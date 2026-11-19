import 'package:flutter/widgets.dart';

import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/tombol.dart';
import 'masuk_langkah.dart';

/// 27 · Masuk dan menunggu verifikasi: a bare sign-in page (no header, no
/// tab bar), `permukaan` over the `kertas` root.
class MasukScreen extends StatelessWidget {
  const MasukScreen({super.key});

  @override
  Widget build(BuildContext context) => LayarPonsel(
    child: ColoredBox(
      color: context.warna.permukaan,
      child: const SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 72, 24, 24),
        child: LangkahMasuk(
          stem: 'Masuk',
          jarak: 36,
          pemulihan: Tautan(ke: 'Pemulihan', child: TautanMasuk(teksPemulihan)),
          hubungkan: Tautan(ke: 'AlurMasuk', child: TautanMasuk(teksHubungkan)),
          awal: Tombol(
            teksAwal,
            onPressed: null,
            ke: 'Awal',
            jenis: JenisTombol.kedua,
            ukuran: UkuranTombol.sedang,
          ),
          // go: entering the app; Back must not return to the code step.
          beranda: Tombol(
            'Buka Beranda',
            onPressed: null,
            ke: 'Main',
            cara: Cara.ganti,
          ),
          terbatas: Tombol(
            'Buka peruntukan Diakonia',
            onPressed: null,
            ke: 'Terbatas',
            cara: Cara.ganti,
          ),
        ),
      ),
    ),
  );
}
