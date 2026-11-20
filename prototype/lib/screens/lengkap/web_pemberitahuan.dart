import 'package:flutter/material.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../widgets/tata_letak.dart';
import 'pemberitahuan.dart';

/// Web · Pemberitahuan: the phone board's list and switches in two columns
/// under the finance side nav (Beranda active).
class WebPemberitahuanScreen extends StatefulWidget {
  const WebPemberitahuanScreen({super.key});

  @override
  State<WebPemberitahuanScreen> createState() => _WebPemberitahuanScreenState();
}

class _WebPemberitahuanScreenState extends State<WebPemberitahuanScreen>
    with PemberitahuanLogika {
  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: HalamanWeb(
      layarKeuangan: true,
      nav: const NavSamping(item: navKeuangan, aktif: 0),
      isi: [
        Semantics(
          header: true,
          child: const Text(
            'Pemberitahuan',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),
        ),
        const CatatanPemberitahuan(),
        BarisLentur(
          anak: [
            Lentur(
              dasar: 460,
              tumbuh: 999,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  barisBelumDibaca(),
                  const SizedBox(height: 12),
                  kartuDaftar(),
                ],
              ),
            ),
            Lentur(
              dasar: 340,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  judulDitampilkan,
                  const SizedBox(height: 12),
                  kartuJenis(),
                  const SizedBox(height: 12),
                  keteranganJenis(context),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
