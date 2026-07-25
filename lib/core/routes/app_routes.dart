import 'package:get/get.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/exercises/presentation/screens/exercise_list_screen.dart';
import '../bindings/app_bindings.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String exercises = '/exercises';

  static final List<GetPage<dynamic>> pages = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: exercises,
      page: () => const ExerciseListScreen(),
      binding: AuthBinding(),
    ),
  ];
}
