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
    test('toggle adds then removes a snapshot', () async {
      final exercise = buildExercise(id: '1', name: 'Knee Ext');
      expect(favorites.isFavorite('1'), isFalse);

      expect(await favorites.toggleFavorite(exercise), isTrue);
      expect(favorites.isFavorite('1'), isTrue);
      expect(favorites.getFavoriteIds(), ['1']);
      expect(favorites.getFavoriteExercises().first.name, 'Knee Ext');

      expect(await favorites.toggleFavorite(exercise), isFalse);
      expect(favorites.isFavorite('1'), isFalse);
      expect(favorites.getFavoriteIds(), isEmpty);
    });

    test('addFavorite is idempotent', () async {
      final exercise = buildExercise(id: '2');
      await favorites.addFavorite(exercise);
      await favorites.addFavorite(exercise);
      expect(favorites.getFavoriteIds(), ['2']);
    });

    test('clear removes every favourite', () async {
      await favorites.addFavorite(buildExercise(id: '1'));
      await favorites.addFavorite(buildExercise(id: '3'));
      await favorites.clear();
      expect(favorites.getFavoriteIds(), isEmpty);
      expect(favorites.getFavoriteExercises(), isEmpty);
    });

    test('persists snapshot across repository re-read from storage', () async {
      await favorites.addFavorite(buildExercise(id: '9', name: 'Persist Me'));
      expect(harness.storage.getFavoriteExercise('9')?.name, 'Persist Me');
    });
  });
}
