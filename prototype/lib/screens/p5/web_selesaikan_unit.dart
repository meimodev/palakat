import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'selesaikan_unit_isi.dart';
import '../../app/layar.dart';

/// Web · Hambatan dari unit (spec 21): SelesaikanUnit on the laptop, with
/// the platform side nav ("Keuangan" active).
class WebSelesaikanUnitScreen extends ConsumerStatefulWidget {
  const WebSelesaikanUnitScreen({super.key});

  @override
  ConsumerState<WebSelesaikanUnitScreen> createState() =>
      _WebSelesaikanUnitState();
}

class _WebSelesaikanUnitState extends ConsumerState<WebSelesaikanUnitScreen>
    with KeadaanSelesaikan {
  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final blok = blokSelesaikan(context, this, web: true);
    return Material(
      type: MaterialType.transparency,
      child: HalamanWeb(
        nav: const NavSamping(item: navPlatform, aktif: 1),
        isi: [
          Column(
            key: kunciIsi,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The 14 px <a> sits on the div's 15 × 1.45 strut: a 21.75 line
              // box with the text 1.1 down; the 44 target overhangs it.
              const MarginNegatif(
                atas: 10.75,
                bawah: 11.5,
                child: Tautan(
                  ke: Layar.tutupBuku,
                  cara: Cara.naik,
                  child: Center(
                    widthFactor: 1,
                    heightFactor: 1,
                    child: TautanTeks('Tutup buku', ukuran: 14),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Semantics(
                header: true,
                child: const Text(
                  'Hambatan dari unit',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                'Supaya satu unit tidak menahan tutup buku seluruh Jemaat',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < blok.length; i++) ...[
                    if (i > 0) const SizedBox(height: 16),
                    blok[i],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
