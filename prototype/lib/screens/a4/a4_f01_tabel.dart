import 'package:flutter/material.dart';

import '../../theme/palakat_tema.dart';

/// One column of an A4 report table: fixed [lebar], or `minmax(0, 1fr)`
/// when null. [mono] applies to body cells only (the header row is sans).
class KolomA4 {
  const KolomA4(
    this.lebar, {
    this.kanan = false,
    this.mono = false,
    this.bungkus = true,
  });
  final double? lebar;
  final bool kanan, mono;

  /// false: an unbreakable value runs into the gap as on the board
  /// (CSS never breaks inside '04/10/2026'; Flutter would).
  final bool bungkus;
}

/// Header row (padding 6 0), body row (4 0, 1 px `garisTegas`) or an
/// emphasised row (4 0, 1.5 `tinta`, 700): the shared A4 report table.
enum JenisBarisA4 { kepala, isi, tebal }

/// One grid row, column gap 10. A cell is a String or a Widget.
class BarisA4 extends StatelessWidget {
  const BarisA4(
    this.kolom,
    this.sel, {
    super.key,
    this.jenis = JenisBarisA4.isi,
  });
  final List<KolomA4> kolom;
  final List<Object> sel;
  final JenisBarisA4 jenis;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final tipis = jenis == JenisBarisA4.isi;
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: jenis == JenisBarisA4.kepala ? 6 : 4,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: tipis ? c.garisTegas : c.tinta,
            width: tipis ? 1 : 1.5,
          ),
        ),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(fontWeight: tipis ? null : FontWeight.w700),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < kolom.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              _sel(kolom[i], sel[i]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sel(KolomA4 k, Object isi) {
    final mono = k.mono && jenis != JenisBarisA4.kepala;
    final anak = isi is Widget
        ? isi
        : Text(
            isi as String,
            textAlign: k.kanan ? TextAlign.right : TextAlign.left,
            softWrap: k.bungkus,
            overflow: TextOverflow.visible,
            style: mono ? const TextStyle(fontFamily: PalakatText.mono) : null,
          );
    final kotak = SizedBox(
      width: double.infinity,
      child: Align(
        alignment: k.kanan ? Alignment.topRight : Alignment.topLeft,
        child: anak,
      ),
    );
    return k.lebar == null
        ? Expanded(child: kotak)
        : SizedBox(width: k.lebar, child: kotak);
  }
}

/// Inline print tag after the uraian text: 1 px `tinta` border, radius 4,
/// padding 0 5, 600, no wrap.
WidgetSpan tandaCetak(BuildContext context, String teks) => WidgetSpan(
  alignment: PlaceholderAlignment.middle,
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
