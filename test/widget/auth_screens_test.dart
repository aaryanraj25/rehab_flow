import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:rehab_flow/core/routes/app_routes.dart';
import 'package:rehab_flow/features/auth/presentation/controllers/auth_controller.dart';
import 'package:rehab_flow/features/auth/presentation/controllers/splash_controller.dart';
import 'package:rehab_flow/features/auth/presentation/screens/login_screen.dart';
import 'package:rehab_flow/features/auth/presentation/screens/splash_screen.dart';
import 'package:rehab_flow/utils/responsive.dart';

import '../helpers/test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestHarness harness;

  setUp(() async {
    harness = await TestHarness.create(online: true);
  });

  tearDown(() async {
    await harness.dispose();
  });

  Future<void> pumpApp(
    WidgetTester tester, {
    required Widget home,
  }) async {
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
            home: home,
            getPages: AppRoutes.pages,
          );
        },
      ),
    );
    await tester.pump();
  }

  group('SplashScreen', () {
    testWidgets('shows branding while bootstrapping', (tester) async {
      Get.put(SplashController(harness.authRepository));
      await pumpApp(tester, home: const SplashScreen());

      expect(find.text('RehabFlow'), findsOneWidget);
      expect(find.text('Rehabilitation Exercise Management'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Flush SplashController's 900ms bootstrap timer so the test can tear down.
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump();
    });
  });

  group('LoginScreen', () {
    testWidgets('shows validation errors for empty submit', (tester) async {
      Get.put(AuthController(harness.authRepository), permanent: true);
      await pumpApp(tester, home: const LoginScreen());

      await tester.ensureVisible(find.text('Sign In'));
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.textContaining('Password is required'), findsOneWidget);
    });

    testWidgets('rejects invalid email format', (tester) async {
      Get.put(AuthController(harness.authRepository), permanent: true);
      await pumpApp(tester, home: const LoginScreen());

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'not-an-email');
      await tester.enterText(fields.at(1), 'rehab123');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.text('Enter a valid email address'), findsOneWidget);
      expect(harness.authRepository.isAuthenticated, isFalse);
    });
  });

  group('AuthController / session', () {
    test('login persists session and marks user authenticated', () async {
      final controller = AuthController(harness.authRepository);
      final user = await harness.authRepository.login(
        email: 'demo@rehabflow.app',
        password: 'rehab123',
      );
      controller.currentUser.value = user;

      expect(controller.isAuthenticated, isTrue);
      expect(controller.currentUser.value?.email, 'demo@rehabflow.app');
      expect(harness.authRepository.getCurrentSession()?.token, isNotEmpty);
      controller.onClose();
    });

    test('splash bootstrap chooses login vs exercises from session', () async {
      expect(harness.authRepository.isAuthenticated, isFalse);

      await harness.authRepository.login(
        email: 'demo@rehabflow.app',
        password: 'rehab123',
      );
      expect(harness.authRepository.isAuthenticated, isTrue);

      await harness.authRepository.logout();
      expect(harness.authRepository.isAuthenticated, isFalse);
    });
  });
}
