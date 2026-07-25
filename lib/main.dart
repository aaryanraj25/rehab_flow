import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'core/constants/app_constants.dart';
import 'core/routes/app_routes.dart';
import 'core/storage/local_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/exercises/data/repositories/exercise_repository.dart';
import 'features/favorites/data/repositories/favorites_repository.dart';
import 'features/favorites/presentation/controllers/favorites_controller.dart';
import 'network/api_client.dart';
import 'utils/responsive.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenUtil.ensureScreenSize();
  await _registerCoreServices();
  runApp(const RehabFlowApp());
}

Future<void> _registerCoreServices() async {
  final storage = await LocalStorageService.init();
  final networkInfo = NetworkInfo();
  final apiClient = ApiClient();
  final AuthRepository authRepository = AuthRepositoryImpl(storage);
  final FavoritesRepository favoritesRepository =
      FavoritesRepositoryImpl(storage);
  final ExerciseRepository exerciseRepository = ExerciseRepositoryImpl(
    storage: storage,
    apiClient: apiClient,
    networkInfo: networkInfo,
  );

  Get.put(storage, permanent: true);
  Get.put(networkInfo, permanent: true);
  Get.put(apiClient, permanent: true);
  Get.put<AuthRepository>(authRepository, permanent: true);
  Get.put<ExerciseRepository>(exerciseRepository, permanent: true);
  Get.put<FavoritesRepository>(favoritesRepository, permanent: true);
  Get.put(
    FavoritesController(
      favoritesRepository: favoritesRepository,
      exerciseRepository: exerciseRepository,
    ),
    permanent: true,
  );
}

class RehabFlowApp extends StatelessWidget {
  const RehabFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Responsive.designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          initialRoute: AppRoutes.splash,
          getPages: AppRoutes.pages,
        );
      },
    );
  }
}
