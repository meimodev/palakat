import 'package:flutter/widgets.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'alur_surat_alur.dart';
import '../../app/layar.dart';

/// Web · Alur · Permohonan surat (screens/19-alursurat.md).
class WebAlurSuratScreen extends StatelessWidget {
  const WebAlurSuratScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return HalamanWeb(
      nav: const NavSamping(item: navPlatform, aktif: 2),
      isi: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Inline 14/1.45 link (20.3 high) inside a 44 px target; the line
            // box keeps the 15/1.45 strut (21.75), so 1.45 more below the text.
            const MarginNegatif(
              atas: 11.85,
              bawah: 10.4,
              child: Tautan(
                ke: Layar.surat,
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
