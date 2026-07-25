import 'dart:async' show unawaited;
import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../network/api_client.dart';
import '../models/exercise_model.dart';
import '../exercise_image_cache.dart';

/// Contract for loading / caching exercises (API, Hive, asset fallback).
abstract class ExerciseRepository {
  Future<ExerciseFetchResult> getExercises({bool forceRefresh = false});

  Future<ExerciseModel?> getExerciseById(String id);

  Future<List<ExerciseModel>> getRelatedExercises(ExerciseModel exercise);

  Future<void> cacheExerciseDetail(ExerciseModel exercise);
}

/// Hive + Dio backed [ExerciseRepository] implementation.
///
/// Online path is **REST-first**. Local Hive cache and the bundled asset are
/// fallbacks when the network fails (unless [forceRefresh] is true — then API
/// failures surface as hard errors for [AppErrorView] + retry).
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
    if (AppConstants.debugForceApiHardFailure) {
      throw const NetworkException(
        'Debug hard-fail is on — showing the API error screen.',
      );
    }

    final online = await _networkInfo.isConnected;
    final cached = _readCachedExercises();

    if (!online) {
      return _offlineResult(cached);
    }

    // Online: always try the REST feed first.
    try {
      final remote = await _fetchFromApi();
      await _persistAll(remote);
      unawaited(ExerciseImageCache.prefetchExercises(remote));
      return ExerciseFetchResult(
        exercises: remote,
        fromCache: false,
        isOffline: false,
      );
    } catch (e) {
      final mapped = ExceptionMapper.from(e);

      // Pull-to-refresh / retry: hard-fail so AppErrorView + Retry appear.
      if (forceRefresh) {
        throw mapped;
      }

      // Initial load: soft-fall back to Hive, then bundled asset.
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
      } catch (_) {
        throw mapped;
      }
    }
  }

  Future<ExerciseFetchResult> _offlineResult(List<ExerciseModel> cached) async {
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

  List<ExerciseModel> _readCachedExercises() => _storage.getCachedExercises();

  @override
  Future<ExerciseModel?> getExerciseById(String id) async {
    final cached = _storage.getExerciseDetail(id);
    if (cached != null) return cached;

    final favorite = _storage.getFavoriteExercise(id);
    if (favorite != null) return favorite;

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
    return _storage.saveExercises(exercises);
  }

  Future<List<ExerciseModel>> _fetchFromApi() async {
    try {
      final response = await _apiClient.get(AppConstants.exercisesApiUrl);
      final list = _parseListPayload(response.data);
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
