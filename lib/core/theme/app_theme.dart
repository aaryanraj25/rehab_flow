import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF0D7377);
  static const Color primaryDark = Color(0xFF095456);
  static const Color secondary = Color(0xFF14919B);
  static const Color accent = Color(0xFF32E0C4);
  static const Color background = Color(0xFFF5F8F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A2B2B);
  static const Color textSecondary = Color(0xFF5A6F6F);
  static const Color border = Color(0xFFD7E3E3);
  static const Color error = Color(0xFFC62828);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Temporary placeholder home used until feature screens are wired (Phase 4+).
class ScaffoldHome extends StatelessWidget {
  const ScaffoldHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: const Center(
        child: Text(
          AppConstants.appTagline,
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
