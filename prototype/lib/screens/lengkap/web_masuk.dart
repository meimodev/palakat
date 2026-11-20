import 'package:flutter/widgets.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/tombol.dart';
import 'masuk_langkah.dart';

/// Web · Masuk dan menunggu verifikasi: the signed-out side nav (one item,
/// "Masuk") and the sign-in card centred in the main column.
class WebMasukScreen extends StatelessWidget {
  const WebMasukScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return HalamanWeb(
      tengah: true,
      nav: const NavSamping(
        item: navMasuk,
        aktif: 0,
        pengguna: Text('Belum masuk'),
      ),
      isi: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: EdgeInsets.all(context.jepit(24, 4, 40)),
                decoration: BoxDecoration(
                  color: c.permukaan,
                  border: Border.all(color: c.garis),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const LangkahMasuk(
                  stem: 'WebMasuk',
                  jarak: 32,
                  pemulihan: Tautan(
                    ke: 'WebPemulihan',
                    child: TautanMasuk(teksPemulihan),
                  ),
                  hubungkan: Tautan(
                    ke: 'WebAlurMasuk',
                    child: TautanMasuk(teksHubungkan),
                  ),
                  awal: Tombol(
                    teksAwal,
                    onPressed: null,
                    ke: 'WebAwal',
                    jenis: JenisTombol.kedua,
                    ukuran: UkuranTombol.sedang,
                  ),
                  beranda: Tombol(
                    'Buka Beranda',
                    onPressed: null,
                    ke: 'WebBeranda',
                    cara: Cara.ganti,
                  ),
                  terbatas: Tombol(
                    'Buka peruntukan Diakonia',
                    onPressed: null,
                    ke: 'WebTerbatas',
                    cara: Cara.ganti,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
