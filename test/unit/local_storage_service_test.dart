import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_harness.dart';

void main() {
  late TestHarness harness;

  setUp(() async {
    harness = await TestHarness.create();
  });

  tearDown(() async {
    await harness.dispose();
  });

  group('LocalStorageService (Hive)', () {
    test('saves and restores auth session', () async {
      final user = await harness.authRepository.login(
        email: 'a@b.com',
        password: 'secret1',
      );

      expect(harness.storage.getSession()?.email, user.email);
      await harness.storage.clearSession();
      expect(harness.storage.getSession(), isNull);
    });

    test('saves exercise list and per-id details', () async {
      final exercises = [
        buildExercise(id: '1', name: 'A'),
        buildExercise(id: '2', name: 'B', category: 'Mobility'),
      ];

      await harness.storage.saveExercises(exercises);

      final cached = harness.storage.getCachedExercises();
      expect(cached.map((e) => e.id), ['1', '2']);
      expect(harness.storage.getExerciseDetail('2')?.name, 'B');
      expect(harness.storage.getExerciseDetail('missing'), isNull);
    });

    test('saveExercises drops stale ids', () async {
      await harness.storage.saveExercises([
        buildExercise(id: '1'),
        buildExercise(id: '2'),
      ]);
      await harness.storage.saveExercises([buildExercise(id: '2')]);

      expect(harness.storage.getCachedExercises().map((e) => e.id), ['2']);
      expect(harness.storage.getExerciseDetail('1'), isNull);
    });

    test('favourite snapshots round-trip', () async {
      await harness.storage.saveFavorite(
        buildExercise(id: '1', name: 'A'),
      );
      await harness.storage.saveFavorite(
        buildExercise(id: '5', name: 'B'),
      );
      expect(harness.storage.getFavoriteIds(), ['1', '5']);
      expect(harness.storage.getFavoriteExercise('5')?.name, 'B');
      await harness.storage.clearFavorites();
      expect(harness.storage.getFavoriteIds(), isEmpty);
    });
  });
}
