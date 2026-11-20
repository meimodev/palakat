import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'alur_unit_isi.dart';
import 'selesaikan_unit_isi.dart';
import '../../app/layar.dart';

/// Web · Alur · Keuangan unit (spec 23, WebAlurUnit): KeuanganUnit's body
/// on the laptop.
class WebAlurUnitScreen extends ConsumerStatefulWidget {
  const WebAlurUnitScreen({super.key});

  @override
  ConsumerState<WebAlurUnitScreen> createState() => _WebAlurUnitScreenState();
}

class _WebAlurUnitScreenState extends ConsumerState<WebAlurUnitScreen>
    with KeadaanSelesaikan, KeuanganUnitLogika {
  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final isi = blok(web: true);
    final bendahara = sisiBendahara;
    return Material(
      type: MaterialType.transparency,
      child: HalamanWeb(
        nav: const NavSamping(item: navPlatform, aktif: 1),
        isi: [
          Column(
            key: kunciIsi,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // A 44 px target drawn as the board's line box (15 × 1.45).
              MarginNegatif(
                atas: 11.125,
                bawah: 11.125,
                child: Tautan(
                  ke: Layar.keuangan,
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
                child: Text(
                  bendahara ? 'Keuangan unit' : 'Keuangan $namaUnit',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                bendahara
                    ? 'Bendahara unit membukukan; Bendahara Jemaat '
                          'menyelesaikan hambatan'
                    : 'Layar keuangan yang sama, terbatas pada peruntukan '
                          'dan Kas/Bank unit',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ],
          ),
          Align(
            alignment: AlignmentDirectional.topStart,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: kolomAlurUnit(isi, 16),
            ),
          ),
        ],
      ),
    );
  }
}
