import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const String fontFamily = 'OpenSans';
final ThemeData appThemeData = ThemeData.light().copyWith(
  scaffoldBackgroundColor: Palette.scaffold,
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14.sp,
      fontWeight: FontWeight.w300,
      color: Palette.textPrimary,
    ),
    counterStyle: TextStyle(
      fontFamily: fontFamily,
      fontSize: 9.sp,
      fontWeight: FontWeight.w400,
      color: Palette.textPrimary,
    ),
    border: const UnderlineInputBorder(
      borderSide: BorderSide(
        color: Palette.primary,
      ),
    ),
    errorBorder: const UnderlineInputBorder(
      borderSide: BorderSide(
        color: Colors.red,
      ),
    ),
  ),
  textTheme: TextTheme(
    headline1: TextStyle(
      fontFamily: fontFamily,
      fontSize: 27.sp,
      fontWeight: FontWeight.w400,
      color: Palette.textPrimary,
    ),
    headline2: TextStyle(
      fontFamily: fontFamily,
      fontSize: 27.sp,
      fontWeight: FontWeight.w500,
      color: Palette.textPrimary,
    ),
    headline3: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16.sp,
      fontWeight: FontWeight.w400,
      color: Palette.textPrimary,
    ),
    headline4: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16.sp,
      fontWeight: FontWeight.w400,
      color: Palette.textPrimary,
    ),
    headline5: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
      color: Palette.textPrimary,
    ),
    headline6: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
      color: Palette.textPrimary,
    ),
    bodyText1: TextStyle(
      fontFamily: fontFamily,
      fontSize: 10.sp,
      fontWeight: FontWeight.w500,
      color: Palette.textPrimary,
    ),
    bodyText2: TextStyle(
      fontFamily: fontFamily,
      fontSize: 10.sp,
      fontWeight: FontWeight.w500,
      color: Palette.textPrimary,
    ),
    caption: TextStyle(
      fontFamily: fontFamily,
      fontSize: 9.sp,
      fontWeight: FontWeight.w400,
      color: Colors.grey.shade600,
    ),
  ),
);

class Palette {
  static const Color primary = Color(0xFF1E1F1C);
  static const Color accent = Color(0xFFFBFAF7);

  static const Color cardForeground = Color(0xFFEBEAEB);
  static const Color cardBackground = Color(0xFFEAE9EA);
  static const Color scaffold = Color(0xFFF9F6F5);

  static const Color positive = Color(0xFF38C672);
  static const Color negative = Color(0xFFC63849);

  //textColor
  static const Color textPrimary = primary;
  static const Color textAccent = accent;
}

class Insets {
  static const double small = 12.0;
  static const double medium = 24.0;
  static const double large = 39.0;
}

class Radius {
  static const double small = 12.0;
}