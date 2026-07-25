import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../utils/responsive.dart';
import '../controllers/splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final markSize = 72.w;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.coralDeep,
              AppColors.coral,
              AppColors.coralSoft,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -40.h,
                right: -30.w,
                child: _GlowOrb(
                  size: 180.w,
                  color: Colors.white.withValues(alpha: 0.18),
                ),
              ),
              Positioned(
                bottom: 80.h,
                left: -50.w,
                child: _GlowOrb(
                  size: 220.w,
                  color: AppColors.ink.withValues(alpha: 0.12),
                ),
              ),
              Center(
                child: Padding(
                  padding: Responsive.pageInsets(context),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: markSize,
                        height: markSize,
                        decoration: BoxDecoration(
                          color: AppColors.textOnCoral.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(22.r),
                          border: Border.all(
                            color:
                                AppColors.textOnCoral.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Icon(
                          Icons.accessibility_new_rounded,
                          size: 38.sp,
                          color: AppColors.textOnCoral,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        AppConstants.appName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textOnCoral,
                          fontSize: 34.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.2,
                          height: 1,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        AppConstants.appTagline,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textOnCoral,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: 40.h),
                      SizedBox(
                        width: 28.w,
                        height: 28.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.8,
                          color: AppColors.textOnCoral,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
