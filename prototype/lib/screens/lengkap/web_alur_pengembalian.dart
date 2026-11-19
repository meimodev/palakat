import 'package:flutter/widgets.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'alur_pengembalian_alur.dart';

/// Web · Alur · Pengembalian (screens/13, WebAlurPengembalian): the refund
/// flow on the laptop, under the platform side nav with "Keuangan" active.
class WebAlurPengembalianScreen extends StatelessWidget {
  const WebAlurPengembalianScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return HalamanWeb(
      nav: const NavSamping(
        item: navPlatform,
        aktif: 1,
        pengguna: PenggunaNav(
          tebal: 'Meiske Lumentut',
          biasa: ' · Bendahara Jemaat',
        ),
      ),
      isi: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Inline 14 px link (line 20.3): the 44 px target overhangs it.
            const MarginNegatif(
              atas: 11.85,
              bawah: 11.85,
              child: Tautan(
                ke: 'WebPengembalian',
                cara: Cara.naik,
                child: Center(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: TautanTeks('Pengembalian', ukuran: 14),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Semantics(
                header: true,
                child: const Text(
                  'Alur · Pengembalian',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            Text(
              'Uang kembali dari pemasok, atau dikembalikan kepada donatur',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ],
        ),
        Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: const AlurPengembalianAlur(web: true),
          ),
        ),
      ],
    );
  }
}
