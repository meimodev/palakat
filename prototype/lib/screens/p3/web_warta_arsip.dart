import 'package:flutter/widgets.dart';

import '../../app/layar.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'warta_arsip_bagian.dart';

/// Web · Warta Jemaat (spec 18, WebWartaArsip).
class WebWartaArsipScreen extends StatelessWidget {
  const WebWartaArsipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return HalamanWeb(
      nav: const NavSamping(item: navPlatform, aktif: 4),
      isi: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Inline 14/1.45 link (20.3 high) inside a 44 px target.
            const MarginNegatif(
              atas: 11.85,
              bawah: 10.4,
              child: Tautan(
                ke: Layar.beranda,
                cara: Cara.naik,
                child: SizedBox(
                  height: 44,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: 1,
                    child: TautanTeks('Beranda', ukuran: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Semantics(
              header: true,
              child: Text(
                'Warta Jemaat',
                style: PalakatText.judulHalaman.copyWith(color: c.tinta),
              ),
            ),
            Text(
              'Edisi yang sudah diterbitkan, persis seperti saat diterbitkan',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ],
        ),
        Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: const IsiWartaArsip(web: true),
          ),
        ),
      ],
    );
  }
}
