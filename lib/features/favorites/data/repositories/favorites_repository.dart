import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/local_storage_service.dart';

/// Persists favourite exercise ids locally for offline access.
class FavoritesRepository {
  FavoritesRepository(this._storage);

  final LocalStorageService _storage;

  List<String> getFavoriteIds() {
    return List<String>.from(
      _storage.getStringList(AppConstants.storageFavoritesKey),
    );
  }

  bool isFavorite(String exerciseId) {
    return getFavoriteIds().contains(exerciseId);
  }

  Future<void> addFavorite(String exerciseId) async {
    final ids = getFavoriteIds();
    if (ids.contains(exerciseId)) return;
    ids.add(exerciseId);
    await _storage.setStringList(AppConstants.storageFavoritesKey, ids);
  }

  Future<void> removeFavorite(String exerciseId) async {
    final ids = getFavoriteIds()..remove(exerciseId);
    await _storage.setStringList(AppConstants.storageFavoritesKey, ids);
  }

  Future<bool> toggleFavorite(String exerciseId) async {
    if (isFavorite(exerciseId)) {
      await removeFavorite(exerciseId);
      return false;
    }
    await addFavorite(exerciseId);
    return true;
  }

  Future<void> clear() async {
    await _storage.setStringList(AppConstants.storageFavoritesKey, []);
  }
}
