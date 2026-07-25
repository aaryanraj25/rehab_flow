import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/constants/app_constants.dart';

/// Layout breakpoints + ScreenUtil sizing.
///
/// Best practice: ScreenUtil scales design tokens (`.w` / `.h` / `.sp` / `.r`).
/// Breakpoints decide structure (stack vs split, grid columns, max widths).
/// On tablets prefer logical px for chrome so `.w` does not inflate UI.
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

  /// Wide canvas — brand + form side-by-side (tablet landscape or large portrait).
  static bool useWideLayout(BuildContext context) {
    if (!isTablet(context)) return false;
    final width = sizeOf(context).width;
    return isLandscape(context) || width >= wideBreakpoint;
  }

  static T value<T>(
    BuildContext context, {
    required T phone,
    required T tablet,
  }) {
    return isTablet(context) ? tablet : phone;
  }

  /// Denser grids on tablet so cards stay compact.
  static int gridCrossAxisCount(BuildContext context) {
    final width = sizeOf(context).width;
    if (width >= 1100) return 5;
    if (width >= 900) return 4;
    if (width >= 700) return 4;
    if (width >= 500) return 2;
    return 1;
  }

  static double horizontalPadding(BuildContext context) {
    return isTablet(context) ? 24 : 20.w;
  }

  /// Cap readable width so detail/list chrome stays phone-dense on iPad.
  static double maxContentWidth(BuildContext context) {
    if (!isTablet(context)) return double.infinity;
    final width = sizeOf(context).width;
    if (width >= 1100) return 900;
    if (width >= wideBreakpoint) return 820;
    return 700;
  }

  /// Login form width in logical px (avoid `.w` overscaling on iPad).
  static double authFormMaxWidth(BuildContext context) {
    if (useWideLayout(context)) return 480;
    if (isTablet(context)) return 520;
    return 400.w.clamp(320.0, 400.0);
  }

  static double buttonHeight() => 46;

  /// Slightly shorter cells → more rows visible with more columns.
  static double exerciseGridAspectRatio(BuildContext context) {
    final columns = gridCrossAxisCount(context);
    if (columns >= 5) return 0.78;
    if (columns >= 4) return 0.8;
    if (columns >= 3) return 0.82;
    return 0.85;
  }

  static EdgeInsets pageInsets(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: horizontalPadding(context),
      vertical: isTablet(context) ? 20 : 16.h,
    );
  }

  /// ScreenUtil `.sp`/`.w` inflate on iPad — use this for shared chrome sizes.
  static double s(BuildContext context, double phoneScaled, double tabletLogical) {
    return isTablet(context) ? tabletLogical : phoneScaled;
  }
}
