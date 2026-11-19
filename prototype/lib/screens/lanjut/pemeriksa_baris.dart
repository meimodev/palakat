import 'package:flutter/widgets.dart';

import '../../theme/palakat_tema.dart';

/// A detail row of Pemeriksa and WebPemeriksa: label 14 `tinta2` and value
/// 14/600 in a `space-between` flex row, gap 16. When both do not fit, each
/// shrinks in proportion to its own width, as CSS `flex-shrink: 1` does.
class BarisRincian extends StatelessWidget {
  const BarisRincian(
    this.label,
    this.nilai, {
    super.key,
    this.warna,
    this.kanan = false,
    this.atas = true,
    this.vertikal = 11,
  });

  final String label, nilai;

  /// Value colour; inherits `tinta` when null.
  final Color? warna;

  /// The value's `text-align: right`.
  final bool kanan;

  /// The 1 px `garis` line above (every row but the first).
  final bool atas;

  /// Row padding top and bottom: 11 phone, 10 web.
  final double vertikal;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final gayaLabel = TextStyle(fontSize: 14, color: c.tinta2);
    final gayaNilai = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: warna,
    );
    final dasar = DefaultTextStyle.of(context).style;
    final skala = MediaQuery.textScalerOf(context);
    double lebar(String t, TextStyle g) {
      final p = TextPainter(
        text: TextSpan(text: t, style: dasar.merge(g)),
        textDirection: TextDirection.ltr,
        textScaler: skala,
      )..layout();
      final w = p.width;
      p.dispose();
      return w;
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: vertikal),
      decoration: atas
          ? BoxDecoration(
              border: Border(top: BorderSide(color: c.garis)),
            )
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: (lebar(label, gayaLabel) * 100).round(),
            child: Text(label, style: gayaLabel),
          ),
          const SizedBox(width: 16),
          Flexible(
            flex: (lebar(nilai, gayaNilai) * 100).round(),
            child: Text(
              nilai,
              textAlign: kanan ? TextAlign.right : TextAlign.left,
              style: gayaNilai,
            ),
          ),
        ],
      ),
    );
  }
}
