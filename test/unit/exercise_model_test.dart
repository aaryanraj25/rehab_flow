import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_flow/features/exercises/data/models/exercise_model.dart';

void main() {
  group('ExerciseModel', () {
    test('fromJson maps required fields and coerces id to string', () {
      final exercise = ExerciseModel.fromJson({
        'id': 7,
        'name': 'Mini Squats',
        'category': 'Strength',
        'difficulty': 'Intermediate',
        'targetMuscle': 'Quadriceps',
        'description': 'desc',
        'instructions': 'Do one. Do two.',
        'equipment': 'None',
        'thumbnailUrl': 'https://example.com/t.jpg',
        'imageUrl': 'https://example.com/i.jpg',
        'relatedIds': [1, '2'],
      });

      expect(exercise.id, '7');
      expect(exercise.name, 'Mini Squats');
      expect(exercise.category, 'Strength');
      expect(exercise.difficulty, 'Intermediate');
      expect(exercise.targetMuscle, 'Quadriceps');
      expect(exercise.thumbnailUrl, isNotNull);
      expect(exercise.relatedIds, ['1', '2']);
    });

    test('fromJson applies defaults for missing optional fields', () {
      final exercise = ExerciseModel.fromJson({'id': 'x'});

      expect(exercise.name, '');
      expect(exercise.category, 'General');
      expect(exercise.difficulty, 'Beginner');
      expect(exercise.targetMuscle, 'Full Body');
      expect(exercise.equipment, 'None');
      expect(exercise.relatedIds, isEmpty);
      expect(exercise.thumbnailUrl, isNull);
    });

    test('toJson round-trips core fields', () {
      final original = ExerciseModel.fromJson({
        'id': '3',
        'name': 'Wall Push-Up',
        'category': 'Strength',
        'difficulty': 'Beginner',
        'targetMuscle': 'Chest',
        'description': 'd',
        'instructions': 'i',
        'equipment': 'Wall',
        'relatedIds': ['7', '10'],
      });

      final again = ExerciseModel.fromJson(original.toJson());
      expect(again.id, original.id);
      expect(again.name, original.name);
      expect(again.relatedIds, original.relatedIds);
    });

    test('instructionSteps splits on sentence boundaries', () {
      final exercise = ExerciseModel.fromJson({
        'id': '1',
        'instructions': 'Sit upright. Extend the knee. Lower slowly.',
      });

      expect(exercise.instructionSteps, [
        'Sit upright.',
        'Extend the knee.',
        'Lower slowly.',
      ]);
    });

    test('instructionSteps returns empty for blank instructions', () {
      final exercise = ExerciseModel.fromJson({'id': '1', 'instructions': '  '});
      expect(exercise.instructionSteps, isEmpty);
    });
  });
}
