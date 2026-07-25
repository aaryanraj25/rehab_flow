import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:rehab_flow/core/constants/app_constants.dart';
import 'package:rehab_flow/core/routes/app_routes.dart';
import 'package:rehab_flow/core/theme/app_theme.dart';
import 'package:rehab_flow/features/auth/presentation/controllers/auth_controller.dart';
import 'package:rehab_flow/features/exercises/data/models/exercise_model.dart';
import 'package:rehab_flow/features/exercises/data/repositories/exercise_repository.dart';
import 'package:rehab_flow/features/exercises/presentation/controllers/exercise_controller.dart';
import 'package:rehab_flow/features/exercises/presentation/controllers/exercise_detail_controller.dart';
import 'package:rehab_flow/features/exercises/presentation/screens/exercise_detail_screen.dart';
import 'package:rehab_flow/features/exercises/presentation/screens/exercise_list_screen.dart';
import 'package:rehab_flow/features/exercises/presentation/widgets/exercise_card.dart';
import 'package:rehab_flow/features/favorites/presentation/controllers/favorites_controller.dart';
import 'package:rehab_flow/network/api_client.dart';
import 'package:rehab_flow/utils/responsive.dart';

import '../helpers/test_harness.dart';

/// Host multi-screen flows for `flutter test` (no device / Xcode build).
///
/// Notes:
/// - Splash → login GetX transitions are covered in widget auth tests.
/// - `FavoritesScreen` is covered via controller resolution here; pumping that
///   screen hangs under the widget tester (RefreshIndicator + card heroes).

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
    return ExerciseFetchResult(
      exercises: exercises,
      fromCache: true,
      isOffline: false,
    );
  }

  @override
  Future<List<ExerciseModel>> getRelatedExercises(ExerciseModel exercise) async {
    return exercises.where((e) => exercise.relatedIds.contains(e.id)).toList();
  }
}

class _SeededDetailController extends ExerciseDetailController {
  _SeededDetailController(
    ExerciseRepository repository,
    NetworkInfo networkInfo,
    this.seed, {
    this.relatedExercises = const [],
  }) : super(repository, networkInfo);

  final ExerciseModel seed;
  final List<ExerciseModel> relatedExercises;

  @override
  void onInit() {
    exerciseId = seed.id;
    exercise.value = seed;
    related.assignAll(relatedExercises);
    status.value = ExerciseDetailStatus.success;
    isOffline.value = false;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestHarness harness;
  late _FakeExerciseRepository fakeRepo;
  late ExerciseController exerciseController;

  setUp(() async {
    harness = await TestHarness.create(online: true);
    await harness.authRepository.login(
      email: 'demo@rehabflow.app',
      password: 'rehab123',
    );

    fakeRepo = _FakeExerciseRepository([
      buildExercise(
        id: '1',
        name: 'Seated Knee Extension',
        relatedIds: const ['2'],
      ),
      buildExercise(
        id: '2',
        name: 'Ankle Circles',
        category: 'Mobility',
        targetMuscle: 'Ankles',
      ),
      buildExercise(
        id: '3',
        name: 'Wall Push-Up',
        targetMuscle: 'Chest',
      ),
    ]);

    if (Get.isRegistered<ExerciseRepository>()) {
      await Get.delete<ExerciseRepository>(force: true);
    }
    Get.put<ExerciseRepository>(fakeRepo, permanent: true);

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

    if (Get.isRegistered<ExerciseController>()) {
      await Get.delete<ExerciseController>(force: true);
    }
    exerciseController = ExerciseController(fakeRepo, harness.networkInfo);
    Get.put(exerciseController);
    await exerciseController.loadExercises();
  });

  tearDown(() async {
    await harness.dispose();
  });

  Future<void> pumpHome(WidgetTester tester, Widget home) async {
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
            title: AppConstants.appName,
            theme: AppTheme.light,
            home: home,
            getPages: AppRoutes.pages,
          );
        },
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('browse list search filters cards live', (tester) async {
    await mockNetworkImagesFor(() async {
      await pumpHome(tester, const ExerciseListScreen());

      expect(find.byType(ExerciseCard), findsNWidgets(3));

      await tester.enterText(find.byType(TextField).first, 'knee');
      await tester.pump();

      expect(find.byType(ExerciseCard), findsOneWidget);
      expect(find.text('Seated Knee Extension'), findsOneWidget);
      expect(find.text('Ankle Circles'), findsNothing);
    });
  });

  test('favourite toggle resolves exercise into favourites list', () async {
    final favorites = Get.find<FavoritesController>();
    expect(favorites.favoriteExercises, isEmpty);

    await favorites.toggleFavorite('1');

    expect(favorites.isFavorite('1'), isTrue);
    expect(favorites.favoriteExercises, hasLength(1));
    expect(favorites.favoriteExercises.first.name, 'Seated Knee Extension');
    expect(harness.favoritesRepository.isFavorite('1'), isTrue);
  });

  testWidgets('detail screen shows description instructions and equipment',
      (tester) async {
    await mockNetworkImagesFor(() async {
      final seed = fakeRepo.exercises.first;
      final related = await fakeRepo.getRelatedExercises(seed);

      Get.put<ExerciseDetailController>(
        _SeededDetailController(
          fakeRepo,
          Get.find<NetworkInfo>(),
          seed,
          relatedExercises: related,
        ),
      );

      await pumpHome(tester, const ExerciseDetailScreen());

      expect(find.text('Seated Knee Extension'), findsWidgets);
      expect(find.text('About this move'), findsOneWidget);
      expect(find.text('How to perform'), findsOneWidget);
      expect(find.text('What you’ll need'), findsOneWidget);
    });
  });
}
