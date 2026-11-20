import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'alih_peruntukan.dart';
import '../../app/layar.dart';

class WebAlihPeruntukanScreen extends ConsumerStatefulWidget {
  const WebAlihPeruntukanScreen({super.key});

  @override
  ConsumerState<WebAlihPeruntukanScreen> createState() =>
      _WebAlihPeruntukanScreenState();
}

class _WebAlihPeruntukanScreenState
    extends ConsumerState<WebAlihPeruntukanScreen>
    with AlihPeruntukanIsi {
  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: HalamanWeb(
      layarKeuangan: true,
      nav: const NavSamping(item: navKeuangan, aktif: 1),
      isi: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // A 44 px target around the 14 px breadcrumb (line box 20.3).
            const MarginNegatif(
              atas: 11.85,
              bawah: 11.85,
              child: Tautan(
                ke: Layar.transaksi,
                cara: Cara.naik,
                child: Align(
                  widthFactor: 1,
                  heightFactor: 1,
                  alignment: Alignment.centerLeft,
                  child: TautanTeks('Transaksi', ukuran: 14),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Semantics(
              header: true,
              child: const Text(
                'Alih peruntukan',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        BarisLentur(
          jarak: 24,
          anak: [
            Lentur(
              dasar: 440,
              tumbuh: 999,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: isian(),
              ),
            ),
            Lentur(
              dasar: 380,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 14,
                children: [kartuSaldo(), ...aksi()],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
