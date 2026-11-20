import 'package:flutter/widgets.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import 'keadaan_umum.dart';
import '../../app/layar.dart';

/// Web · Keadaan umum (spec 17-keadaanumum.md), as the web and tablet guard
/// view.
class WebKeadaanUmumScreen extends StatelessWidget {
  const WebKeadaanUmumScreen({super.key, required this.penjaga});

  /// The guard reason the router passes (README 3.6).
  final Penjaga penjaga;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return HalamanWeb(
      nav: const NavSamping(item: navPlatform, aktif: 0),
      isi: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 44 px target around the 14 px breadcrumb, without growing the block.
            const MarginNegatif(
              atas: 11,
              bawah: 11,
              child: Tautan(
                ke: Layar.beranda,
                cara: Cara.naik,
                child: SizedBox(
                  height: 44,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: 1,
                    child: TautanTeks('Beranda', ukuran: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Semantics(
              header: true,
              child: const Text(
                'Keadaan umum',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              'Satu pola untuk semua modul',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ],
        ),
        Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: IsiKeadaanUmum(
              penjaga: penjaga,
              kembali: Tombol(
                'Kembali ke Beranda',
                onPressed: null,
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.sedang,
                ke: Layar.beranda,
                cara: Cara.naik,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
