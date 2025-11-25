import 'package:flutter/material.dart';

/// [INFO]
/// Centralized color definitions for the Palakat app.
/// All colors derive from or complement the primary teal color.
/// This implements a monochromatic color system for visual consistency.
class BaseColor {
  // ============================================
  // PRIMARY COLOR - Teal (Main Brand Color)
  // ============================================
  static const int _tealPrimaryValue = 0xFF009688;

  /// Primary teal MaterialColor with full 50-900 shade scale
  /// Use for accent and interactive elements
  static const MaterialColor primary =
      MaterialColor(_tealPrimaryValue, <int, Color>{
        50: Color(0xFFE0F2F1),
        100: Color(0xFFB2DFDB),
        200: Color(0xFF80CBC4),
        300: Color(0xFF4DB6AC),
        400: Color(0xFF26A69A),
        500: Color(_tealPrimaryValue),
        600: Color(0xFF00897B),
        700: Color(0xFF00796B),
        800: Color(0xFF00695C),
        900: Color(0xFF004D40),
      });

  // Legacy teal alias for backward compatibility
  static const MaterialColor teal = primary;

  // ============================================
  // NEUTRAL COLORS (with teal undertone)
  // ============================================
  static const int _neutralPrimaryValue = 0xFF9E9E9E;

  /// Neutral palette for surfaces and backgrounds
  static const MaterialColor neutral = MaterialColor(
    _neutralPrimaryValue,
    <int, Color>{
      50: Color(0xFFFAFAFA), // Page background
      100: Color(0xFFF5F5F5), // Card background
      200: Color(0xFFEEEEEE), // Dividers
      300: Color(0xFFE0E0E0), // Borders
      400: Color(0xFFBDBDBD), // Disabled text
      500: Color(_neutralPrimaryValue), // Placeholder text
      600: Color(0xFF757575), // Secondary text
      700: Color(0xFF616161), // Body text
      800: Color(0xFF424242), // Headings
      900: Color(0xFF212121), // Primary text
    },
  );

  // Individual neutral color constants for easy access
  static const Color neutral0 = Color(0xFFFFFFFF); // White
  static const Color neutral10 = Color(0xFFFAFAFA); // Very light gray (50)
  static const Color neutral20 = Color(0xFFF5F5F5); // Light gray (100)
  static const Color neutral30 = Color(0xFFEEEEEE); // Light medium gray (200)
  static const Color neutral40 = Color(0xFFE0E0E0); // Medium gray (300)
  static const Color neutral50 = Color(0xFFBDBDBD); // Base neutral (400)
  static const Color neutral60 = Color(0xFF9E9E9E); // Medium dark gray (500)
  static const Color neutral70 = Color(0xFF757575); // Dark gray (600)
  static const Color neutral80 = Color(0xFF616161); // Very dark gray (700)
  static const Color neutral90 = Color(0xFF212121); // Almost black (900)

  // ============================================
  // SURFACE COLORS (neutral with teal undertone)
  // ============================================
  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color surfaceMedium = Color(0xFFF5F5F5);
  static const Color surfaceDark = Color(0xFFEEEEEE);

  // Legacy card background aliases
  static const Color cardBackground1 = surfaceMedium;
  static const Color cardBackground2 = surfaceDark;

  // ============================================
  // SEMANTIC COLORS
  // ============================================
  /// Success color - uses primary teal for consistency
  static const Color success = Color(_tealPrimaryValue);

  /// Error color - red for accessibility (must remain distinct)
  static const Color error = Color(0xFFD32F2F);

  /// Warning color - amber
  static const Color warning = Color(0xFFFF8F00);

  /// Info color - dark teal variant
  static const Color info = Color(0xFF00796B);

  // ============================================
  // TEXT COLORS
  // ============================================
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Legacy text color aliases
  static const Color primaryText = textPrimary;
  static const Color secondaryText = textSecondary;
  static const Color disabled = textDisabled;

  // ============================================
  // BASIC COLORS
  // ============================================
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);
  static const Color shadow = Color(0xFF18280F);

  // ============================================
  // LEGACY PRIMARY COLOR ALIASES (for backward compatibility)
  // Prefer using primary[shade] directly for new code
  // ============================================
  /// Alias for primary[100] - light teal for focus/overlay states
  /// Prefer: BaseColor.primary[100]
  static const Color primary2 = Color(0xFFB2DFDB);

  /// Alias for primary[500] - the main teal color
  /// Prefer: BaseColor.primary[500] or BaseColor.primary
  static const Color primary3 = Color(_tealPrimaryValue);

  /// Alias for primary[400] - active state teal
  /// Prefer: BaseColor.primary[400]
  static const Color primary4 = Color(0xFF26A69A);

  // ============================================
  // SECONDARY COLOR PALETTES (for specific use cases)
  // ============================================

  // Red palette - for error states and destructive actions
  static const int _redPrimaryValue = 0xFFD32F2F;
  static const MaterialColor red = MaterialColor(_redPrimaryValue, <int, Color>{
    50: Color(0xFFFFEBEE),
    100: Color(0xFFFFCDD2),
    200: Color(0xFFEF9A9A),
    300: Color(0xFFE57373),
    400: Color(0xFFEF5350),
    500: Color(_redPrimaryValue),
    600: Color(0xFFC62828),
    700: Color(0xFFB71C1C),
    800: Color(0xFF8E0000),
    900: Color(0xFF5D0000),
  });

  // Amber/Yellow palette - for warnings
  static const int _yellowPrimaryValue = 0xFFFF8F00;
  static const MaterialColor yellow =
      MaterialColor(_yellowPrimaryValue, <int, Color>{
        50: Color(0xFFFFF8E1),
        100: Color(0xFFFFECB3),
        200: Color(0xFFFFE082),
        300: Color(0xFFFFD54F),
        400: Color(0xFFFFCA28),
        500: Color(_yellowPrimaryValue),
        600: Color(0xFFFF6F00),
        700: Color(0xFFE65100),
        800: Color(0xFFBF360C),
        900: Color(0xFF8D2600),
      });

  // Blue palette - kept for legacy compatibility, use sparingly
  static const int _bluePrimaryValue = 0xFF2196F3;
  static const MaterialColor blue =
      MaterialColor(_bluePrimaryValue, <int, Color>{
        50: Color(0xFFE3F2FD),
        100: Color(0xFFBBDEFB),
        200: Color(0xFF90CAF9),
        300: Color(0xFF64B5F6),
        400: Color(0xFF42A5F5),
        500: Color(_bluePrimaryValue),
        600: Color(0xFF1E88E5),
        700: Color(0xFF1976D2),
        800: Color(0xFF1565C0),
        900: Color(0xFF0D47A1),
      });

  // Green palette - kept for legacy compatibility, prefer teal for success
  static const int _greenPrimaryValue = 0xFF4CAF50;
  static const MaterialColor green =
      MaterialColor(_greenPrimaryValue, <int, Color>{
        50: Color(0xFFE8F5E9),
        100: Color(0xFFC8E6C9),
        200: Color(0xFFA5D6A7),
        300: Color(0xFF81C784),
        400: Color(0xFF66BB6A),
        500: Color(_greenPrimaryValue),
        600: Color(0xFF43A047),
        700: Color(0xFF388E3C),
        800: Color(0xFF2E7D32),
        900: Color(0xFF1B5E20),
      });
}
