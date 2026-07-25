import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';

/// Layout breakpoints + ScreenUtil sizing.
///
/// Best practice: ScreenUtil scales design tokens (`.w` / `.h` / `.sp` / `.r`).
/// Breakpoints decide structure (stack vs split, grid columns, max widths).
class Responsive {
  Responsive._();

  static const double tabletBreakpoint = 600;
  static const double wideBreakpoint = 840;

  static Size get designSize => const Size(
        AppConstants.designWidth,
        AppConstants.designHeight,
      );

  static Size sizeOf(BuildContext context) => MediaQuery.sizeOf(context);

  static bool isTablet(BuildContext context) {
    return sizeOf(context).shortestSide >= tabletBreakpoint;
  }

  static bool isPhone(BuildContext context) => !isTablet(context);

  static bool isLandscape(BuildContext context) {
    return MediaQuery.orientationOf(context) == Orientation.landscape;
  }

  /// Wide tablet canvas — brand + form side-by-side.
  static bool useWideLayout(BuildContext context) {
    return isTablet(context) && sizeOf(context).width >= wideBreakpoint;
  }

  static T value<T>(
    BuildContext context, {
    required T phone,
    required T tablet,
  }) {
    return isTablet(context) ? tablet : phone;
  }

  static int gridCrossAxisCount(BuildContext context) {
    final width = sizeOf(context).width;
    if (width >= 1100) return 4;
    if (width >= 700) return 3;
    if (width >= 500) return 2;
    return 1;
  }

  static double horizontalPadding(BuildContext context) {
    return isTablet(context) ? 40.w : 20.w;
  }

  static double maxContentWidth(BuildContext context) {
    return isTablet(context) ? 1000.w : double.infinity;
  }

  static double authFormMaxWidth(BuildContext context) {
    return isTablet(context) ? 440.w : 400.w;
  }

  static double buttonHeight() => 46.h;

  static EdgeInsets pageInsets(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: horizontalPadding(context),
      vertical: isTablet(context) ? 28.h : 16.h,
    );
  }
}

class DifficultyColors {
  DifficultyColors._();

  static Color forLevel(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return AppColors.success;
      case 'intermediate':
        return AppColors.warning;
      case 'advanced':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}
