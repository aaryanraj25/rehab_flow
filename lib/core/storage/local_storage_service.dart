import 'package:hive_flutter/hive_flutter.dart';

import '../../features/auth/data/models/user_model.dart';
import '../../features/exercises/data/models/exercise_model.dart';
import '../constants/app_constants.dart';

/// Hive-backed local storage for session, exercise cache, and favourites.
///
/// Uses typed [HiveObject] adapters for auth + exercises. Favourites and the
/// ordered exercise-id index are plain `List` values (Hive supports those
/// natively without a custom adapter).
class LocalStorageService {
  LocalStorageService({
    required Box<UserModel> authBox,
    required Box<ExerciseModel> exercisesBox,
    required Box<List> favoritesBox,
    required Box<List> exerciseIndexBox,
  })  : _authBox = authBox,
        _exercisesBox = exercisesBox,
        _favoritesBox = favoritesBox,
        _exerciseIndexBox = exerciseIndexBox;

  final Box<UserModel> _authBox;
  final Box<ExerciseModel> _exercisesBox;
  final Box<List> _favoritesBox;
  final Box<List> _exerciseIndexBox;

  // ── Auth session ──────────────────────────────────────────────────────────

  UserModel? getSession() => _authBox.get(AppConstants.storageAuthKey);

  Future<void> saveSession(UserModel user) =>
      _authBox.put(AppConstants.storageAuthKey, user);

  Future<void> clearSession() => _authBox.delete(AppConstants.storageAuthKey);

  bool get hasSession => _authBox.containsKey(AppConstants.storageAuthKey);

  // ── Exercise list + details ───────────────────────────────────────────────

  List<ExerciseModel> getCachedExercises() {
    final ids = _readListIds();
    if (ids.isEmpty) {
      // Fallback if index was never written but details exist.
      return _exercisesBox.values.toList();
    }
    final restored = <ExerciseModel>[];
    for (final id in ids) {
      final exercise = _exercisesBox.get(id);
      if (exercise != null) restored.add(exercise);
    }
    return restored;
  }

  Future<void> saveExercises(List<ExerciseModel> exercises) async {
    for (final exercise in exercises) {
      await _exercisesBox.put(exercise.id, exercise);
    }

    final keep = exercises.map((e) => e.id).toSet();
    final stale = _exercisesBox.keys
        .whereType<String>()
        .where((key) => !keep.contains(key))
        .toList();
    for (final key in stale) {
      await _exercisesBox.delete(key);
    }

    await _exerciseIndexBox.put(
      AppConstants.storageExercisesKey,
      exercises.map((e) => e.id).toList(),
    );
  }

  Future<void> saveExerciseDetail(ExerciseModel exercise) =>
      _exercisesBox.put(exercise.id, exercise);

  ExerciseModel? getExerciseDetail(String id) => _exercisesBox.get(id);

  List<String> _readListIds() {
    final raw = _exerciseIndexBox.get(AppConstants.storageExercisesKey);
    if (raw == null) return const [];
    return raw.map((e) => e.toString()).toList();
  }

  // ── Favourites ────────────────────────────────────────────────────────────

  List<String> getFavoriteIds() {
    final raw = _favoritesBox.get(AppConstants.storageFavoritesKey);
    if (raw == null) return const [];
    return raw.map((e) => e.toString()).toList();
  }

  Future<void> setFavoriteIds(List<String> ids) =>
      _favoritesBox.put(AppConstants.storageFavoritesKey, List<String>.from(ids));

  // ── Bootstrap ─────────────────────────────────────────────────────────────

  /// Opens Hive boxes, registers adapters, and returns a ready service.
  static Future<LocalStorageService> init() async {
    await Hive.initFlutter();
    return _open();
  }

  /// Test helper — Hive on a filesystem path (no Flutter plugin binding).
  static Future<LocalStorageService> initForTest(String path) async {
    Hive.init(path);
    return _open(clearExisting: true);
  }

  /// Closes all open boxes — call from test tearDown before deleting the temp dir.
  static Future<void> closeForTest() => Hive.close();


  static Future<LocalStorageService> _open({bool clearExisting = false}) async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ExerciseModelAdapter());
    }

    final authBox = await Hive.openBox<UserModel>(AppConstants.hiveAuthBox);
    final exercisesBox =
        await Hive.openBox<ExerciseModel>(AppConstants.hiveExercisesBox);
    final favoritesBox =
        await Hive.openBox<List>(AppConstants.hiveFavoritesBox);
    final exerciseIndexBox =
        await Hive.openBox<List>(AppConstants.hiveExerciseIndexBox);

    if (clearExisting) {
      await authBox.clear();
      await exercisesBox.clear();
      await favoritesBox.clear();
      await exerciseIndexBox.clear();
    }

    return LocalStorageService(
      authBox: authBox,
      exercisesBox: exercisesBox,
      favoritesBox: favoritesBox,
      exerciseIndexBox: exerciseIndexBox,
    );
  }
}
