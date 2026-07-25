import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../utils/responsive.dart';

/// Temporary dashboard shell until Phase 6 exercise cards land.
class ExerciseListScreen extends GetView<AuthController> {
  const ExerciseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final markSize = 64.w;

    return Scaffold(
      backgroundColor: AppColors.coral,
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textOnCoral,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: IconButton(
              tooltip: 'Sign out',
              onPressed: controller.logout,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.textOnCoral.withValues(alpha: 0.16),
              ),
              icon: const Icon(Icons.logout_rounded),
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.coral, AppColors.coralSoft, AppColors.background],
            stops: [0.0, 0.35, 1.0],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Responsive.value(context, phone: 400.w, tablet: 520.w),
            ),
            child: Obx(
              () => Container(
                margin: EdgeInsets.all(Responsive.horizontalPadding(context)),
                padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.ink.withValues(alpha: 0.16),
                      blurRadius: 28.r,
                      offset: Offset(0, 14.h),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: markSize,
                      height: markSize,
                      decoration: BoxDecoration(
                        color: AppColors.coral.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Icon(
                        Icons.fitness_center_rounded,
                        size: 30.sp,
                        color: AppColors.coralDeep,
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Text(
                      'Hey, ${controller.currentUser.value?.displayName ?? 'Athlete'}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.6,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Your exercise dashboard lands in the next phases — stay tuned.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
