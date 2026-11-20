import 'package:flutter/material.dart';

import '../theme/palakat_tema.dart';
import 'garis.dart';
import 'tekan.dart';

/// One choice of a few, all visible. Label 14 `tinta2` (+ [keterangan] in
/// `tinta3`), gap [jarakLabel]; chips wrap with the board's `margin: 0 8px
/// 8px 0` ([jarakBaris] 0 for the `0 8px 0 0` filter rows). Nothing is
/// chosen until the person taps ([terpilih] null).
class ChipPilihan<T> extends StatelessWidget {
  const ChipPilihan({
    super.key,
    this.label,
    required this.pilihan,
    required this.terpilih,
    required this.onPilih,
    this.keterangan,
    this.padding = 14,
    this.jarakLabel = 8,
    this.jarakBaris = 8,
    this.jarakBawah,
  });

  /// 'Diambil dari peruntukan'; null for list filters without a label.
  final String? label;

  /// '· uang siapa ini', after the label in `tinta3`.
  final String? keterangan;
  final List<({T nilai, String teks})> pilihan;
  final T? terpilih;
  final ValueChanged<T> onPilih;

  /// Horizontal chip padding: 14 in forms, 16 in list filters.
  final double padding;

  /// Gap under the label: 8, or 6 on the flow boards.
  final double jarakLabel;

  /// Each chip's bottom margin (CSS): 8 in forms, 0 in filter rows.
  final double jarakBaris;

  /// Space under the chips when it differs from [jarakBaris]: 0 for the flow
  /// boards' `flex-wrap: wrap; gap: 8px` group (gap 8 between lines, none under).
  final double? jarakBawah;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final chips = Padding(
      padding: EdgeInsets.only(bottom: jarakBawah ?? jarakBaris),
      child: Wrap(
        spacing: 8,
        runSpacing: jarakBaris,
        children: [
          for (final p in pilihan)
            ChipSatu(
              teks: p.teks,
              dipilih: p.nilai == terpilih,
              padding: padding,
              onTap: () => onPilih(p.nilai),
            ),
        ],
      ),
    );
    if (label == null) return chips;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            children: [
              if (keterangan != null)
                TextSpan(
                  text: ' $keterangan',
                  style: TextStyle(color: c.tinta3),
                ),
            ],
          ),
          style: TextStyle(fontSize: 14, color: c.tinta2),
        ),
        SizedBox(height: jarakLabel),
        chips,
      ],
    );
  }
}

/// One chip: min height 44, padding 0 [padding], pill, 1.5 line, 14/600.
/// Chosen: `tinta` fill and line, `permukaan` text. Not chosen: `permukaan`,
/// `garisTegas` line, `tinta` text. Instant colour change (no transition).
/// Public for the screens that draw a chip outside a [ChipPilihan] (Main's
/// "Catatan lain" links inside a `Tautan`: pass [onTap] null there).
class ChipSatu extends StatelessWidget {
  const ChipSatu({
    super.key,
    required this.teks,
    required this.dipilih,
    required this.onTap,
    this.padding = 14,
  });

  final String teks;
  final bool dipilih;
  final VoidCallback? onTap;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final isi = Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: EdgeInsets.symmetric(horizontal: padding),
      decoration: ShapeDecoration(
        color: dipilih ? c.tinta : c.permukaan,
        shape: GarisBorder.penuh(
          dipilih ? c.tinta : c.garisTegas,
          radius: PalakatRadius.chip,
        ),
      ),
      // A min-size Row fills the 44 minimum and centres the text in it.
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              teks,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: dipilih ? c.permukaan : c.tinta,
              ),
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return isi;
    return Tekan(onTap: onTap, dipilih: dipilih, radius: 22, child: isi);
  }
}
