import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// [INFO]
/// Constant for typography to be used in the app with following design system
class BaseTypography {
  static TextStyle headlineLarge = TextStyle(
    fontSize: 36.sp,
    fontWeight: FontWeight.bold,
  );

  static TextStyle headlineSmall = TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w400,
  );

  static TextStyle titleMedium = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
  );
  static TextStyle bodyMedium = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
  );

  static TextStyle displayLarge = TextStyle(
    fontSize: 28.sp,
    fontWeight: FontWeight.w400,
  );
  static TextStyle bodySmall = TextStyle(
    fontSize: 10.sp,
    fontWeight: FontWeight.w400,
  );
  static TextStyle labelSmall = TextStyle(
    fontSize: 6.sp,
    fontWeight: FontWeight.w400,
  );
}
