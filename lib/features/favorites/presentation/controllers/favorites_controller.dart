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
    favoriteIds.addAll(_favoritesRepository.getFavoriteIds());
    loadFavoriteExercises();
  }

  bool isFavorite(String exerciseId) => favoriteIds.contains(exerciseId);

  Future<void> toggleFavorite(String exerciseId) async {
    final nowFavorite = await _favoritesRepository.toggleFavorite(exerciseId);
    if (nowFavorite) {
      favoriteIds.add(exerciseId);
    } else {
      favoriteIds.remove(exerciseId);
    }
    favoriteIds.refresh();
    await loadFavoriteExercises();
  }

  Future<void> clearAll() async {
    await _favoritesRepository.clear();
    favoriteIds.clear();
    favoriteExercises.clear();
  }

  Future<void> loadFavoriteExercises() async {
    isLoading.value = true;
    try {
      final ids = favoriteIds.toList();
      if (ids.isEmpty) {
        favoriteExercises.clear();
        return;
      }

      final result = await _exerciseRepository.getExercises();
      final byId = {for (final e in result.exercises) e.id: e};
      favoriteExercises.assignAll(
        ids.map((id) => byId[id]).whereType<ExerciseModel>(),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
