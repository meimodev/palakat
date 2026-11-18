import 'package:flutter/widgets.dart';

import '../motion/kerangka.dart';
import '../theme/palakat_tema.dart';
import '../widgets/garis.dart';

/// Main's toast (components.md 4.5): a direct child of the [LayarPonsel]
/// Stack, `left 20, right 20, bottom 100`; `tinta` field, 1.5 dashed
/// `garisTegas` (a draft is not in the balance), radius 14, padding 12 16,
/// 14/600 `permukaan`. Enters with `muncul` 280 ms `keluar`; the screen removes
/// it after 2600 ms, with no exit.
class Toast extends StatelessWidget {
  const Toast(this.teks, {super.key});

  /// "Draf tersimpan · belum masuk saldo".
  final String teks;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Positioned(
      left: 20,
      right: 20,
      bottom: 100,
      child: Gerak(
        Kerangka.muncul,
        lama: PalakatMotion.pindahLayar,
        kurva: PalakatMotion.keluar,
        child: Semantics(
          liveRegion: true,
          container: true,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: ShapeDecoration(
              color: c.tinta,
              shape: GarisBorder.putus(c.garisTegas, tebal: 1.5, radius: 14),
            ),
            child: Text(
              teks,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: c.permukaan,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
