import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:rehab_flow/features/exercises/data/models/exercise_model.dart';
import 'package:rehab_flow/features/exercises/data/repositories/exercise_repository.dart';
import 'package:rehab_flow/features/favorites/presentation/controllers/favorites_controller.dart';

import '../helpers/test_harness.dart';

class _FakeExerciseRepository implements ExerciseRepository {
  _FakeExerciseRepository(this.exercises);

  final List<ExerciseModel> exercises;

  @override
  Future<void> cacheExerciseDetail(ExerciseModel exercise) async {}

  @override
  Future<ExerciseModel?> getExerciseById(String id) async {
    try {
      return exercises.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<ExerciseFetchResult> getExercises({bool forceRefresh = false}) async {
    return ExerciseFetchResult(exercises: exercises, fromCache: true);
  }

  @override
  Future<List<ExerciseModel>> getRelatedExercises(ExerciseModel exercise) async {
    return exercises.where((e) => exercise.relatedIds.contains(e.id)).toList();
  }
}

void main() {
  late TestHarness harness;
  late FavoritesController controller;

  setUp(() async {
    harness = await TestHarness.create();
    final fakeRepo = _FakeExerciseRepository([
      buildExercise(id: '1', name: 'Seated Knee Extension'),
      buildExercise(id: '2', name: 'Ankle Circles'),
    ]);

    if (Get.isRegistered<FavoritesController>()) {
      await Get.delete<FavoritesController>(force: true);
    }
    controller = FavoritesController(
      favoritesRepository: harness.favoritesRepository,
      exerciseRepository: fakeRepo,
    );
    Get.put(controller, permanent: true);
  });

  tearDown(() async {
    await harness.dispose();
  });

  group('FavoritesController', () {
    test('toggle updates ids and resolved exercise list', () async {
      expect(controller.favoriteIds, isEmpty);

      await controller.toggleFavorite('1');
      expect(controller.isFavorite('1'), isTrue);
      expect(controller.favoriteExercises.map((e) => e.id), ['1']);

      await controller.toggleFavorite('2');
      expect(controller.favoriteExercises.map((e) => e.id), ['1', '2']);

      await controller.toggleFavorite('1');
      expect(controller.isFavorite('1'), isFalse);
      expect(controller.favoriteExercises.map((e) => e.id), ['2']);
    });

    test('clearAll wipes favourites', () async {
      await controller.toggleFavorite('1');
      await controller.clearAll();
      expect(controller.favoriteIds, isEmpty);
      expect(controller.favoriteExercises, isEmpty);
    });
  });
}
