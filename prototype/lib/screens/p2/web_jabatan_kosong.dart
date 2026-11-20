import 'package:flutter/material.dart';

import '../../app/layar.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import 'inti_bagian.dart';
import 'jabatan_kosong.dart';

/// Web · Menjalankan jabatan kosong + Web · Alur (screens/14, screens/15),
/// over the body shared with JabatanKosongScreen. "Pengaturan" is active, as
/// on WebAlurJabatanKosong.
class WebJabatanKosongScreen extends StatelessWidget {
  const WebJabatanKosongScreen({super.key});

  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: HalamanWeb(
      nav: const NavSamping(item: navPlatform, aktif: 7),
      isi: [
        judulWeb(
          context,
          remah: remahWeb(Layar.beranda, 'Beranda'),
          judul: 'Menjalankan jabatan kosong',
          anakJudul:
              'Operator menjalankan jabatan kosong sampai ada pemegangnya',
        ),
        Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: const IsiJabatanKosong(web: true),
          ),
        ),
      ],
    ),
  );
}
