import 'package:flutter/material.dart';

import '../../app/layar.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import 'pengumuman_bagian.dart';

/// 65 · Pengumuman (spec 17), with AlurWarta's announcement form.
class PengumumanScreen extends StatelessWidget {
  const PengumumanScreen({super.key});

  @override
  Widget build(BuildContext context) => const LayarPonsel(
    child: Material(
      type: MaterialType.transparency,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KepalaPonsel(
            judul: 'Pengumuman',
            anakJudul: 'Berdiri sendiri; Warta Jemaat mengambil dari sini',
            kembaliKe: Layar.beranda,
            labelKembali: 'Kembali ke Beranda',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: IsiPengumuman(web: false),
            ),
          ),
        ],
      ),
    ),
  );
}
