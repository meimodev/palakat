import 'package:flutter/widgets.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import 'buka_nama_bagian.dart';

/// 67 · Tampilkan nama (pengecualian) (spec 18-wartaeditor.md, BukaNama).
class BukaNamaScreen extends StatelessWidget {
  const BukaNamaScreen({super.key});

  @override
  Widget build(BuildContext context) => const LayarPonsel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KepalaPonsel(
          judul: 'Tampilkan nama (pengecualian)',
          anakJudul: 'Hanya Sekretaris Jemaat, dengan alasan, dan tercatat',
          kembaliKe: 'WartaEditor',
          labelKembali: 'Kembali ke Warta Jemaat',
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: BukaNamaPapan(
              stem: 'BukaNama',
              ke: 'WartaEditor',
              web: false,
            ),
          ),
        ),
      ],
    ),
  );
}
