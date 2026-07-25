import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'models/exercise_model.dart';

/// Disk cache for exercise images so they remain available offline.
class ExerciseImageCache {
  ExerciseImageCache._();

  static const key = 'rehab_flow_exercise_images';

  static final CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 200,
    ),
  );

  /// Downloads thumbnail images first (low priority), then hero images.
  /// Best-effort — never throws; UI still has branded fallbacks.
  static Future<void> prefetchExercises(Iterable<ExerciseModel> exercises) async {
    final thumbs = <String>{};
    final heroes = <String>{};
    for (final exercise in exercises) {
      final thumb = exercise.thumbnailUrl?.trim();
      final image = exercise.imageUrl?.trim();
      if (thumb != null && thumb.isNotEmpty) thumbs.add(thumb);
      if (image != null && image.isNotEmpty && image != thumb) {
        heroes.add(image);
      }
    }

    await _downloadAll(thumbs);
    // Yield so list UI can settle before larger hero downloads.
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await _downloadAll(heroes);
  }

  static Future<void> _downloadAll(Set<String> urls) {
    return Future.wait(
      urls.map((url) async {
        try {
          await instance.downloadFile(url);
        } catch (_) {
          // Ignore individual failures — UI still has branded fallback.
        }
      }),
      eagerError: false,
    );
  }
}
