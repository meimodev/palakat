import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palakat/core/assets/fonts.gen.dart';
import 'package:palakat/core/constants/themes/color_constants.dart';
import 'package:palakat/core/constants/themes/typography_constant.dart';

/// Base theme configuration for the Palakat app.
/// Uses the monochromatic teal color system defined in [BaseColor].
class BaseTheme {
  /// Main app theme using Material 3 with teal as primary color.
  static ThemeData appTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: BaseColor.primary,
      brightness: Brightness.light,
      primary: BaseColor.primary,
      onPrimary: BaseColor.textOnPrimary,
      surface: BaseColor.surfaceLight,
      onSurface: BaseColor.textPrimary,
      error: BaseColor.error,
    ),
    scaffoldBackgroundColor: BaseColor.surfaceLight,
    fontFamily: FontFamily.openSans,
    textTheme: BaseTypography.textTheme.apply(
      bodyColor: BaseColor.textPrimary,
      displayColor: BaseColor.textPrimary,
    ),
    primaryTextTheme: BaseTypography.textTheme.apply(
      bodyColor: BaseColor.textOnPrimary,
      displayColor: BaseColor.textOnPrimary,
    ),
    primaryColor: BaseColor.primary,
    visualDensity: VisualDensity.standard,
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: BaseColor.surfaceLight,
      foregroundColor: BaseColor.textPrimary,
      centerTitle: false,
      titleTextStyle: BaseTypography.titleLarge.copyWith(
        color: BaseColor.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      toolbarTextStyle: BaseTypography.bodyMedium.copyWith(
        color: BaseColor.textPrimary,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        systemNavigationBarColor: BaseColor.black,
        statusBarBrightness: Brightness.light,
        statusBarColor: BaseColor.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      color: BaseColor.surfaceMedium,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(8),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: BaseColor.neutral[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: BaseColor.neutral[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: BaseColor.primary, width: 2),
      ),
      isDense: true,
      filled: true,
      fillColor: BaseColor.surfaceLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: BaseTypography.bodyMedium.copyWith(
        color: BaseColor.textSecondary,
      ),
      labelStyle: BaseTypography.bodyMedium.copyWith(
        color: BaseColor.textSecondary,
      ),
      floatingLabelStyle: BaseTypography.bodyMedium.copyWith(
        color: BaseColor.primary,
        fontWeight: FontWeight.w600,
      ),
      helperStyle: BaseTypography.bodyMedium.copyWith(
        color: BaseColor.textSecondary,
      ),
      errorStyle: BaseTypography.bodyMedium.copyWith(color: BaseColor.error),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: BaseColor.primary,
        foregroundColor: BaseColor.textOnPrimary,
        textStyle: BaseTypography.labelLarge.copyWith(
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: BaseColor.primary,
        textStyle: BaseTypography.labelLarge.copyWith(
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: BaseColor.primary),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: BaseColor.primary,
        textStyle: BaseTypography.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: BaseColor.primary,
      foregroundColor: BaseColor.textOnPrimary,
      elevation: 2,
    ),
    chipTheme: ChipThemeData(
      side: BorderSide(color: BaseColor.neutral[300]!),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: BaseColor.primary[50],
      selectedColor: BaseColor.primary[100],
      labelStyle: BaseTypography.labelMedium.copyWith(
        color: BaseColor.textPrimary,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: BaseColor.primary,
      unselectedItemColor: BaseColor.textSecondary,
      backgroundColor: BaseColor.surfaceLight,
      elevation: 8,
      selectedLabelStyle: BaseTypography.labelMedium.copyWith(
        color: BaseColor.primary,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: BaseTypography.labelMedium.copyWith(
        color: BaseColor.textSecondary,
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: BaseColor.primary,
      unselectedLabelColor: BaseColor.textSecondary,
      indicatorColor: BaseColor.primary,
      labelStyle: BaseTypography.labelLarge.copyWith(
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: BaseTypography.labelLarge.copyWith(
        fontWeight: FontWeight.w600,
      ),
    ),
    iconTheme: const IconThemeData(color: BaseColor.textSecondary, size: 24),
    primaryIconTheme: const IconThemeData(
      color: BaseColor.textOnPrimary,
      size: 24,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: BaseColor.primary,
      linearTrackColor: BaseColor.primary[100],
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      showCloseIcon: true,
      contentTextStyle: BaseTypography.bodyMedium.copyWith(
        color: BaseColor.textPrimary,
      ),
    ),
  );
}
