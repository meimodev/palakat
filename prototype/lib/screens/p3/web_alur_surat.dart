import 'package:flutter/widgets.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'alur_surat_alur.dart';

/// Web · Alur · Permohonan surat (screens/19-alursurat.md).
class WebAlurSuratScreen extends StatelessWidget {
  const WebAlurSuratScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return HalamanWeb(
      nav: const NavSamping(
        item: navPlatform,
        aktif: 2,
        pengguna: PenggunaNav(
          tebal: 'Olvie Pangemanan',
          biasa: ' · Sekretaris Jemaat',
        ),
      ),
      isi: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The inline 14 px link keeps its line height; the 44 target
            // overhangs it, as the board's `<a>` takes no extra room.
            const MarginNegatif(
              atas: 11.85,
              bawah: 11.85,
              child: Tautan(
                ke: 'WebPermohonanSurat',
                cara: Cara.naik,
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: 1,
                  child: TautanTeks('Permohonan surat', ukuran: 14),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Semantics(
              header: true,
              child: const Text(
                'Alur · Permohonan surat',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              'Dari permohonan anggota sampai surat diterbitkan atau tidak',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ],
        ),
        Align(
          alignment: AlignmentDirectional.topStart,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: const AlurSuratIsi(web: true),
          ),
        ),
      ],
    );
  }
}
