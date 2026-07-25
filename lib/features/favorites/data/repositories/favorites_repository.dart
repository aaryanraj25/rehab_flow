import '../../../../core/storage/local_storage_service.dart';

/// Contract for favourite exercise id persistence.
abstract class FavoritesRepository {
  List<String> getFavoriteIds();

  bool isFavorite(String exerciseId);

  Future<void> addFavorite(String exerciseId);

  Future<void> removeFavorite(String exerciseId);

  Future<bool> toggleFavorite(String exerciseId);

  Future<void> clear();
}

/// Hive-backed [FavoritesRepository] implementation.
class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._storage);

  final LocalStorageService _storage;

  @override
  List<String> getFavoriteIds() =>
      List<String>.from(_storage.getFavoriteIds());

  @override
  bool isFavorite(String exerciseId) {
    return getFavoriteIds().contains(exerciseId);
  }

  @override
  Future<void> addFavorite(String exerciseId) async {
    final ids = getFavoriteIds();
    if (ids.contains(exerciseId)) return;
    ids.add(exerciseId);
    await _storage.setFavoriteIds(ids);
  }

  @override
  Future<void> removeFavorite(String exerciseId) async {
    final ids = getFavoriteIds()..remove(exerciseId);
    await _storage.setFavoriteIds(ids);
  }

  @override
  Future<bool> toggleFavorite(String exerciseId) async {
    if (isFavorite(exerciseId)) {
      await removeFavorite(exerciseId);
      return false;
    }
    await addFavorite(exerciseId);
    return true;
  }

  @override
  Future<void> clear() async {
    await _storage.setFavoriteIds([]);
  }
}
