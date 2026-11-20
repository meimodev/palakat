import 'package:flutter/widgets.dart';

import '../../app/layar.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'data_ganda.dart';

/// Web · Kemungkinan data ganda: [IsiDataGanda] beside the platform side nav
/// ("Data jemaat" active).
class WebDataGandaScreen extends StatelessWidget {
  const WebDataGandaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return HalamanWeb(
      nav: const NavSamping(item: navPlatform, aktif: 5),
      isi: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The 14 px link on the div's 21.75 strut; the 44 target
            // overhangs it.
            const MarginNegatif(
              atas: 10.75,
              bawah: 11.5,
              child: Tautan(
                ke: Layar.dataAnggota,
                cara: Cara.naik,
                child: Center(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: TautanTeks('Data jemaat', ukuran: 14),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Semantics(
              header: true,
              child: const Text(
                'Kemungkinan data ganda',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              'Bandingkan dulu; tidak pernah digabung sendiri',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ],
        ),
        Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: const IsiDataGanda(),
          ),
        ),
      ],
    );
  }
}
