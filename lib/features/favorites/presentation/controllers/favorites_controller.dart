import 'package:get/get.dart';

import '../../../exercises/data/models/exercise_model.dart';
import '../../../exercises/data/repositories/exercise_repository.dart';
import '../../data/repositories/favorites_repository.dart';

class FavoritesController extends GetxController {
  FavoritesController({
    required FavoritesRepository favoritesRepository,
    required ExerciseRepository exerciseRepository,
  })  : _favoritesRepository = favoritesRepository,
        _exerciseRepository = exerciseRepository;

  final FavoritesRepository _favoritesRepository;
  final ExerciseRepository _exerciseRepository;

  final RxSet<String> favoriteIds = <String>{}.obs;
  final RxList<ExerciseModel> favoriteExercises = <ExerciseModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _hydrateFromStorage();
  }

  void _hydrateFromStorage() {
    favoriteIds
      ..clear()
      ..addAll(_favoritesRepository.getFavoriteIds());
    favoriteExercises.assignAll(_favoritesRepository.getFavoriteExercises());
    favoriteIds.refresh();
    favoriteExercises.refresh();
  }

  bool isFavorite(String exerciseId) {
    // Prefer ids set; also treat anything currently listed as favourited
    // so hearts stay filled on the Favourites screen.
    if (favoriteIds.toList().contains(exerciseId)) return true;
    return favoriteExercises.any((e) => e.id == exerciseId);
  }

  /// Resolves a snapshot (cache / API / asset) then persists the full model.
  /// Pass [snapshot] when the UI already has the exercise to avoid a lookup miss
  /// and to clone out of the exercises Hive box before favouriting.
  Future<void> toggleFavorite(
    String exerciseId, {
    ExerciseModel? snapshot,
  }) async {
    if (isFavorite(exerciseId)) {
      await _favoritesRepository.removeFavorite(exerciseId);
      favoriteIds.remove(exerciseId);
      favoriteExercises.removeWhere((e) => e.id == exerciseId);
      favoriteIds.refresh();
      favoriteExercises.refresh();
      return;
    }

    final exercise =
        snapshot ?? await _exerciseRepository.getExerciseById(exerciseId);
    if (exercise == null) return;

    await _favoritesRepository.addFavorite(exercise);
    favoriteIds.add(exerciseId);
    if (!favoriteExercises.any((e) => e.id == exerciseId)) {
      favoriteExercises.add(exercise.clone());
    }
    favoriteIds.refresh();
    favoriteExercises.refresh();
  }

  Future<void> clearAll() async {
    await _favoritesRepository.clear();
    favoriteIds.clear();
    favoriteExercises.clear();
  }

  Future<void> loadFavoriteExercises() async {
    isLoading.value = true;
    try {
      _hydrateFromStorage();
    } finally {
      isLoading.value = false;
    }
  }
}
