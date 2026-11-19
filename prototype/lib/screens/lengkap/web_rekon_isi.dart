import 'package:flutter/widgets.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'rekon_isi.dart';

/// Web · Rekonsiliasi: isi rekening koran dan cocok sebagian (spec 09).
class WebRekonIsiScreen extends StatefulWidget {
  const WebRekonIsiScreen({super.key});
  @override
  State<WebRekonIsiScreen> createState() => _WebRekonIsiState();
}

class _WebRekonIsiState extends State<WebRekonIsiScreen> with RekonIsiLogika {
  @override
  String get stem => 'WebRekonIsi';

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final b = bagian(context);
    return HalamanWeb(
      jabatanKosong: true,
      nav: const NavSamping(
        item: navKeuangan,
        aktif: 3,
        pengguna: PenggunaKeuangan(),
      ),
      isi: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The inline link keeps its line height; the 44 target overhangs.
            MarginNegatif(
              atas: 11,
              bawah: 11,
              child: Tautan(
                ke: 'WebRekonsiliasi',
                cara: Cara.naik,
                child: const Center(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: TautanTeks('Rekonsiliasi', ukuran: 14),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Semantics(
              header: true,
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Isi rekening koran '),
                    TextSpan(
                      text: '· Bank BNI ··4821 · Oktober 2026',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: c.tinta3,
                      ),
                    ),
                  ],
                ),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        BarisLentur(
          anak: [
            Lentur(
              dasar: 340,
              child: kolomRekon([b.isian, b.tahap, b.sisa, ...b.akhir], 16),
            ),
            Lentur(dasar: 480, tumbuh: 999, child: b.daftar),
          ],
        ),
      ],
    );
  }
}
