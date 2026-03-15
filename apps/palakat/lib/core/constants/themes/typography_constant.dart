import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// [INFO]
/// Constant for typography to be used in the app with following design system
class BaseTypography {
  static TextStyle _style({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontSize: fontSize.sp,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static final TextStyle displayLarge = _style(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.12,
    letterSpacing: -0.3,
  );

  static final TextStyle headlineLarge = _style(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.4,
  );

  static final TextStyle headlineSmall = _style(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.2,
  );

  static final TextStyle titleLarge = _style(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  static final TextStyle titleMedium = _style(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static final TextStyle bodyMedium = _style(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  static final TextStyle bodySmall = _style(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static final TextStyle labelLarge = _style(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0.1,
  );

  static final TextStyle labelMedium = _style(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.1,
  );

  static final TextStyle labelSmall = _style(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.1,
  );

  static final TextTheme textTheme = TextTheme(
    displayLarge: displayLarge,
    headlineLarge: headlineLarge,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}
