import 'package:get/get.dart';

import '../../data/repositories/auth_repository.dart';
import '../../../../core/routes/app_routes.dart';

class SplashController extends GetxController {
  SplashController(this._authRepository);

  final AuthRepository _authRepository;

  @override
  void onReady() {
    super.onReady();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (_authRepository.isAuthenticated) {
      Get.offAllNamed(AppRoutes.exercises);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
