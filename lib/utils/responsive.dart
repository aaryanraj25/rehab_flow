import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class Responsive {
  Responsive._();

  static bool isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).shortestSide >= 600;
  }

  static int gridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1100) return 4;
    if (width >= 700) return 3;
    if (width >= 500) return 2;
    return 1;
  }

  static double horizontalPadding(BuildContext context) {
    return isTablet(context) ? 32 : 16;
  }

  static double maxContentWidth(BuildContext context) {
    return isTablet(context) ? 1000 : double.infinity;
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
