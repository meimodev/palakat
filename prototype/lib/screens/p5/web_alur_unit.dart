import 'package:flutter/material.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'alur_unit_isi.dart';

/// Web · Alur · Keuangan unit (spec 23, WebAlurUnit).
class WebAlurUnitScreen extends StatefulWidget {
  const WebAlurUnitScreen({super.key});

  @override
  State<WebAlurUnitScreen> createState() => _WebAlurUnitScreenState();
}

class _WebAlurUnitScreenState extends State<WebAlurUnitScreen>
    with AlurUnitLogika<WebAlurUnitScreen> {
  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return alat(
      'WebAlurUnit',
      Material(
        type: MaterialType.transparency,
        child: HalamanWeb(
          nav: const NavSamping(
            item: navPlatform,
            aktif: 1,
            // Static: it does not follow "Dilihat sebagai".
            pengguna: PenggunaNav(
              tebal: 'Meiske Lumentut',
              biasa: ' · Bendahara Jemaat',
            ),
          ),
          isi: [
            Column(
              key: kunciAtas,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Inline link: a 44 target that keeps the line's height.
                MarginNegatif(
                  atas: 12,
                  bawah: 12,
                  child: Tautan(
                    ke: 'WebBeranda',
                    cara: Cara.naik,
                    child: const Align(
                      widthFactor: 1,
                      heightFactor: 1,
                      child: TautanTeks('Keuangan', ukuran: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Semantics(
                  header: true,
                  child: const Text(
                    'Alur · Keuangan unit',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  'Bendahara Kolom 7 membukukan; Bendahara Jemaat '
                  'menyelesaikan hambatan',
                  style: TextStyle(fontSize: 14, color: c.tinta2),
                ),
              ],
            ),
            Align(
              alignment: AlignmentDirectional.topStart,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: kolomAlurUnit(blok(web: true), 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
