import 'package:flutter/widgets.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'kesiapan_isi.dart';

/// Web · Pernyataan kesiapan per peruntukan.
class WebKesiapanScreen extends StatefulWidget {
  const WebKesiapanScreen({super.key});
  @override
  State<WebKesiapanScreen> createState() => _WebKesiapanScreenState();
}

class _WebKesiapanScreenState extends State<WebKesiapanScreen>
    with KesiapanLogika<WebKesiapanScreen> {
  @override
  String get stem => 'WebKesiapan';

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final bend = bendahara(context);
    // The breadcrumb line box (15 × 1.45, the page strut) inside its 44 px target.
    const sisa = (44 - 15 * 1.45) / 2;
    return HalamanWeb(
      nav: const NavSamping(
        item: navKeuangan,
        aktif: 4,
        pengguna: PenggunaKeuangan(ikutJabatanKosong: false),
      ),
      isi: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarginNegatif(
              atas: sisa,
              bawah: sisa,
              child: Tautan(
                ke: 'WebTutupBuku',
                cara: Cara.naik,
                child: const SizedBox(
                  height: 44,
                  child: Align(
                    widthFactor: 1,
                    child: TautanTeks('Bulan dan tutup buku', ukuran: 14),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Semantics(
                header: true,
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Pernyataan kesiapan '),
                      TextSpan(
                        text: '· Oktober 2026',
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
            ),
            Text(
              'Masuk sebagai ${siapaKesiapan(bend)}. Berlaku setelah Jemaat punya bendahara unit (Putaran 5).',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ],
        ),
        BarisLentur(
          jarak: 24,
          anak: [
            Lentur(dasar: 480, tumbuh: 999, child: daftarBaris(context, bend)),
            Lentur(
              dasar: 340,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (bend) kartuKeadaan(context) else introPenyiap(context),
                  const SizedBox(height: 14),
                  Text(
                    'Perubahan pada transaksi bulan itu membuat pernyataan perlu dinyatakan lagi. Yang dibebaskan tampil sebagai pengecualian di konfirmasi tutup buku.',
                    style: TextStyle(fontSize: 13, color: c.tinta3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
