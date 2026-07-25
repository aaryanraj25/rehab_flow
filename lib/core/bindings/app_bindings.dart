import 'package:get/get.dart';

import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/controllers/splash_controller.dart';

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
