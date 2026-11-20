import 'package:flutter/widgets.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'laporan_lintas.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';

/// Web · Laporan (spec 22): LaporanLintas on the laptop, seen as the Ketua
/// Jemaat. Platform side nav with "Beranda" active, as drawn.
class WebLaporanLintasScreen extends StatelessWidget {
  const WebLaporanLintasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final keadaan = belumDipindah<String>('Seluruh Jemaat');
    return HalamanWeb(
      nav: const NavSamping(item: navPlatform, aktif: 0),
      isi: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // A 44 px target drawn as the board's line box (15 × 1.45).
            MarginNegatif(
              atas: 11.125,
              bawah: 11.125,
              child: Tautan(
                ke: Layar.beranda,
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
