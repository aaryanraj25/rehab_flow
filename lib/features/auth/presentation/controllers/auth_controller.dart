import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../../core/routes/app_routes.dart';

class AuthController extends GetxController {
  AuthController(this._authRepository);

  final AuthRepository _authRepository;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxnString errorMessage = RxnString();

  bool get isAuthenticated => currentUser.value != null;

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _authRepository.getCurrentSession();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() async {
    errorMessage.value = null;
    if (!(formKey.currentState?.validate() ?? false)) return;

    isLoading.value = true;
    try {
      final user = await _authRepository.login(
        email: emailController.text,
        password: passwordController.text,
      );
      currentUser.value = user;
      Get.offAllNamed(AppRoutes.exercises);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    currentUser.value = null;
    emailController.clear();
    passwordController.clear();
    Get.offAllNamed(AppRoutes.login);
  }
}
