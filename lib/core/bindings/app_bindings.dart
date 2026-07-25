import 'package:get/get.dart';

import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/controllers/splash_controller.dart';
import '../../features/exercises/data/repositories/exercise_repository.dart';
import '../../features/exercises/presentation/controllers/exercise_controller.dart';
import '../../features/exercises/presentation/controllers/exercise_detail_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Must use put (not lazyPut): SplashScreen never reads `controller`,
    // so lazy registration would never create SplashController / run bootstrap.
    Get.put(SplashController(Get.find<AuthRepository>()));
  }
}

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController(Get.find<AuthRepository>()), permanent: true);
    }
  }
}

class ExerciseBinding extends Bindings {
  @override
  void dependencies() {
    AuthBinding().dependencies();
    if (!Get.isRegistered<ExerciseController>()) {
      Get.put(ExerciseController(Get.find<ExerciseRepository>()));
    }
  }
}

class ExerciseDetailBinding extends Bindings {
  @override
  void dependencies() {
    if (Get.isRegistered<ExerciseDetailController>()) {
      Get.delete<ExerciseDetailController>(force: true);
    }
    Get.put(ExerciseDetailController(Get.find<ExerciseRepository>()));
  }
}
