import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_flow/features/exercises/data/repositories/exercise_repository.dart';
import 'package:rehab_flow/features/exercises/presentation/controllers/exercise_controller.dart';

import '../helpers/test_harness.dart';

void main() {
  late TestHarness harness;

  setUp(() async {
    // Offline → repository serves bundled asset and Hive-caches it.
    harness = await TestHarness.create(online: false);
  });

  tearDown(() async {
    await harness.dispose();
  });

  group('ExerciseRepositoryImpl', () {
    test('loads bundled exercises offline and caches them', () async {
      final result = await harness.exerciseRepository.getExercises();

      expect(result.exercises, isNotEmpty);
      expect(result.isOffline, isTrue);
      expect(result.fromCache, isTrue);
      expect(harness.storage.getCachedExercises().length, result.exercises.length);
    });

    test('getExerciseById returns a cached detail', () async {
      final result = await harness.exerciseRepository.getExercises();
      final first = result.exercises.first;

      final detail = await harness.exerciseRepository.getExerciseById(first.id);
      expect(detail?.id, first.id);
      expect(detail?.name, first.name);
    });

    test('getRelatedExercises resolves relatedIds', () async {
      final result = await harness.exerciseRepository.getExercises();
      final withRelated = result.exercises.firstWhere(
        (e) => e.relatedIds.isNotEmpty,
      );

      final related =
          await harness.exerciseRepository.getRelatedExercises(withRelated);
      expect(related, isNotEmpty);
      expect(
        related.every((e) => withRelated.relatedIds.contains(e.id)),
        isTrue,
      );
    });

    test('serves Hive cache on subsequent offline loads', () async {
      final first = await harness.exerciseRepository.getExercises();
      final second = await harness.exerciseRepository.getExercises();

      expect(second.exercises.length, first.exercises.length);
      expect(second.isOffline, isTrue);
    });
  });

  group('ExerciseController search & filters', () {
    late ExerciseController controller;

    setUp(() async {
      controller = ExerciseController(
        harness.exerciseRepository,
        harness.networkInfo,
      );
      await controller.loadExercises();
    });

    tearDown(() {
      controller.onClose();
    });

    test('loads exercises into success state', () {
      expect(controller.status.value, ExerciseListStatus.success);
      expect(controller.allExercises, isNotEmpty);
      expect(controller.isOffline.value, isTrue);
    });

    test('search is case-insensitive and live', () {
      controller.onSearchChanged('KNEE');
      expect(controller.filteredExercises, isNotEmpty);
      expect(
        controller.filteredExercises.every(
          (e) => e.name.toLowerCase().contains('knee'),
        ),
        isTrue,
      );

      controller.onSearchChanged('');
      expect(
        controller.filteredExercises.length,
        controller.allExercises.length,
      );

      controller.onSearchChanged('zzzz-no-match');
      expect(controller.filteredExercises, isEmpty);
    });

    test('difficulty and search AND with category; muscle ORs with category',
        () {
      final total = controller.filteredExercises.length;

      controller.selectCategory('Strength');
      controller.selectDifficulty('Beginner');
      final afterFacets = controller.filteredExercises;
      expect(afterFacets, isNotEmpty);
      expect(afterFacets.length, lessThanOrEqualTo(total));
      expect(
        afterFacets.every(
          (e) => e.category == 'Strength' && e.difficulty == 'Beginner',
        ),
        isTrue,
      );

      final muscle = afterFacets.first.targetMuscle;
      controller.selectMuscle(muscle);

      // Category + muscle → show if Strength OR that muscle (still Beginner).
      expect(
        controller.filteredExercises.every(
          (e) =>
              e.difficulty == 'Beginner' &&
              (e.category == 'Strength' || e.targetMuscle == muscle),
        ),
        isTrue,
      );
      expect(
        controller.filteredExercises.any((e) => e.category == 'Strength'),
        isTrue,
      );

      controller.onSearchChanged(afterFacets.first.name.substring(0, 3));
      expect(
        controller.filteredExercises.every(
          (e) => e.name.toLowerCase().contains(
                afterFacets.first.name.substring(0, 3).toLowerCase(),
              ),
        ),
        isTrue,
      );

      controller.clearFilters();
      expect(controller.filteredExercises.length, total);
      expect(controller.hasActiveFilters, isFalse);
    });

    test('single category + single muscle still ORs together', () {
      controller.selectCategory('Strength');
      final strengthCount = controller.filteredExercises.length;

      // Pick a muscle that exists on a non-Strength exercise when possible.
      final otherMuscle = controller.allExercises
          .where((e) => e.category != 'Strength')
          .map((e) => e.targetMuscle)
          .toSet()
          .first;

      controller.selectMuscle(otherMuscle);
      final combined = controller.filteredExercises;

      expect(
        combined.every(
          (e) =>
              e.category == 'Strength' || e.targetMuscle == otherMuscle,
        ),
        isTrue,
      );
      // Broader than Strength-only because muscle facet adds matches.
      expect(combined.length, greaterThanOrEqualTo(strengthCount));
    });

    test('multiple categories use OR within the category facet', () {
      final cats = controller.categories.take(2).toList();
      expect(cats, hasLength(2));

      controller.selectCategory(cats[0]);
      controller.selectCategory(cats[1]);
      expect(controller.selectedCategories, unorderedEquals(cats));

      final filtered = controller.filteredExercises;
      expect(filtered, isNotEmpty);
      expect(
        filtered.every((e) => cats.contains(e.category)),
        isTrue,
      );
    });

    test('multiple target muscles use OR within the muscle facet', () {
      final muscles = controller.targetMuscles.take(2).toList();
      expect(muscles, hasLength(2));

      controller.selectMuscle(muscles[0]);
      controller.selectMuscle(muscles[1]);
      expect(controller.selectedMuscles, unorderedEquals(muscles));

      final filtered = controller.filteredExercises;
      expect(filtered, isNotEmpty);
      expect(
        filtered.every((e) => muscles.contains(e.targetMuscle)),
        isTrue,
      );

      // Deselect one — remaining muscle still filters.
      controller.selectMuscle(muscles[0]);
      expect(controller.selectedMuscles, equals({muscles[1]}));
      expect(
        controller.filteredExercises
            .every((e) => e.targetMuscle == muscles[1]),
        isTrue,
      );
    });

    test('selecting the same facet again clears it', () {
      controller.selectCategory('Strength');
      expect(controller.selectedCategories, equals({'Strength'}));
      controller.selectCategory('Strength');
      expect(controller.selectedCategories, isEmpty);
    });
  });
}
