import 'package:flutter/widgets.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import 'alur_surat_alur.dart';
import '../../app/layar.dart';

/// 70 · Alur · Permohonan surat (screens/19-alursurat.md).
class AlurSuratScreen extends StatelessWidget {
  const AlurSuratScreen({super.key});

  @override
  Widget build(BuildContext context) => const LayarPonsel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KepalaPonsel(
          judul: 'Alur · Permohonan surat',
          anakJudul:
              'Dari permohonan anggota sampai surat diterbitkan atau tidak',
          kembaliKe: Layar.surat,
          labelKembali: 'Kembali ke Permohonan surat',
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: AlurSuratIsi(),
          ),
        ),
      ],
    ),
  );
}
