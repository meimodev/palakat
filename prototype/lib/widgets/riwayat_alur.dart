import 'package:flutter/widgets.dart';

import '../theme/palakat_tema.dart';
import 'garis.dart';
import 'kecil.dart';

/// The flow boards' history (K11): h2 16/700 "Riwayat", then a `Kartu`
/// padding 4 16 whose rows are `padding: 8px 0; border-top: 1px solid garis;
/// margin-top: -1px`, 13 `tinta3`. Nothing when [baris] is empty.
class RiwayatAlur extends StatelessWidget {
  const RiwayatAlur({
    super.key,
    required this.baris,
    this.judul = 'Riwayat',
    this.jarak = 16,
  });

  /// Newest first, each already 'dd/mm/yyyy · {what} · {who}, {post}'.
  final List<String> baris;
  final String judul;

  /// The body gap between heading and card (16 phone; the screen's gap on web).
  final double jarak;

  @override
  Widget build(BuildContext context) {
    if (baris.isEmpty) return const SizedBox.shrink();
    final c = context.warna;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          header: true,
          child: Text(
            judul,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        SizedBox(height: jarak),
        Kartu(
          // The −1 margin of every row is folded in: top 4 − 1, each row
          // 8 0 7 under its rule, bottom 4 + 1. So the first rule sits 3 px
          // under the card's top edge, as on every board.
          padding: const EdgeInsets.fromLTRB(16, 3, 16, 5),
          child: DefaultTextStyle.merge(
            style: TextStyle(fontSize: 13, color: c.tinta3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final b in baris) ...[
                  GarisLurus(warna: c.garis),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 7),
                    child: Text(b),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
