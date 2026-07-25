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
  }

  bool isFavorite(String exerciseId) => favoriteIds.contains(exerciseId);

  /// Resolves a snapshot (cache / API / asset) then persists the full model.
  Future<void> toggleFavorite(String exerciseId) async {
    if (isFavorite(exerciseId)) {
      await _favoritesRepository.removeFavorite(exerciseId);
      favoriteIds.remove(exerciseId);
      favoriteExercises.removeWhere((e) => e.id == exerciseId);
      favoriteIds.refresh();
      return;
    }

    final exercise = await _exerciseRepository.getExerciseById(exerciseId);
    if (exercise == null) return;

    await _favoritesRepository.addFavorite(exercise);
    favoriteIds.add(exerciseId);
    favoriteExercises.add(exercise);
    favoriteIds.refresh();
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
