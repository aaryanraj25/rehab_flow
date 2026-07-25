import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Accent colors for Beginner / Intermediate / Advanced badges.
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
