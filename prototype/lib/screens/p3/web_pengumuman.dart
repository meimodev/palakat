import 'package:flutter/widgets.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'pengumuman_bagian.dart';

/// Web · Pengumuman (17-keadaanumum.md): as Pengumuman, with a table for the
/// list and a member preview beside the draft.
class WebPengumumanScreen extends StatefulWidget {
  const WebPengumumanScreen({super.key});

  @override
  State<WebPengumumanScreen> createState() => _WebPengumumanScreenState();
}

class _WebPengumumanScreenState extends State<WebPengumumanScreen>
    with KeadaanPengumuman {
  @override
  String get stem => 'WebPengumuman';

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final k = keadaan(context);
    final isi = switch (k) {
      'Daftar' => [const TabelPengumuman(), tulisPengumuman(pilih)],
      'Draf' => [
        BarisLentur(
          jarak: 28,
          jarakBaris: 20,
          anak: [
            Lentur(
              dasar: 420,
              tumbuh: 1.3,
              child: KolomJarak(
                jarak: 12,
                anak: drafPengumuman(context, pilih),
              ),
            ),
            Lentur(
              dasar: 340,
              child: KolomJarak(jarak: 12, anak: pratinjauPengumuman(context)),
            ),
          ],
        ),
      ],
      _ => viewPengumuman(context, k, pilih),
    };
    return HalamanWeb(
      nav: const NavSamping(
        item: navPlatform,
        aktif: 3,
        pengguna: PenggunaNav(
          tebal: 'Olvie Pangemanan',
          biasa: ' · Sekretaris Jemaat',
        ),
      ),
      isi: [
        Column(
          key: kunciAtas,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The 44 px target overhangs the line box (the div's 15 px strut).
            MarginNegatif(
              atas: (44 - 15 * 1.45) / 2,
              bawah: (44 - 15 * 1.45) / 2,
              child: Tautan(
                ke: 'WebBerandaJabatan',
                cara: Cara.naik,
                child: const Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: 1,
                  heightFactor: 1,
                  child: TautanTeks('Beranda', ukuran: 14),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Semantics(
              header: true,
              child: const Text(
                'Pengumuman',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              'Berdiri sendiri; Warta Jemaat mengambil dari sini',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ],
        ),
        Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: KolomJarak(jarak: 16, anak: isi),
          ),
        ),
      ],
    );
  }
}
