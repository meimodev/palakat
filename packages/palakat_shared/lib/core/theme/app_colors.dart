import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const MaterialColor primary = MaterialColor(0xFF000000, {
    50: Color(0xFFF3F3F3),
    100: Color(0xFFE2E2E2),
    200: Color(0xFFC6C6C6),
    300: Color(0xFFA6A6A6),
    400: Color(0xFF777777),
    500: Color(0xFF5E5E5E),
    600: Color(0xFF474747),
    700: Color(0xFF3B3B3B),
    800: Color(0xFF1A1A1A),
    900: Color(0xFF000000),
  });

  static const MaterialColor secondary = MaterialColor(0xFF424242, {
    50: Color(0xFFF2F4F3),
    100: Color(0xFFD6D4D3),
    200: Color(0xFFC8C6C6),
    300: Color(0xFFACABAB),
    400: Color(0xFF8D8C8C),
    500: Color(0xFF6F6E6E),
    600: Color(0xFF5F5E5E),
    700: Color(0xFF4D4C4C),
    800: Color(0xFF424242),
    900: Color(0xFF2F3131),
  });

  static const MaterialColor neutral = MaterialColor(0xFFF5F5F5, {
    50: Color(0xFFF9F9F9),
    100: Color(0xFFF3F3F3),
    200: Color(0xFFEEEEEE),
    300: Color(0xFFE8E8E8),
    400: Color(0xFFE2E2E2),
    500: Color(0xFFDADADA),
    600: Color(0xFFC6C6C6),
    700: Color(0xFFA6A6A6),
    800: Color(0xFF777777),
    900: Color(0xFF1A1A1A),
  });

  static const MaterialColor success = MaterialColor(0xFF2D6A4F, {
    50: Color(0xFFEAF4EF),
    100: Color(0xFFD1E6DA),
    200: Color(0xFFA3D1B7),
    300: Color(0xFF7AB898),
    400: Color(0xFF5E9B7D),
    500: Color(0xFF458162),
    600: Color(0xFF2D6A4F),
    700: Color(0xFF22513D),
    800: Color(0xFF183A2C),
    900: Color(0xFF0F251C),
  });

  static const MaterialColor error = MaterialColor(0xFF9B2226, {
    50: Color(0xFFFBE9EA),
    100: Color(0xFFF6D2D4),
    200: Color(0xFFEEA7AA),
    300: Color(0xFFE37A7F),
    400: Color(0xFFD85057),
    500: Color(0xFFBF343C),
    600: Color(0xFF9B2226),
    700: Color(0xFF7B0613),
    800: Color(0xFF5A040D),
    900: Color(0xFF410002),
  });

  static const MaterialColor warning = MaterialColor(0xFF8A6A2E, {
    50: Color(0xFFFAF2E6),
    100: Color(0xFFF1DFC0),
    200: Color(0xFFE6C98D),
    300: Color(0xFFD7AF58),
    400: Color(0xFFBC8B3E),
    500: Color(0xFFA67934),
    600: Color(0xFF8A6A2E),
    700: Color(0xFF6D5323),
    800: Color(0xFF513D19),
    900: Color(0xFF372910),
  });

  static const Color tertiary = Color(0xFFE0E0E0);
  static const Color surface = Color(0xFFF9F9F9);
  static const Color background = surface;
  static const Color surfaceDim = Color(0xFFDADADA);
  static const Color surfaceBright = Color(0xFFF9F9F9);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F3F3);
  static const Color surfaceContainer = Color(0xFFEEEEEE);
  static const Color surfaceContainerHigh = Color(0xFFE8E8E8);
  static const Color surfaceContainerHighest = Color(0xFFE2E2E2);
  static const Color surfaceVariant = Color(0xFFE2E2E2);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF3B3B3B);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFD6D4D3);
  static const Color onSecondaryContainer = Color(0xFF1B1C1C);
  static const Color onTertiary = Color(0xFF000000);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF410002);
  static const Color onSurface = Color(0xFF1A1C1C);
  static const Color onSurfaceVariant = Color(0xFF474747);
  static const Color onBackground = onSurface;
  static const Color outline = Color(0xFF777777);
  static const Color outlineVariant = Color(0xFFC6C6C6);
  static const Color inverseSurface = Color(0xFF2F3131);
  static const Color inverseOnSurface = Color(0xFFF1F1F1);
  static const Color inversePrimary = Color(0xFFC6C6C6);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF000000), Color(0xFF3B3B3B)],
  );

  static Color ghostBorder([double opacity = 0.15]) =>
      outlineVariant.withValues(alpha: opacity);
}
