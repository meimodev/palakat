import 'package:flutter/material.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'alih_peruntukan.dart';

class WebAlihPeruntukanScreen extends StatefulWidget {
  const WebAlihPeruntukanScreen({super.key});

  @override
  State<WebAlihPeruntukanScreen> createState() =>
      _WebAlihPeruntukanScreenState();
}

class _WebAlihPeruntukanScreenState extends State<WebAlihPeruntukanScreen>
    with AlihPeruntukanIsi {
  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: HalamanWeb(
      jabatanKosong: true,
      nav: const NavSamping(
        item: navKeuangan,
        aktif: 1,
        pengguna: PenggunaKeuangan(),
      ),
      isi: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // A 44 px target around the 14 px breadcrumb (line box 20.3).
            const MarginNegatif(
              atas: 11.85,
              bawah: 11.85,
              child: Tautan(
                ke: 'WebTransaksi',
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
