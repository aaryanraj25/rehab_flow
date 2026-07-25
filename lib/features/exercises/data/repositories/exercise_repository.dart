import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../network/api_client.dart';
import '../models/exercise_model.dart';
import '../exercise_image_cache.dart';

/// Loads exercises from bundled asset (source of truth for MVP content),
/// optionally refreshes from a public REST endpoint, and caches for offline use.
class ExerciseRepository {
  ExerciseRepository({
    required LocalStorageService storage,
    required ApiClient apiClient,
    required NetworkInfo networkInfo,
  })  : _storage = storage,
        _apiClient = apiClient,
        _networkInfo = networkInfo;

  final LocalStorageService _storage;
  final ApiClient _apiClient;
  final NetworkInfo _networkInfo;

  static const String assetPath = AppConstants.exercisesAssetPath;

  Future<ExerciseFetchResult> getExercises({bool forceRefresh = false}) async {
    final online = await _networkInfo.isConnected;
    final cached = _readCachedExercises();

    // Offline: serve local cache first, then bundled asset.
    if (!online) {
      if (cached.isNotEmpty) {
        return ExerciseFetchResult(
          exercises: cached,
          fromCache: true,
          isOffline: true,
        );
      }
      try {
        final asset = await _loadFromAsset();
        if (asset.isEmpty) {
          throw ApiException('No exercises available offline.');
        }
        await _persistAll(asset);
        return ExerciseFetchResult(
          exercises: asset,
          fromCache: true,
          isOffline: true,
        );
      } catch (e) {
        // Truly nothing to show — surface as a hard failure to the controller.
        rethrow;
      }
    }

    // Pull-to-refresh can try the remote feed; otherwise prefer the bundled
    // dataset so local content updates are not masked by stale GitHub JSON.
    if (forceRefresh) {
      try {
        final remote = await _fetchFromApi();
        await _persistAll(remote);
        unawaited(ExerciseImageCache.prefetchExercises(remote));
        return ExerciseFetchResult(
          exercises: remote,
          fromCache: false,
          isOffline: false,
        );
      } catch (_) {
        if (cached.isNotEmpty) {
          unawaited(ExerciseImageCache.prefetchExercises(cached));
          return ExerciseFetchResult(
            exercises: cached,
            fromCache: true,
            isOffline: false,
            refreshFailed: true,
          );
        }
        // No cache — fall through to asset, still signal soft refresh failure.
        final asset = await _loadFromAsset();
        await _persistAll(asset);
        unawaited(ExerciseImageCache.prefetchExercises(asset));
        return ExerciseFetchResult(
          exercises: asset,
          fromCache: true,
          isOffline: false,
          refreshFailed: true,
        );
      }
    }

    final asset = await _loadFromAsset();
    await _persistAll(asset);
    // Warm disk cache while online so detail/list images work offline.
    unawaited(ExerciseImageCache.prefetchExercises(asset));
    return ExerciseFetchResult(
      exercises: asset,
      fromCache: true,
      isOffline: false,
    );
  }

  List<ExerciseModel> _readCachedExercises() {
    final raw = _storage.getJson(AppConstants.storageExercisesKey);
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => ExerciseModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<ExerciseModel?> getExerciseById(String id) async {
    final detailKey = '${AppConstants.storageExerciseDetailsPrefix}$id';
    final cachedJson = _storage.getJson(detailKey);
    if (cachedJson is Map<String, dynamic>) {
      return ExerciseModel.fromJson(cachedJson);
    }

    final result = await getExercises();
    try {
      final match = result.exercises.firstWhere((e) => e.id == id);
      await cacheExerciseDetail(match);
      return match;
    } catch (_) {
      return null;
    }
  }

  Future<List<ExerciseModel>> getRelatedExercises(ExerciseModel exercise) async {
    if (exercise.relatedIds.isEmpty) return const [];
    final result = await getExercises();
    final byId = {for (final item in result.exercises) item.id: item};
    return exercise.relatedIds
        .map((id) => byId[id])
        .whereType<ExerciseModel>()
        .toList();
  }

  Future<void> cacheExerciseDetail(ExerciseModel exercise) {
    return _storage.setJson(
      '${AppConstants.storageExerciseDetailsPrefix}${exercise.id}',
      exercise.toJson(),
    );
  }

  Future<void> _persistAll(List<ExerciseModel> exercises) async {
    await _cacheExercises(exercises);
    for (final exercise in exercises) {
      await cacheExerciseDetail(exercise);
    }
  }

  Future<void> _cacheExercises(List<ExerciseModel> exercises) {
    return _storage.setJson(
      AppConstants.storageExercisesKey,
      exercises.map((e) => e.toJson()).toList(),
    );
  }

  Future<List<ExerciseModel>> _fetchFromApi() async {
    final response = await _apiClient.get(AppConstants.exercisesApiUrl);
    final data = response.data;
    final list = _parseListPayload(data);
    if (list.isEmpty) {
      throw ApiException('Empty exercise payload from API');
    }
    return list;
  }

  Future<List<ExerciseModel>> _loadFromAsset() async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw);
    return _parseListPayload(decoded);
  }

  List<ExerciseModel> _parseListPayload(dynamic data) {
    if (data is String) {
      data = jsonDecode(data);
    }
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => ExerciseModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
