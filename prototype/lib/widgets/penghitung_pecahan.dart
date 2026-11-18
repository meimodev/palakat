import 'package:flutter/material.dart';

import '../mock/format.dart';
import '../theme/palakat_tema.dart';
import 'garis.dart';
import 'tekan.dart';

const _mono = TextStyle(
  fontFamily: PalakatText.mono,
  fontFeatures: [FontFeature.tabularFigures()],
);

/// One HitungKas row: denomination, − and + (44 × 44), the count and the
/// product. Min height 56, gap 8, a 1 px `garis` rule above ([garisAtas]
/// false on the first row). Put the rows in a `Kartu(padding:
/// EdgeInsets.fromLTRB(16, 0, 12, 0))`. The count never goes below 0.
class PenghitungPecahan extends StatelessWidget {
  const PenghitungPecahan({
    super.key,
    required this.pecahan,
    required this.lembar,
    required this.onUbah,
    this.garisAtas = true,
  });

  /// 100000.
  final int pecahan;

  /// Count, ≥ 0.
  final int lembar;

  /// New count, clamped at 0 (board: Math.max(0, m[i] + d)).
  final ValueChanged<int> onUbah;
  final bool garisAtas;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final baris = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              titik('$pecahan'),
              style: _mono.copyWith(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          _TombolHitung(
            tanda: '−',
            label: 'Kurangi satu lembar ${rp(pecahan)}',
            gelap: false,
            onTap: () => onUbah(lembar > 0 ? lembar - 1 : 0),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 36,
            child: Text(
              '$lembar',
              textAlign: TextAlign.center,
              style: _mono.copyWith(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          _TombolHitung(
            tanda: '+',
            label: 'Tambah satu lembar ${rp(pecahan)}',
            gelap: true,
            onTap: () => onUbah(lembar + 1),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              lembar > 0 ? rp(lembar * pecahan) : kosong,
              textAlign: TextAlign.right,
              style: _mono.copyWith(
                fontSize: 14,
                color: lembar > 0 ? c.tinta : c.tinta3,
              ),
            ),
          ),
        ],
      ),
    );
    if (!garisAtas) return baris;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GarisLurus(warna: c.garis),
        baris,
      ],
    );
  }
}

/// The − (1.5 `garisTegas` on `permukaan`) and + (`tinta` fill, `permukaan`
/// text) buttons: 44 × 44, radius 12, sign 22/600, line height 1.
class _TombolHitung extends StatelessWidget {
  const _TombolHitung({
    required this.tanda,
    required this.label,
    required this.gelap,
    required this.onTap,
  });

  final String tanda, label;
  final bool gelap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tekan(
      onTap: onTap,
      label: label,
      radius: 12,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          color: gelap ? c.tinta : c.permukaan,
          shape: gelap
              ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              : GarisBorder.penuh(c.garisTegas, radius: 12),
        ),
        child: Text(
          tanda,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            height: 1,
            color: gelap ? c.permukaan : c.tinta,
          ),
        ),
      ),
    );
  }
}
