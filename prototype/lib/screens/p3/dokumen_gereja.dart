import 'package:flutter/widgets.dart';

import '../../app/layar.dart';
import '../../shell/kepala_ponsel.dart';
import 'dokumen_gereja_isi.dart';

/// 62 · Dokumen gereja (spec 17) + AlurDokumen's list (README 7.1): the
/// church document archive on the phone. It is the root page of the
/// `dokumenGereja` shell ([AlurDokumenKendali] gives it its LayarPonsel).
class DokumenGerejaScreen extends StatelessWidget {
  const DokumenGerejaScreen({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      KepalaPonsel(
        judul: 'Dokumen gereja',
        anakJudul:
            'Arsip dokumen seluruh Jemaat yang dipelihara Sekretaris Jemaat',
        kembaliKe: Layar.beranda,
        labelKembali: 'Kembali ke Beranda',
      ),
      Expanded(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: IsiDokumenGereja(web: false),
        ),
      ),
    ],
  );
}
