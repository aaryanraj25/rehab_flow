import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/storage/local_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'network/api_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _registerCoreServices();
  runApp(const RehabFlowApp());
}

Future<void> _registerCoreServices() async {
  final prefs = await SharedPreferences.getInstance();
  final storage = LocalStorageService(prefs);
  Get.put(storage, permanent: true);
  Get.put(NetworkInfo(), permanent: true);
  Get.put(ApiClient(), permanent: true);
  Get.put(AuthRepository(storage), permanent: true);
}

class RehabFlowApp extends StatelessWidget {
  const RehabFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const ScaffoldHome(),
    );
  }
}
