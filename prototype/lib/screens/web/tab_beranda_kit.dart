import 'package:flutter/material.dart';

import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';

/// Shared parts of the tablet finance boards (TabBeranda, TabTransaksi):
/// the h1 header row, the month pill and the inline text links. Every link
/// target stays a literal in the screen files (test/links_test.dart).

/// Header row (wrap, centred, gap 12): h1 `flex: 1 1 200px`, then [ujung].
/// The h1 grows, so on one line the [ujung] group sits at the right edge;
/// when it does not fit it wraps under the h1 and wraps in itself.
class KepalaTab extends StatelessWidget {
  const KepalaTab(this.judul, {super.key, required this.ujung});
  final String judul;
  final List<Widget> ujung;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.spaceBetween,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 12,
    runSpacing: 12,
    children: [
      ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 200),
        child: Semantics(
          header: true,
          child: Text(
            judul,
            style: PalakatText.judulHalaman.copyWith(
              color: context.warna.tinta,
            ),
          ),
        ),
      ),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: ujung,
      ),
    ],
  );
}

/// The month pill "November 2026 · Belum ditutup"; the screen wraps it in
/// `Tautan(ke: 'WebPilihBulan', radius: 999, …)` (push).
class PilBulan extends StatelessWidget {
  const PilBulan({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: c.permukaan,
        border: Border.all(color: c.garisTegas),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Center(
        widthFactor: 1,
        heightFactor: 1,
        child: Text(
          'November 2026 · Belum ditutup',
          style: TextStyle(fontWeight: FontWeight.w600, color: c.tinta),
        ),
      ),
    );
  }
}

/// CSS spreads line-height leading evenly above and below the glyphs;
/// Flutter's default splits it by ascent and descent, which moves the mono
/// figures (line height 1.05 or 1.45) by 2 to 4 px. Wraps each child of
/// `main`, since HalamanWeb's DefaultTextStyle does not set it.
List<Widget> leadingCss(List<Widget> isi) => [
  for (final w in isi)
    DefaultTextStyle.merge(
      style: const TextStyle(leadingDistribution: TextLeadingDistribution.even),
      child: w,
    ),
];

/// An inline `<a>` (laut, underlined) as a 44 × 44 target, text centred.
class TautanTab extends StatelessWidget {
  const TautanTab(
    this.teks, {
    super.key,
    required this.ke,
    this.cara = Cara.dorong,
    this.ukuran,
    this.berat = FontWeight.w600,
  });

  final String teks;
  final String ke;
  final Cara cara;
  final double? ukuran;
  final FontWeight berat;

  @override
  Widget build(BuildContext context) => Tautan(
    ke: ke,
    cara: cara,
    child: Align(
      widthFactor: 1,
      heightFactor: 1,
      child: TautanTeks(teks, ukuran: ukuran, berat: berat),
    ),
  );
}
