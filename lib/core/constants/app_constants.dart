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

  static const String storageAuthKey = 'auth_session';
  static const String storageExercisesKey = 'cached_exercises';
  static const String storageFavoritesKey = 'favorite_exercise_ids';
  static const String storageExerciseDetailsPrefix = 'exercise_detail_';

  static const Duration apiTimeout = Duration(seconds: 12);
  static const int passwordMinLength = 6;

  static const String demoEmailHint = 'demo@rehabflow.app';
  static const String demoPasswordHint = 'rehab123';
}
