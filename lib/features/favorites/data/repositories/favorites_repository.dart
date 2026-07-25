import '../../../../core/storage/local_storage_service.dart';
import '../../../exercises/data/models/exercise_model.dart';

/// Contract for favourite exercise persistence (full model snapshots).
abstract class FavoritesRepository {
  List<String> getFavoriteIds();

  List<ExerciseModel> getFavoriteExercises();

  bool isFavorite(String exerciseId);

  Future<void> addFavorite(ExerciseModel exercise);

  Future<void> removeFavorite(String exerciseId);

  /// Toggles by [exercise.id]. Pass the full model so a snapshot is stored.
  Future<bool> toggleFavorite(ExerciseModel exercise);

  Future<void> clear();
}

/// Hive-backed [FavoritesRepository] — stores [ExerciseModel] snapshots offline.
class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._storage);

  final LocalStorageService _storage;

  @override
  List<String> getFavoriteIds() =>
      List<String>.from(_storage.getFavoriteIds());

  @override
  List<ExerciseModel> getFavoriteExercises() =>
      List<ExerciseModel>.from(_storage.getFavoriteExercises());

  @override
  bool isFavorite(String exerciseId) => _storage.isFavorite(exerciseId);

  @override
  Future<void> addFavorite(ExerciseModel exercise) =>
      _storage.saveFavorite(exercise);

  @override
  Future<void> removeFavorite(String exerciseId) =>
      _storage.removeFavorite(exerciseId);

  @override
  Future<bool> toggleFavorite(ExerciseModel exercise) async {
    if (isFavorite(exercise.id)) {
      await removeFavorite(exercise.id);
      return false;
    }
    await addFavorite(exercise);
    return true;
  }

  @override
  Future<void> clear() => _storage.clearFavorites();
}
