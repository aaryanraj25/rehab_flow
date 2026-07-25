import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'core/constants/app_constants.dart';
import 'core/di/service_locator.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'utils/responsive.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenUtil.ensureScreenSize();
  await ServiceLocator.registerCore();
  runApp(const RehabFlowApp());
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
