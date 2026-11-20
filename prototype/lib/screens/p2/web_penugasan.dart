import 'package:flutter/material.dart';

import '../../app/layar.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import 'inti_bagian.dart';
import 'penugasan.dart';

/// Web · Penugasan jabatan (screens/14): the "Pengaturan" page of the
/// platform nav, over the body shared with PenugasanScreen.
class WebPenugasanScreen extends StatelessWidget {
  const WebPenugasanScreen({super.key});

  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: HalamanWeb(
      nav: const NavSamping(item: navPlatform, aktif: 7),
      isi: [
        judulWeb(
          context,
          remah: remahWeb(Layar.beranda, 'Beranda'),
          judul: 'Penugasan jabatan',
          anakJudul: 'Siapa memegang jabatan apa, di unit mana, sejak kapan',
        ),
        Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: const IsiPenugasan(web: true),
          ),
        ),
      ],
    ),
  );
}
