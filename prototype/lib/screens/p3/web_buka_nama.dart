import 'package:flutter/widgets.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'buka_nama_bagian.dart';

/// Web · Tampilkan nama (pengecualian) (spec 18-wartaeditor.md, WebBukaNama).
class WebBukaNamaScreen extends StatelessWidget {
  const WebBukaNamaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return HalamanWeb(
      nav: const NavSamping(
        item: navPlatform,
        aktif: 4,
        pengguna: PenggunaNav(
          tebal: 'Olvie Pangemanan',
          biasa: ' · Sekretaris Jemaat',
        ),
      ),
      isi: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The 44 px target around the 14 px breadcrumb keeps its line.
            const MarginNegatif(
              atas: 12,
              bawah: 12,
              child: Tautan(
                ke: 'WebWartaEditor',
                cara: Cara.naik,
                child: Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: 1,
                  heightFactor: 1,
                  child: TautanTeks('Warta Jemaat', ukuran: 14),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Semantics(
              header: true,
              child: const Text(
                'Tampilkan nama (pengecualian)',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              'Hanya Sekretaris Jemaat, dengan alasan, dan tercatat',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ],
        ),
        const BukaNamaPapan(
          stem: 'WebBukaNama',
          ke: 'WebWartaEditor',
          web: true,
        ),
      ],
    );
  }
}
