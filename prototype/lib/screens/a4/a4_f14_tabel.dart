import 'package:flutter/material.dart';

import '../../theme/palakat_tema.dart';

/// Header row (padding 6 0, 1.5 `tinta` rule, 700), body row (padding 4 0,
/// 1 `garisTegas` rule) or emphasised row (padding 4 0, 1.5 `tinta`, 700).
enum JenisBarisA4 { kepala, isi, tebal }

/// One grid row of an A4 report table (column gap 10). [kolom]: a width, or
/// null for `minmax(0, 1fr)`. A String cell is plain text (mono when its index
/// is in [mono]); any other cell is a widget. Shared by A4F14 and A4Sementara.
class BarisA4 extends StatelessWidget {
  const BarisA4({
    super.key,
    required this.kolom,
    required this.sel,
    this.jenis = JenisBarisA4.isi,
    this.kanan = const {},
    this.mono = const {},
  });

  final List<double?> kolom;
  final List<Object> sel;
  final JenisBarisA4 jenis;
  final Set<int> kanan, mono;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final isi = jenis == JenisBarisA4.isi;
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: jenis == JenisBarisA4.kepala ? 6 : 4,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: isi
              ? BorderSide(color: c.garisTegas)
              : BorderSide(color: c.tinta, width: 1.5),
        ),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(fontWeight: isi ? null : FontWeight.w700),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < kolom.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              _sel(i),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sel(int i) {
    final s = sel[i];
    final anak = s is String
        ? Text(
            s,
            textAlign: kanan.contains(i) ? TextAlign.right : TextAlign.left,
            style: mono.contains(i)
                ? const TextStyle(fontFamily: PalakatText.mono)
                : null,
          )
        : s as Widget;
    final lebar = kolom[i];
    return lebar == null
        ? Expanded(child: anak)
        : SizedBox(width: lebar, child: anak);
  }
}

/// Inline print tag after uraian text: 1 `tinta` border, radius 4,
/// padding 0 5, 600, no wrap.
WidgetSpan tagCetak(BuildContext context, String teks) => WidgetSpan(
  alignment: PlaceholderAlignment.baseline,
  baseline: TextBaseline.alphabetic,
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 5),
    decoration: BoxDecoration(
      border: Border.all(color: context.warna.tinta),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      teks,
      softWrap: false,
      style: const TextStyle(fontWeight: FontWeight.w600),
    ),
  ),
);

/// Section title, 700, margin [atas] 0 2.
class JudulA4 extends StatelessWidget {
  const JudulA4(this.teks, {super.key, this.atas = 6});
  final String teks;
  final double atas;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: atas, bottom: 2),
    child: Text(teks, style: const TextStyle(fontWeight: FontWeight.w700)),
  );
}

/// 15 px section block.
class BagianA4 extends StatelessWidget {
  const BagianA4({super.key, required this.anak});
  final List<Widget> anak;

  @override
  Widget build(BuildContext context) => DefaultTextStyle.merge(
    style: const TextStyle(fontSize: 15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: anak,
    ),
  );
}
