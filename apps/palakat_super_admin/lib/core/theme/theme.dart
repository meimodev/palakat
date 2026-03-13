import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF14B8A6),
      brightness: Brightness.light,
      surface: const Color(0xFFFAFAFA),
      onSurface: const Color(0xFF212121),
    ),
    visualDensity: VisualDensity.standard,
  );

  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: base.colorScheme.onSurface,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: base.colorScheme.onSurface,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(
        color: base.colorScheme.onSurface.withValues(alpha: 0.85),
      ),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        color: base.colorScheme.onSurfaceVariant,
      ),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: base.colorScheme.surface,
      foregroundColor: base.colorScheme.onSurface,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: base.colorScheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: base.colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: base.colorScheme.primary, width: 2),
      ),
      isDense: true,
      filled: true,
      fillColor: base.colorScheme.surface,
    ),
    dividerTheme: DividerThemeData(
      color: base.colorScheme.outlineVariant,
      space: 0.5,
      thickness: 1,
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      iconColor: base.colorScheme.onSurfaceVariant,
    ),
    chipTheme: base.chipTheme.copyWith(
      side: BorderSide(color: base.colorScheme.outlineVariant),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: base.colorScheme.primaryContainer.withValues(
        alpha: 0.35,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: base.colorScheme.outlineVariant),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
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
      actionTextColor: base.colorScheme.primary,
      showCloseIcon: true,
      closeIconColor: base.colorScheme.onInverseSurface,
    ),
  );
}
