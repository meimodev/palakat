import 'package:flutter/material.dart';

import '../../app/layar.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'permohonan_surat_bagian.dart';

/// Web · Permohonan surat + WebAlurSurat (README 7.1).
class WebPermohonanSuratScreen extends StatelessWidget {
  const WebPermohonanSuratScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Material(
      type: MaterialType.transparency,
      child: HalamanWeb(
        nav: const NavSamping(item: navPlatform, aktif: 2),
        isi: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Inline breadcrumb in the 15 px page text (a 22 px line box):
              // the 44 px target overhangs it by 11 above and below.
              const MarginNegatif(
                atas: 11,
                bawah: 11,
                child: Tautan(
                  ke: Layar.dokumenGereja,
                  cara: Cara.naik,
                  child: SizedBox(
                    height: 44,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: 1,
                      child: TautanTeks('Dokumen gereja', ukuran: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Semantics(
                header: true,
                child: const Text(
                  'Permohonan surat',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                'Atestasi dan surat keterangan untuk satu anggota',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: const IsiSurat(web: true),
            ),
          ),
        ],
      ),
    );
  }
}
