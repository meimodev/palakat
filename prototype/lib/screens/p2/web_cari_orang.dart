import 'package:flutter/material.dart';

import '../../app/layar.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import 'cari_orang.dart';
import 'inti_bagian.dart';

/// Web · Cari orang + Web · Alur · Memulihkan akun anggota (screens/15,
/// screens/16), over the body shared with CariOrangScreen.
class WebCariOrangScreen extends StatelessWidget {
  const WebCariOrangScreen({super.key});

  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: HalamanWeb(
      nav: const NavSamping(item: navPlatform, aktif: 0),
      isi: [
        judulWeb(
          context,
          remah: remahWeb(Layar.beranda, 'Beranda'),
          judul: 'Cari orang',
          anakJudul:
              'Hasil hanya dari modul aktif dan dari yang boleh Anda '
              'lihat',
        ),
        Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: const IsiCariOrang(web: true),
          ),
        ),
      ],
    ),
  );
}
