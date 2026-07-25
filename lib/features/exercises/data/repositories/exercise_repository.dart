import 'dart:async' show unawaited;
import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../network/api_client.dart';
import '../models/exercise_model.dart';
import '../exercise_image_cache.dart';

/// Contract for loading / caching exercises (asset, API, Hive).
abstract class ExerciseRepository {
  Future<ExerciseFetchResult> getExercises({bool forceRefresh = false});

  Future<ExerciseModel?> getExerciseById(String id);

  Future<List<ExerciseModel>> getRelatedExercises(ExerciseModel exercise);

  Future<void> cacheExerciseDetail(ExerciseModel exercise);
}

/// Hive + Dio backed [ExerciseRepository] implementation.
class ExerciseRepositoryImpl implements ExerciseRepository {
  ExerciseRepositoryImpl({
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

  @override
  Future<ExerciseFetchResult> getExercises({bool forceRefresh = false}) async {
    // Debug hard-fail path: skip soft-fail so AppErrorView is demoable.
    if (AppConstants.debugForceApiHardFailure) {
      final remote = await _fetchFromApi();
      await _persistAll(remote);
      unawaited(ExerciseImageCache.prefetchExercises(remote));
      return ExerciseFetchResult(
        exercises: remote,
        fromCache: false,
        isOffline: false,
      );
    }

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
          throw const NetworkException(
            'No internet connection and no saved exercises to show.',
          );
        }
        await _persistAll(asset);
        return ExerciseFetchResult(
          exercises: asset,
          fromCache: true,
          isOffline: true,
        );
      } catch (e) {
        throw ExceptionMapper.from(e);
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
        // Soft-fail: keep showing local data when a refresh fails.
        if (cached.isNotEmpty) {
          unawaited(ExerciseImageCache.prefetchExercises(cached));
          return ExerciseFetchResult(
            exercises: cached,
            fromCache: true,
            isOffline: false,
            refreshFailed: true,
          );
        }
        try {
          final asset = await _loadFromAsset();
          await _persistAll(asset);
          unawaited(ExerciseImageCache.prefetchExercises(asset));
          return ExerciseFetchResult(
            exercises: asset,
            fromCache: true,
            isOffline: false,
            refreshFailed: true,
          );
        } catch (e) {
          throw ExceptionMapper.from(e);
        }
      }
    }

    try {
      final asset = await _loadFromAsset();
      await _persistAll(asset);
      // Warm disk cache while online so detail/list images work offline.
      unawaited(ExerciseImageCache.prefetchExercises(asset));
      return ExerciseFetchResult(
        exercises: asset,
        fromCache: true,
        isOffline: false,
      );
    } catch (e) {
      throw ExceptionMapper.from(e);
    }
  }

  List<ExerciseModel> _readCachedExercises() => _storage.getCachedExercises();

  @override
  Future<ExerciseModel?> getExerciseById(String id) async {
    final cached = _storage.getExerciseDetail(id);
    if (cached != null) return cached;

    final result = await getExercises();
    try {
      final match = result.exercises.firstWhere((e) => e.id == id);
      await cacheExerciseDetail(match);
      return match;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ExerciseModel>> getRelatedExercises(ExerciseModel exercise) async {
    if (exercise.relatedIds.isEmpty) return const [];
    final result = await getExercises();
    final byId = {for (final item in result.exercises) item.id: item};
    return exercise.relatedIds
        .map((id) => byId[id])
        .whereType<ExerciseModel>()
        .toList();
  }

  @override
  Future<void> cacheExerciseDetail(ExerciseModel exercise) {
    return _storage.saveExerciseDetail(exercise);
  }

  Future<void> _persistAll(List<ExerciseModel> exercises) {
    // saveExercises writes both the ordered index and per-id detail entries.
    return _storage.saveExercises(exercises);
  }

  Future<List<ExerciseModel>> _fetchFromApi() async {
    if (AppConstants.debugForceApiHardFailure) {
      throw const NetworkException();
    }

    try {
      final response = await _apiClient.get(AppConstants.exercisesApiUrl);
      final data = response.data;
      final list = _parseListPayload(data);
      if (list.isEmpty) {
        throw const ServerException('No exercises returned from the server.');
      }
      return list;
    } catch (e) {
      throw ExceptionMapper.from(e);
    }
  }

  Future<List<ExerciseModel>> _loadFromAsset() async {
    try {
      final raw = await rootBundle.loadString(assetPath);
      final decoded = jsonDecode(raw);
      final list = _parseListPayload(decoded);
      if (list.isEmpty) {
        throw const UnknownException('Exercise data is empty.');
      }
      return list;
    } catch (e) {
      throw ExceptionMapper.from(e);
    }
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
