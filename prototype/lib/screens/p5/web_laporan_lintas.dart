import 'package:flutter/widgets.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/prototipe_state.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'laporan_lintas.dart';

/// Web · Laporan (spec 22): LaporanLintas on the laptop, seen as the Ketua
/// Jemaat. Platform side nav with "Beranda" active, as drawn.
class WebLaporanLintasScreen extends StatelessWidget {
  const WebLaporanLintasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final keadaan = context.tweak<String>('WebLaporanLintas', 'keadaan');
    return HalamanWeb(
      nav: const NavSamping(
        item: navPlatform,
        aktif: 0,
        pengguna: PenggunaNav(
          tebal: 'Pdt. Lidya Rondonuwu',
          biasa: ' · Ketua Jemaat',
        ),
      ),
      isi: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 44 px target, laid out at the inline link's 14 × 1.45 height.
            MarginNegatif(
              atas: 11.85,
              bawah: 11.85,
              child: Tautan(
                ke: 'WebBerandaJabatan',
                cara: Cara.naik,
                child: const Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: 1,
                  child: TautanTeks('Beranda', ukuran: 14),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Semantics(
              header: true,
              child: const Text(
                'Laporan',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              'Dari data yang sah, disaring menurut jangkauan tiap jabatan',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: IsiLaporanLintas(keadaan: keadaan),
          ),
        ),
      ],
    );
  }
}
