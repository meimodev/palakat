import 'dart:math' show max;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/palakat_tema.dart';
import 'ikon_data.dart';

export 'ikon_data.dart';

/// An icon of [Ikon]: inline SVG tinted by tokens. Line icons keep one thin
/// stroke at every size: never thinner than 1.25 px on screen.
class PalakatIkon extends StatelessWidget {
  const PalakatIkon(
    this.ikon, {
    super.key,
    this.ukuran = 22,
    this.warna,
    this.label,
  });
  final IkonData ikon;
  final double ukuran;

  /// Fills `{warna}`; default = DefaultTextStyle colour (CSS currentColor).
  final Color? warna;

  /// Board aria-label (role="img"); null = aria-hidden.
  final String? label;

  static final _cache = <(IkonData, Color, double, PalakatWarna), String>{};

  static String _hex(Color c) =>
      '#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';

  /// The stroke in viewBox units (line icons are drawn on a 24 grid).
  double get tebal => max(ikon.tebal ?? 0, 1.25 * 24 / ukuran);

  /// The resolved SVG string for this theme and tint.
  String svg(BuildContext context) {
    final w = context.warna;
    final tint = warna ?? DefaultTextStyle.of(context).style.color ?? w.tinta;
    String bangun() {
      final token = {
        'warna': tint,
        'laut': w.laut,
        'diLaut': w.diLaut,
        'bata': w.bata,
        'diBata': w.diBata,
        'tinta': w.tinta,
        'tinta2': w.tinta2,
        'tinta3': w.tinta3,
        'putus': w.putus,
        'garis': w.garis,
        'permukaan': w.permukaan,
      };
      final s = ikon.tebal == null ? '' : tebal.toStringAsFixed(2);
      return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="${ikon.viewBox}" ${ikon.akar}>${ikon.isi}</svg>'
          .replaceAll('{tebal}', s)
          .replaceAllMapped(RegExp(r'\{(\w+)\}'), (m) => _hex(token[m[1]]!));
    }

    // Only the two resting palettes are cached: a theme switch lerps through
    // throwaway palettes (and tints) for a few frames.
    if (!identical(w, PalakatWarna.terang) &&
        !identical(w, PalakatWarna.gelap)) {
      return bangun();
    }
    if (_cache.length > 512) _cache.clear();
    return _cache.putIfAbsent((ikon, tint, tebal, w), bangun);
  }

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      svg(context),
      width: ukuran,
      height: ukuran,
      semanticsLabel: label,
      excludeFromSemantics: label == null,
    );
  }
}
