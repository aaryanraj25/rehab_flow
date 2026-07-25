import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Coral-forward palette — coral replaces classic white surfaces.
class AppColors {
  AppColors._();

  /// Brand coral (user swatch) — used where apps typically use white.
  static const Color coral = Color(0xFFEF7656);
  static const Color coralDeep = Color(0xFFE85A36);
  static const Color coralSoft = Color(0xFFF6A089);
  static const Color coralGlow = Color(0xFFFFB59A);

  static const Color primary = coral;
  static const Color primaryDark = coralDeep;
  static const Color secondary = Color(0xFF2B1A16);
  static const Color accent = coralGlow;

  /// Warm wash behind coral panels (not flat white).
  static const Color background = Color(0xFFFFE8E0);
  static const Color surface = coral;
  static const Color surfaceElevated = Color(0xFFFFF7F3);
  static const Color ink = Color(0xFF1C1210);
  static const Color textPrimary = Color(0xFF1C1210);
  static const Color textSecondary = Color(0xFF6B433A);
  static const Color textOnCoral = Color(0xFFFFF7F3);
  static const Color border = Color(0xFFE8B8A8);
  static const Color error = Color(0xFFB42318);
  static const Color success = Color(0xFF1B7A4E);
  static const Color warning = Color(0xFFC2410C);
  static const Color favorite = Color(0xFFDC2626);
}

class AppTheme {
  AppTheme._();

  /// Built inside [ScreenUtilInit] so `.sp` / `.r` / `.h` are available.
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.coral,
        onPrimary: AppColors.textOnCoral,
        secondary: AppColors.secondary,
        onSecondary: AppColors.textOnCoral,
        surface: AppColors.surfaceElevated,
        onSurface: AppColors.ink,
        error: AppColors.error,
        onError: Colors.white,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.coral,
        foregroundColor: AppColors.textOnCoral,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textOnCoral,
          fontSize: 22.sp,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: AppColors.textOnCoral),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevated,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        hintStyle: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.7),
          fontSize: 14.sp,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: AppColors.ink, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: AppColors.error, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.textOnCoral,
          disabledBackgroundColor: AppColors.ink.withValues(alpha: 0.45),
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: Size.fromHeight(46.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          textStyle: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.15,
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        selectedColor: AppColors.coral.withValues(alpha: 0.22),
        checkmarkColor: AppColors.coralDeep,
        backgroundColor: AppColors.surfaceElevated,
        labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
        side: const BorderSide(color: AppColors.border),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 26.sp,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.6,
          color: AppColors.ink,
        ),
        titleLarge: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
        ),
        titleMedium: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        bodyLarge: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
          height: 1.55,
          color: AppColors.ink,
        ),
        bodyMedium: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          height: 1.45,
          color: AppColors.ink,
        ),
        bodySmall: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceElevated,
        elevation: 1.5,
        shadowColor: AppColors.ink.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: TextStyle(
          color: AppColors.textOnCoral,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }
}
