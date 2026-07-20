import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const MaterialColor primary = MaterialColor(0xFF921573, {
    50: Color(0xFFF2E3EE),
    100: Color(0xFFE5C7DD),
    200: Color(0xFFD19DC4),
    300: Color(0xFFC077AE),
    400: Color(0xFFAC4D95),
    500: Color(0xFF9F3184),
    600: Color(0xFF8C146E),
    700: Color(0xFF801265),
    800: Color(0xFF72105A),
    900: Color(0xFF600E4C),
  });

  static const MaterialColor secondary = MaterialColor(0xFF6B1D84, {
    50: Color(0xFFEDE4F0),
    100: Color(0xFFDBC9E1),
    200: Color(0xFFC1A0CB),
    300: Color(0xFFA97CB8),
    400: Color(0xFF8F53A2),
    500: Color(0xFF7D3893),
    600: Color(0xFF671C7F),
    700: Color(0xFF5E1A74),
    800: Color(0xFF531767),
    900: Color(0xFF471357),
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

  static const MaterialColor success = MaterialColor(0xFF2F7A64, {
    50: Color(0xFFE6EFEC),
    100: Color(0xFFCDDFDA),
    200: Color(0xFFA8C7BE),
    300: Color(0xFF86B2A5),
    400: Color(0xFF619A89),
    500: Color(0xFF488A77),
    600: Color(0xFF2D7560),
    700: Color(0xFF296B58),
    800: Color(0xFF255F4E),
    900: Color(0xFF1F5142),
  });

  static const MaterialColor error = MaterialColor(0xFFAD2E4F, {
    50: Color(0xFFF5E6EA),
    100: Color(0xFFEBCDD5),
    200: Color(0xFFDDA7B5),
    300: Color(0xFFCF8699),
    400: Color(0xFFC16079),
    500: Color(0xFFB74764),
    600: Color(0xFFA62C4C),
    700: Color(0xFF982846),
    800: Color(0xFF87243E),
    900: Color(0xFF721E34),
  });

  static const MaterialColor warning = MaterialColor(0xFFA56A1F, {
    50: Color(0xFFF4EDE4),
    100: Color(0xFFE9DBC9),
    200: Color(0xFFD9C0A1),
    300: Color(0xFFCBA97D),
    400: Color(0xFFBB8E55),
    500: Color(0xFFB07C3A),
    600: Color(0xFF9E661E),
    700: Color(0xFF915D1B),
    800: Color(0xFF815318),
    900: Color(0xFF6D4614),
  });

  static const Color tertiary = Color(0xFFB81D5B);
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
  static const Color primaryContainer = Color(0xFF801265);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFDBC9E1);
  static const Color onSecondaryContainer = Color(0xFF471357);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFEBCDD5);
  static const Color onErrorContainer = Color(0xFF721E34);
  static const Color onSurface = Color(0xFF1A1C1C);
  static const Color onSurfaceVariant = Color(0xFF474747);
  static const Color onBackground = onSurface;
  static const Color outline = Color(0xFF777777);
  static const Color outlineVariant = Color(0xFFC6C6C6);
  static const Color inverseSurface = Color(0xFF2F3131);
  static const Color inverseOnSurface = Color(0xFFF1F1F1);
  static const Color inversePrimary = Color(0xFFD19DC4);

  static Color ghostBorder([double opacity = 0.15]) =>
      outlineVariant.withValues(alpha: opacity);
}
