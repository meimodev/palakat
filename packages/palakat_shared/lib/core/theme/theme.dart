import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

export 'app_colors.dart';
export 'app_typography.dart';
export 'gap.dart';
export 'text_style_extension.dart';

class SanctuaryLayout {
  const SanctuaryLayout._();

  static const double radius = 8;
  static const double radiusLarge = 16;
  static const double pillRadius = 999;
  static const double sectionGap = 24;
  static const double blockGap = 16;
  static const double compactGap = 12;
  static const double desktopSidebarWidth = 288;
  static const double desktopContentMaxWidth = 1440;
  static const double mobileContentMaxWidth = 840;

  static double horizontalPadding(double width) {
    if (width < 600) return 16;
    if (width < 960) return 24;
    if (width > 1600) return 40;
    return 32;
  }

  static double mobileHorizontalPadding(double width) {
    if (width >= 768) return 24;
    return 16;
  }
}

class SanctuaryDepth {
  const SanctuaryDepth._();

  static List<BoxShadow> ambient({double opacity = 0.05, double blur = 40}) {
    return [
      BoxShadow(
        color: AppColors.onSurface.withValues(alpha: opacity),
        blurRadius: blur,
        offset: const Offset(0, 12),
      ),
    ];
  }
}

ThemeData buildAppTheme() {
  const baseColorTheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    secondaryContainer: AppColors.secondaryContainer,
    tertiary: AppColors.tertiary,
    onTertiary: AppColors.onTertiary,
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.onErrorContainer,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    surfaceTint: AppColors.primaryContainer,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    outline: AppColors.outline,
    outlineVariant: AppColors.outlineVariant,
    inverseSurface: AppColors.inverseSurface,
    onInverseSurface: AppColors.inverseOnSurface,
    inversePrimary: AppColors.inversePrimary,
  );

  final baseTheme = ThemeData(
    useMaterial3: true,
    colorScheme: baseColorTheme,
    scaffoldBackgroundColor: AppColors.background,
    canvasColor: AppColors.background,
  );

  final textTheme = AppTypography.buildTextTheme(baseTheme.textTheme);

  return baseTheme.copyWith(
    textTheme: textTheme,
    scaffoldBackgroundColor: AppColors.background,
    splashFactory: InkSparkle.splashFactory,
    iconTheme: const IconThemeData(color: AppColors.onSurfaceVariant),
    primaryIconTheme: const IconThemeData(color: AppColors.onSurface),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.onSurface,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: AppColors.onSurface,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
      ),
      margin: EdgeInsets.zero,
      shadowColor: AppColors.onSurface.withValues(alpha: 0.04),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
        borderSide: BorderSide(
          color: AppColors.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
        borderSide: BorderSide(
          color: AppColors.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      isDense: true,
      filled: true,
      fillColor: AppColors.surfaceContainer,
      hintStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.onSurfaceVariant.withValues(alpha: 0.72),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.ghostBorder(0.08),
      space: 1,
      thickness: 1,
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
      ),
      iconColor: AppColors.onSurfaceVariant,
      tileColor: AppColors.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    ),
    chipTheme: baseTheme.chipTheme.copyWith(
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SanctuaryLayout.pillRadius),
      ),
      backgroundColor: AppColors.surfaceContainer,
      selectedColor: AppColors.primary,
      labelStyle: textTheme.labelMedium?.copyWith(color: AppColors.onSurface),
      secondaryLabelStyle: textTheme.labelMedium?.copyWith(
        color: AppColors.onPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        elevation: 0,
        shadowColor: Colors.transparent,
        textStyle: textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
        ),
        side: BorderSide(color: AppColors.ghostBorder()),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        textStyle: textTheme.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        textStyle: textTheme.labelLarge,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surfaceContainerLowest,
      elevation: 0,
      shadowColor: AppColors.onSurface.withValues(alpha: 0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.onSurfaceVariant,
      backgroundColor: AppColors.surface.withValues(alpha: 0.92),
      elevation: 0,
      selectedLabelStyle: textTheme.labelSmall,
      unselectedLabelStyle: textTheme.labelSmall,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(AppColors.onPrimary),
      side: BorderSide(color: AppColors.ghostBorder(0.3), width: 1.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.tertiary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryContainer;
        }
        return AppColors.surfaceContainer;
      }),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.surfaceContainerLowest,
      elevation: 0,
      shadowColor: AppColors.onSurface.withValues(alpha: 0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColors.surfaceContainerLowest,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
  );
}
