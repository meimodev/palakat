import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTypography {
  AppTypography._();

  static TextTheme buildTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 56.sp,
        fontWeight: FontWeight.w700,
        height: 1.05,
        letterSpacing: -1.2,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: 44.sp,
        fontWeight: FontWeight.w700,
        height: 1.08,
        letterSpacing: -0.9,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontSize: 36.sp,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -0.6,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 32.sp,
        fontWeight: FontWeight.w600,
        height: 1.12,
        letterSpacing: -0.5,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 28.sp,
        fontWeight: FontWeight.w600,
        height: 1.16,
        letterSpacing: -0.35,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: -0.2,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 20.sp,
        fontWeight: FontWeight.w500,
        height: 1.3,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 18.sp,
        fontWeight: FontWeight.w500,
        height: 1.32,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        height: 1.34,
      ),

      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        height: 1.55,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        height: 1.55,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),

      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: 0.2,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: 0.3,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 11.sp,
        fontWeight: FontWeight.w700,
        height: 1.18,
        letterSpacing: 0.35,
      ),
    );
  }
}
