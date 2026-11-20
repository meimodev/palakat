import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layar.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'impor_buku.dart';
import 'jemaat_bagian.dart';

/// Web · Impor buku anggota + WebAlurKeluarga (spec 19, 21): the book and
/// its rows on the left, the actions on the right. The family confirmation
/// is phone-only (README 7.1 rule 4).
class WebImporBukuScreen extends ConsumerStatefulWidget {
  const WebImporBukuScreen({super.key});

  @override
  ConsumerState<WebImporBukuScreen> createState() => _WebImporBukuScreenState();
}

class _WebImporBukuScreenState extends ConsumerState<WebImporBukuScreen>
    with ImporBukuLogika {
  Widget _kolom(List<Widget> anak) => kolomJemaat(anak, jarak: 12);

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final b = buku();
    return HalamanWeb(
      nav: const NavSamping(item: navPlatform, aktif: 5),
      isi: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The 44 target overhangs the 21.75 line of the 14 px link.
            const MarginNegatif(
              bawah: 44 - 21.75,
              child: Tautan(
                ke: Layar.dataAnggota,
                cara: Cara.naik,
                child: Padding(
                  padding: EdgeInsets.only(top: 1.1),
                  child: TautanTeks('Data jemaat', ukuran: 14),
                ),
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Impor buku anggota',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            ),
            Text(
              'Operator memasukkan buku anggota kertas; belum ada yang '
              'menjadi anggota aktif',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ],
        ),
        Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: b == null
                ? kotakKosong(context, 'Belum ada buku anggota yang ditampung.')
                : BarisLentur(
                    jarak: 28,
                    jarakBaris: 20,
                    anak: [
                      Lentur(dasar: 420, tumbuh: 1.3, child: _kolom(kiri(b))),
                      Lentur(dasar: 340, child: _kolom(kanan(b))),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
