import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:rehab_flow/core/routes/app_routes.dart';
import 'package:rehab_flow/features/auth/presentation/controllers/auth_controller.dart';
import 'package:rehab_flow/features/exercises/data/models/exercise_model.dart';
import 'package:rehab_flow/features/exercises/data/repositories/exercise_repository.dart';
import 'package:rehab_flow/features/exercises/presentation/controllers/exercise_controller.dart';
import 'package:rehab_flow/features/exercises/presentation/screens/exercise_list_screen.dart';
import 'package:rehab_flow/features/exercises/presentation/widgets/exercise_card.dart';
import 'package:rehab_flow/features/favorites/presentation/controllers/favorites_controller.dart';
import 'package:rehab_flow/utils/responsive.dart';

import '../helpers/test_harness.dart';

/// In-memory repo so widget tests never hit Dio / image prefetch / assets IO races.
class _FakeExerciseRepository implements ExerciseRepository {
  _FakeExerciseRepository(this._exercises);

  final List<ExerciseModel> _exercises;

  @override
  Future<void> cacheExerciseDetail(ExerciseModel exercise) async {}

  @override
  Future<ExerciseModel?> getExerciseById(String id) async {
    try {
      return _exercises.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<ExerciseFetchResult> getExercises({bool forceRefresh = false}) async {
    return ExerciseFetchResult(
      exercises: _exercises,
      fromCache: true,
      isOffline: false,
    );
  }

  @override
  Future<List<ExerciseModel>> getRelatedExercises(ExerciseModel exercise) async {
    return _exercises
        .where((e) => exercise.relatedIds.contains(e.id))
        .toList();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestHarness harness;
  late ExerciseController exerciseController;
  late List<ExerciseModel> sampleExercises;

  setUp(() async {
    harness = await TestHarness.create(online: true);
    await harness.authRepository.login(
      email: 'demo@rehabflow.app',
      password: 'rehab123',
    );

    sampleExercises = [
      buildExercise(
        id: '1',
        name: 'Seated Knee Extension',
        category: 'Strength',
        difficulty: 'Beginner',
        targetMuscle: 'Quadriceps',
      ),
      buildExercise(
        id: '2',
        name: 'Ankle Circles',
        category: 'Mobility',
        difficulty: 'Beginner',
        targetMuscle: 'Ankles',
      ),
      buildExercise(
        id: '3',
        name: 'Wall Push-Up',
        category: 'Strength',
        difficulty: 'Beginner',
        targetMuscle: 'Chest',
      ),
    ];

    final fakeRepo = _FakeExerciseRepository(sampleExercises);
    if (Get.isRegistered<ExerciseRepository>()) {
      await Get.delete<ExerciseRepository>(force: true);
    }
    Get.put<ExerciseRepository>(fakeRepo, permanent: true);

    // Rebuild favourites controller against the fake repo (no image prefetch).
    if (Get.isRegistered<FavoritesController>()) {
      await Get.delete<FavoritesController>(force: true);
    }
    Get.put(
      FavoritesController(
        favoritesRepository: harness.favoritesRepository,
        exerciseRepository: fakeRepo,
      ),
      permanent: true,
    );

    Get.put(AuthController(harness.authRepository), permanent: true);
    exerciseController = ExerciseController(fakeRepo, harness.networkInfo);
    if (Get.isRegistered<ExerciseController>()) {
      await Get.delete<ExerciseController>(force: true);
    }
    Get.put(exerciseController);
    await exerciseController.loadExercises();
  });

  tearDown(() async {
    await harness.dispose();
  });

  Future<void> pumpList(WidgetTester tester) async {
    final view = tester.view;
    view.physicalSize = const Size(390, 844);
    view.devicePixelRatio = 1.0;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: Responsive.designSize,
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return GetMaterialApp(
            home: const ExerciseListScreen(),
            getPages: AppRoutes.pages,
          );
        },
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  group('ExerciseListScreen', () {
    testWidgets('renders exercise cards after load', (tester) async {
      await mockNetworkImagesFor(() async {
        await pumpList(tester);

        expect(exerciseController.status.value, ExerciseListStatus.success);
        expect(find.textContaining('Hey,'), findsOneWidget);
        expect(find.byType(ExerciseCard), findsNWidgets(3));
        expect(find.text('Seated Knee Extension'), findsOneWidget);
      });
    });

    testWidgets('search filters the list live', (tester) async {
      await mockNetworkImagesFor(() async {
        await pumpList(tester);

        await tester.enterText(find.byType(TextField).first, 'knee');
        await tester.pump();

        expect(find.byType(ExerciseCard), findsOneWidget);
        expect(find.text('Seated Knee Extension'), findsOneWidget);
        expect(find.text('Ankle Circles'), findsNothing);

        await tester.enterText(
          find.byType(TextField).first,
          'no-such-exercise-xyz',
        );
        await tester.pump();

        expect(find.text('No matches'), findsOneWidget);
      });
    });
  });
}
