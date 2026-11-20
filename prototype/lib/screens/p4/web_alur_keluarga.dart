import 'package:flutter/widgets.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'alur_keluarga_bersama.dart';

/// Web · Alur · Buku anggota: AlurKeluarga on the laptop, in two columns.
class WebAlurKeluargaScreen extends StatefulWidget {
  const WebAlurKeluargaScreen({super.key});

  @override
  State<WebAlurKeluargaScreen> createState() => _WebAlurKeluargaScreenState();
}

class _WebAlurKeluargaScreenState extends State<WebAlurKeluargaScreen>
    with AlurKeluargaLogika {
  Widget _duaKolom(List<Widget> kiri, List<Widget> kanan) => BarisLentur(
    jarak: 28,
    jarakBaris: 20,
    anak: [
      Lentur(dasar: 420, tumbuh: 1.3, child: kolomAlur(kiri, 12)),
      Lentur(dasar: 340, child: kolomAlur(kanan, 12)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final blok = [
      ?banner,
      if (op && st.isEmpty) _duaKolom(bukuKiri, bukuKanan),
      if (op && st.isNotEmpty) _duaKolom(konfKiri, konfKanan),
      if (!op) ...penatua,
      ?riwayat,
    ];
    return denganAlat(
      'WebAlurKeluarga',
      HalamanWeb(
        nav: const NavSamping(
          item: navPlatform,
          aktif: 5,
          pengguna: PenggunaNav(tebal: 'Yanti Sumual', biasa: ' · Operator'),
        ),
        isi: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MarginNegatif(
                // The 14 px <a> sits on the div's 15 × 1.45 strut: a 21.75 line
                // box with the text 1.1 down; the 44 target overhangs it.
                atas: 10.75,
                bawah: 11.5,
                child: Tautan(
                  ke: 'WebDataAnggota',
                  cara: Cara.naik,
                  child: Center(
                    widthFactor: 1,
                    child: TautanTeks('Data jemaat', ukuran: 14),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Semantics(
                header: true,
                child: const Text(
                  'Alur · Buku anggota',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                'Operator mengimpor; keluarga mengonfirmasi; Penatua memverifikasi',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: kolomAlur(blok, 16),
            ),
          ),
        ],
      ),
    );
  }
}
