import 'package:hive_flutter/hive_flutter.dart';

import '../../features/auth/data/models/user_model.dart';
import '../../features/exercises/data/models/exercise_model.dart';
import '../constants/app_constants.dart';

/// Hive-backed local storage for session, exercise cache, and favourites.
///
/// Uses typed [HiveObject] adapters for auth, exercises, and favourite
/// snapshots. The ordered exercise-id index is a plain `List` (native Hive).
class LocalStorageService {
  LocalStorageService({
    required Box<UserModel> authBox,
    required Box<ExerciseModel> exercisesBox,
    required Box<ExerciseModel> favoritesBox,
    required Box<List> exerciseIndexBox,
  })  : _authBox = authBox,
        _exercisesBox = exercisesBox,
        _favoritesBox = favoritesBox,
        _exerciseIndexBox = exerciseIndexBox;

  final Box<UserModel> _authBox;
  final Box<ExerciseModel> _exercisesBox;
  final Box<ExerciseModel> _favoritesBox;
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

  // ── Favourites (full ExerciseModel snapshots) ─────────────────────────────

  List<String> getFavoriteIds() => _favoritesBox.keys
      .map((key) => key.toString())
      .where((key) => key.isNotEmpty)
      .toList();

  List<ExerciseModel> getFavoriteExercises() =>
      getFavoriteIds()
          .map(_favoritesBox.get)
          .whereType<ExerciseModel>()
          .toList();

  ExerciseModel? getFavoriteExercise(String id) => _favoritesBox.get(id);

  bool isFavorite(String exerciseId) => _favoritesBox.containsKey(exerciseId);

  Future<void> saveFavorite(ExerciseModel exercise) =>
      _favoritesBox.put(exercise.id, exercise.clone());

  Future<void> removeFavorite(String exerciseId) =>
      _favoritesBox.delete(exerciseId);

  Future<void> clearFavorites() => _favoritesBox.clear();

  // ── Bootstrap ─────────────────────────────────────────────────────────────

  static Future<LocalStorageService> init() async {
    await Hive.initFlutter();
    return _open();
  }

  static Future<LocalStorageService> initForTest(String path) async {
    Hive.init(path);
    return _open(clearExisting: true);
  }

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
        await Hive.openBox<ExerciseModel>(AppConstants.hiveFavoritesBox);
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
