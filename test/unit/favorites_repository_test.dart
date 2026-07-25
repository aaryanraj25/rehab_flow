import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_flow/features/favorites/data/repositories/favorites_repository.dart';

import '../helpers/test_harness.dart';

void main() {
  late TestHarness harness;
  late FavoritesRepository favorites;

  setUp(() async {
    harness = await TestHarness.create();
    favorites = harness.favoritesRepository;
  });

  tearDown(() async {
    await harness.dispose();
  });

  group('FavoritesRepositoryImpl', () {
    test('toggle adds then removes an id', () async {
      expect(favorites.isFavorite('1'), isFalse);

      expect(await favorites.toggleFavorite('1'), isTrue);
      expect(favorites.isFavorite('1'), isTrue);
      expect(favorites.getFavoriteIds(), ['1']);

      expect(await favorites.toggleFavorite('1'), isFalse);
      expect(favorites.isFavorite('1'), isFalse);
      expect(favorites.getFavoriteIds(), isEmpty);
    });

    test('addFavorite is idempotent', () async {
      await favorites.addFavorite('2');
      await favorites.addFavorite('2');
      expect(favorites.getFavoriteIds(), ['2']);
    });

    test('clear removes every favourite', () async {
      await favorites.addFavorite('1');
      await favorites.addFavorite('3');
      await favorites.clear();
      expect(favorites.getFavoriteIds(), isEmpty);
    });

    test('persists across repository re-read from storage', () async {
      await favorites.addFavorite('9');
      expect(harness.storage.getFavoriteIds(), contains('9'));
    });
  });
}
