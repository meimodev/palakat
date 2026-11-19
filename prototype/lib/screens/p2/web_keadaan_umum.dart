import 'package:flutter/widgets.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import 'keadaan_umum.dart';

/// Web · Keadaan umum (spec 17-keadaanumum.md).
class WebKeadaanUmumScreen extends StatefulWidget {
  const WebKeadaanUmumScreen({super.key});

  @override
  State<WebKeadaanUmumScreen> createState() => _WebKeadaanUmumScreenState();
}

class _WebKeadaanUmumScreenState extends State<WebKeadaanUmumScreen>
    with KeadaanUmumState {
  @override
  String get stem => 'WebKeadaanUmum';

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    // HalamanWeb's page scroll picks this up, so a view change can jump to the top.
    return PrimaryScrollController(
      controller: gulir,
      automaticallyInheritForPlatforms: TargetPlatform.values.toSet(),
      child: HalamanWeb(
        nav: const NavSamping(
          item: navPlatform,
          aktif: 0,
          pengguna: PenggunaNav(
            tebal: 'Pnt. Hendrik Rumagit',
            biasa: ' · Penatua Kolom 7',
          ),
        ),
        isi: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 44 px target around the 14 px breadcrumb, without growing the block.
              MarginNegatif(
                atas: 11.8,
                bawah: 11.8,
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
                keadaan: keadaan,
                onCobaLagi: () => pilih('Memuat'),
                kembali: const Tombol(
                  'Kembali ke Beranda',
                  onPressed: null,
                  jenis: JenisTombol.kedua,
                  ukuran: UkuranTombol.sedang,
                  ke: 'WebBerandaJabatan',
                  cara: Cara.naik,
                ),
                masuk: const Tombol(
                  'Masuk lagi',
                  onPressed: null,
                  jenis: JenisTombol.tinta,
                  ke: 'WebAlurMasuk',
                  cara: Cara.ganti,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
