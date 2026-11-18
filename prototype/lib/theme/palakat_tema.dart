import 'package:flutter/material.dart';

import 'palakat_tokens.dart';
import 'palakat_warna.dart';

export 'palakat_tokens.dart';
export 'palakat_warna.dart';

abstract final class PalakatUkuran {
  static const double tombolKedua = 48; // size-tombolKedua
  static const double isian = 48; // size-isian
}

ThemeData palakatTema(Brightness b) {
  final w = b == Brightness.light ? PalakatWarna.terang : PalakatWarna.gelap;
  final scheme = ColorScheme(
    brightness: b,
    primary: w.laut,
    onPrimary: w.diLaut,
    primaryContainer: w.lautLembut,
    onPrimaryContainer: w.lautTua,
    secondary: w.tinta,
    onSecondary: w.permukaan,
    error: w.bata,
    onError: w.diBata,
    errorContainer: w.bataLembut,
    onErrorContainer: w.bata,
    surface: w.kertas,
    surfaceContainerLowest: w.permukaan,
    onSurface: w.tinta,
    onSurfaceVariant: w.tinta2,
    outline: w.putus,
    outlineVariant: w.garis,
    inverseSurface: w.tinta,
    onInverseSurface: w.diTinta,
  );
  const teks = TextTheme(
    headlineMedium: PalakatText.judulHalaman,
    headlineSmall: PalakatText.judulBesar,
    titleLarge: PalakatText.judulLayar,
    titleMedium: PalakatText.judulBagian,
    bodyLarge: PalakatText.isi,
    bodyMedium: PalakatText.pendamping,
    bodySmall: PalakatText.keterangan,
    labelLarge: TextStyle(
      fontFamily: PalakatText.sans,
      fontSize: 16,
      fontWeight: FontWeight.w700,
    ),
  );
  return ThemeData(
    useMaterial3: true,
    brightness: b,
    colorScheme: scheme,
    extensions: [w],
    scaffoldBackgroundColor: w.kertas,
    fontFamily: PalakatText.sans,
    textTheme: teks.apply(bodyColor: w.tinta, displayColor: w.tinta),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    focusColor: Colors.transparent,
    visualDensity: VisualDensity.standard,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    cardTheme: CardThemeData(
      color: w.permukaan,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: w.garis),
      ),
    ),
  );
}

extension PalakatKonteks on BuildContext {
  PalakatWarna get warna => Theme.of(this).extension<PalakatWarna>()!;

  /// True when the system asks for reduced motion or the Keadaan panel switch is on.
  bool get kurangiGerak => MediaQuery.disableAnimationsOf(this);

  /// Token duration, or zero under reduced motion.
  Duration gerak(Duration d) => kurangiGerak ? Duration.zero : d;

  /// CSS vw: percent of the window width (not the parent width).
  double vw(double persen) => MediaQuery.sizeOf(this).width * persen / 100;

  /// CSS `clamp(min, <vw>vw, max)`.
  double jepit(double min, double vwPersen, double max) =>
      vw(vwPersen).clamp(min, max);
}
