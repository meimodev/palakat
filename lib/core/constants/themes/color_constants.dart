import 'package:flutter/material.dart';

/// [INFO]
/// Constant for colors to be used in the app with following the design system
class BaseColor {
  static const int _tealPrimaryValue = 0xFF009688;
  static const int _greenPrimaryValue = 0xFF4CAF50;
  static const int _yellowPrimaryValue = 0xFFFBC02D;
  static const int _bluePrimaryValue = 0xFF2196F3;
  static const int _redPrimaryValue = 0xFFFF4032;
  static const int _neutralPrimaryValue = 0xFFB8B8B8;

  static const Color primary1 = Color(0xFFF0FBF8);
  static const Color primary2 = Color(0xFFDEF5EE);
  static const Color primary3 = Color(0xFF000000);
  static const Color primary4 = Color(0xFF28A745);
  static const Color primary5 = Color(0xFF19692C);

  static const Color cardBackground1 = Color(0xFFEBEBEB);
  static const Color cardBackground2 = Color(0xFFE9E9E9);
  static const Color primaryText = Color(0xFF000000);
  static const Color secondaryText = Color(0xFF929292);
  static const Color disabled = Color(0xFFD9D9D9);

  static Color  primaryLight = primary3.withValues(alpha: .5);

  static const MaterialColor neutral = MaterialColor(
    _neutralPrimaryValue,
    <int, Color>{
      0: Color(0xFFFFFFFF),
      10: Color(0xFFF7F7F7),
      20: Color(0xFFEDEDED),
      30: Color(0xFFE0E0E0),
      40: Color(0xFFCDCDCD),
      50: Color(_neutralPrimaryValue),
      60: Color(0xFF878787),
      70: Color(0xFF606060),
      80: Color(0xFF383838),
      90: Color(0xFF151515),
    },
  );

  static const MaterialColor red = MaterialColor(
    _redPrimaryValue,
    <int, Color>{
      50: Color(0xFFFFF5F5),
      100: Color(0xFFFFD1CE),
      200: Color(0xFFFFADA7),
      300: Color(0xFFFF8980),
      400: Color(0xFFFF6459),
      500: Color(_redPrimaryValue),
      600: Color(0xFFD9362B),
      700: Color(0xFFB32D23),
      800: Color(0xFF8C231C),
      900: Color(0xFF661A14),
    },
  );

  static const MaterialColor blue = MaterialColor(
    _bluePrimaryValue,
    <int, Color>{
      50: Color(0xFFF4FAFE),
      100: Color(0xFFCAE6FC),
      200: Color(0xFFA0D2FA),
      300: Color(0xFF75BEF8),
      400: Color(0xFF4BAAF5),
      500: Color(_bluePrimaryValue),
      600: Color(0xFF1C80CF),
      700: Color(0xFF1769AA),
      800: Color(0xFF125386),
      900: Color(0xFF0D3C61),
    },
  );

  static const MaterialColor yellow = MaterialColor(
    _yellowPrimaryValue,
    <int, Color>{
      50: Color(0xFFFFFCF5),
      100: Color(0xFFFEF0CD),
      200: Color(0xFFFDE4A5),
      300: Color(0xFFFDD87D),
      400: Color(0xFFFCCC55),
      500: Color(_yellowPrimaryValue),
      600: Color(0xFFD5A326),
      700: Color(0xFFB08620),
      800: Color(0xFF8A6A19),
      900: Color(0xFF644D12),
    },
  );

  static const MaterialColor green = MaterialColor(
    _greenPrimaryValue,
    <int, Color>{
      50: Color(0xFFF6FBF6),
      100: Color(0xFFD4ECD5),
      200: Color(0xFFB2DDB4),
      300: Color(0xFF90CD93),
      400: Color(0xFF6EBE71),
      500: Color(_greenPrimaryValue),
      600: Color(0xFF419544),
      700: Color(0xFF357B38),
      800: Color(0xFF2A602C),
      900: Color(0xFF1E4620),
    },
  );

  static const MaterialColor teal = MaterialColor(
    _tealPrimaryValue,
    <int, Color>{
      50: Color(0xFFF2FAF9),
      100: Color(0xFFC2E6E2),
      200: Color(0xFF91D2CC),
      300: Color(0xFF61BEB5),
      400: Color(0xFF30AA9F),
      500: Color(_tealPrimaryValue),
      600: Color(0xFF008074),
      700: Color(0xFF00695F),
      800: Color(0xFF00534B),
      900: Color(0xFF003C36),
    },
  );

  static const Color shadow = Color(0xFF18280F);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  static const Color error = Color(_redPrimaryValue);
  static const Color info = Color(_bluePrimaryValue);
  static const Color warning = Color(_yellowPrimaryValue);
  static const Color success = Color(_greenPrimaryValue);
}
