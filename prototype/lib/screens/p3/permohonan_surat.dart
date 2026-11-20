import 'package:flutter/material.dart';

import '../../app/layar.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import 'permohonan_surat_bagian.dart';

/// 64 · Permohonan surat + 70 · AlurSurat (README 7.1): letter requests.
class PermohonanSuratScreen extends StatelessWidget {
  const PermohonanSuratScreen({super.key});

  @override
  Widget build(BuildContext context) => const LayarPonsel(
    child: Material(
      type: MaterialType.transparency,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KepalaPonsel(
            judul: 'Permohonan surat',
            anakJudul: 'Atestasi dan surat keterangan untuk satu anggota',
            kembaliKe: Layar.dokumenGereja,
            labelKembali: 'Kembali ke Dokumen gereja',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: IsiSurat(web: false),
            ),
          ),
        ],
      ),
    ),
  );
}
