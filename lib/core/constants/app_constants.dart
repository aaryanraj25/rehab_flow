/// App-wide constants for RehabFlow.
class AppConstants {
  AppConstants._();

  static const String appName = 'RehabFlow';
  static const String appTagline = 'Rehabilitation Exercise Management';

  /// Base design canvas for [flutter_screenutil] (logical px).
  static const double designWidth = 390;
  static const double designHeight = 844;

  /// Public REST endpoint for exercises (fallback: bundled asset + local cache).
  static const String exercisesApiUrl =
      'https://raw.githubusercontent.com/aaryanraj25/rehab_flow/main/assets/data/exercises.json';

  static const String exercisesAssetPath = 'assets/data/exercises.json';

  /// Hive box names (one box per concern for isolated clear/reset).
  static const String hiveAuthBox = 'auth_box';
  static const String hiveExercisesBox = 'exercises_box';
  /// Typed favourite snapshots ([ExerciseModel] per id).
  static const String hiveFavoritesBox = 'favorites_exercises_box';
  static const String hiveExerciseIndexBox = 'exercise_index_box';

  /// Keys within the Hive boxes.
  static const String storageAuthKey = 'auth_session';
  static const String storageExercisesKey = 'cached_exercises_v2';

  static const Duration apiTimeout = Duration(seconds: 12);
  static const int passwordMinLength = 6;

  static const String demoEmailHint = 'demo@rehabflow.app';
  static const String demoPasswordHint = 'rehab123';

  /// Debug-only: force the hard [AppErrorView] path on every exercise load
  /// (skips REST/cache/asset). Keep `false` for normal use; flip to demo the
  /// API-failure screen without yanking the network.
  static const bool debugForceApiHardFailure = false;
}
