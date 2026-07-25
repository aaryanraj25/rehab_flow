import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rehab_flow/core/constants/app_constants.dart';
import 'package:rehab_flow/core/routes/app_routes.dart';
import 'package:rehab_flow/core/storage/local_storage_service.dart';
import 'package:rehab_flow/features/auth/data/repositories/auth_repository.dart';
import 'package:rehab_flow/features/auth/presentation/controllers/auth_controller.dart';
import 'package:rehab_flow/features/auth/presentation/screens/login_screen.dart';
import 'package:rehab_flow/features/exercises/data/models/exercise_model.dart';
import 'package:rehab_flow/features/exercises/data/repositories/exercise_repository.dart';
import 'package:rehab_flow/main.dart';
import 'package:rehab_flow/network/api_client.dart';
import 'package:rehab_flow/utils/responsive.dart';
import 'package:rehab_flow/utils/validators.dart';

class _OfflineNetworkInfo extends NetworkInfo {
  @override
  Future<bool> get isConnected async => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = LocalStorageService(prefs);
    final networkInfo = _OfflineNetworkInfo();
    final apiClient = ApiClient();
    Get.put(storage, permanent: true);
    Get.put<NetworkInfo>(networkInfo, permanent: true);
    Get.put(apiClient, permanent: true);
    Get.put(AuthRepository(storage), permanent: true);
    Get.put(
      ExerciseRepository(
        storage: storage,
        apiClient: apiClient,
        networkInfo: networkInfo,
      ),
      permanent: true,
    );
  });

  tearDown(Get.reset);

  testWidgets('splash shows RehabFlow branding', (tester) async {
    await tester.pumpWidget(const RehabFlowApp());
    expect(find.text('RehabFlow'), findsOneWidget);
    expect(find.text('Rehabilitation Exercise Management'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('login screen validates email and password', (tester) async {
    Get.put(AuthController(Get.find<AuthRepository>()), permanent: true);

    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: Responsive.designSize,
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return GetMaterialApp(
            home: const LoginScreen(),
            getPages: AppRoutes.pages,
          );
        },
      ),
    );

    await tester.ensureVisible(find.text('Sign In'));
    await tester.tap(find.text('Sign In'));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.textContaining('Password is required'), findsOneWidget);
  });

  test('email validator rejects invalid addresses', () {
    expect(Validators.email(null), isNotNull);
    expect(Validators.email('bad'), isNotNull);
    expect(Validators.email('demo@rehabflow.app'), isNull);
  });

  test('password validator enforces minimum length', () {
    expect(Validators.password('123'), isNotNull);
    expect(Validators.password('rehab123'), isNull);
  });

  test('AuthRepository persists and clears mock session', () async {
    final auth = Get.find<AuthRepository>();
    expect(auth.isAuthenticated, isFalse);

    final user = await auth.login(
      email: 'demo@rehabflow.app',
      password: 'rehab123',
    );
    expect(user.email, 'demo@rehabflow.app');
    expect(auth.isAuthenticated, isTrue);
    expect(auth.getCurrentSession()?.token, isNotEmpty);

    await auth.logout();
    expect(auth.isAuthenticated, isFalse);
  });

  test('ExerciseModel parses json payload', () {
    final exercise = ExerciseModel.fromJson({
      'id': 1,
      'name': 'Mini Squats',
      'category': 'Strength',
      'difficulty': 'Intermediate',
      'targetMuscle': 'Quadriceps',
      'description': 'desc',
      'instructions': 'steps',
      'equipment': 'None',
      'relatedIds': ['1', '2'],
    });

    expect(exercise.id, '1');
    expect(exercise.name, 'Mini Squats');
    expect(exercise.relatedIds, ['1', '2']);
  });

  test('ExerciseRepository loads asset data and caches list offline', () async {
    final repo = Get.find<ExerciseRepository>();
    final storage = Get.find<LocalStorageService>();

    final result = await repo.getExercises();
    expect(result.exercises, isNotEmpty);
    expect(result.isOffline, isTrue);
    expect(result.fromCache, isTrue);
    expect(result.exercises.first.name, isNotEmpty);

    final cached = storage.getJson(AppConstants.storageExercisesKey);
    expect(cached, isA<List>());
    expect((cached as List).length, result.exercises.length);

    final detail = await repo.getExerciseById(result.exercises.first.id);
    expect(detail?.id, result.exercises.first.id);
  });
}
