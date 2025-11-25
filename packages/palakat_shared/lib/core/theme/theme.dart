import 'package:flutter/material.dart';

/// Primary teal color for the Palakat app
/// This is the seed color for the entire color scheme
const Color _primaryTeal = Color(0xFF009688);

/// Builds the app theme using Material 3 with teal as the primary color.
/// Uses ColorScheme.fromSeed to generate a cohesive color palette.
ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryTeal,
      brightness: Brightness.light,
      // Override specific colors for consistency with design system
      primary: _primaryTeal,
      onPrimary: Colors.white,
      surface: const Color(0xFFFAFAFA),
      onSurface: const Color(0xFF212121),
      error: const Color(0xFFD32F2F),
    ),
    visualDensity: VisualDensity.standard,
  );

  return base.copyWith(
    // Typography with color integration
    textTheme: base.textTheme.copyWith(
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: const Color(0xFF212121),
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: const Color(0xFF212121),
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(
        color: const Color(0xFF424242),
      ),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        color: const Color(0xFF616161),
      ),
    ),

    // AppBar theme
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: base.colorScheme.surface,
      foregroundColor: base.colorScheme.onSurface,
      centerTitle: false,
      titleTextStyle: base.textTheme.titleLarge?.copyWith(
        color: const Color(0xFF212121),
        fontWeight: FontWeight.w600,
      ),
    ),

    // Card theme with 16px border radius per design spec
    cardTheme: CardThemeData(
      elevation: 1,
      color: const Color(0xFFF5F5F5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(8),
    ),

    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryTeal, width: 2),
      ),
      isDense: true,
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
    ),

    // Divider theme
    dividerTheme: DividerThemeData(
      color: base.colorScheme.outlineVariant,
      space: 0.5,
      thickness: 1,
    ),

    // ListTile theme
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      iconColor: base.colorScheme.onSurfaceVariant,
      tileColor: const Color(0xFFF5F5F5),
    ),

    // Chip theme with 8px border radius per design spec
    chipTheme: base.chipTheme.copyWith(
      side: BorderSide(color: base.colorScheme.outlineVariant),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: const Color(0xFFE0F2F1), // primary[50]
      selectedColor: const Color(0xFFB2DFDB), // primary[100]
      labelStyle: const TextStyle(color: Color(0xFF212121)),
    ),

    // Elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryTeal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 0,
      ),
    ),

    // Outlined button theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _primaryTeal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: _primaryTeal),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),

    // Text button theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primaryTeal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    ),

    // Floating action button theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _primaryTeal,
      foregroundColor: Colors.white,
      elevation: 2,
    ),

    // SnackBar theme
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: base.colorScheme.inverseSurface,
      contentTextStyle: base.textTheme.bodyMedium?.copyWith(
        color: base.colorScheme.onInverseSurface,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      actionTextColor: const Color(0xFF80CBC4), // primary[200] for contrast
      showCloseIcon: true,
      closeIconColor: base.colorScheme.onInverseSurface,
    ),

    // Bottom navigation bar theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: _primaryTeal,
      unselectedItemColor: Color(0xFF757575),
      backgroundColor: Color(0xFFFAFAFA),
      elevation: 8,
    ),

    // Tab bar theme
    tabBarTheme: const TabBarThemeData(
      labelColor: _primaryTeal,
      unselectedLabelColor: Color(0xFF757575),
      indicatorColor: _primaryTeal,
    ),

    // Icon theme
    iconTheme: const IconThemeData(color: Color(0xFF757575), size: 24),

    // Primary icon theme
    primaryIconTheme: const IconThemeData(color: Colors.white, size: 24),

    // Progress indicator theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: _primaryTeal,
      linearTrackColor: Color(0xFFB2DFDB), // primary[100]
    ),

    // Switch theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _primaryTeal;
        }
        return const Color(0xFFBDBDBD);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFF80CBC4); // primary[200]
        }
        return const Color(0xFFE0E0E0);
      }),
    ),

    // Checkbox theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _primaryTeal;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      side: const BorderSide(color: Color(0xFFBDBDBD), width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    // Radio theme
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _primaryTeal;
        }
        return const Color(0xFFBDBDBD);
      }),
    ),
  );
}
