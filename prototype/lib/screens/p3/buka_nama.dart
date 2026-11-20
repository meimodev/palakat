import 'package:flutter/widgets.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import 'buka_nama_bagian.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';

/// 67 · Tampilkan nama (pengecualian) (spec 18-wartaeditor.md, BukaNama).
class BukaNamaScreen extends StatelessWidget {
  const BukaNamaScreen({super.key});

  @override
  Widget build(BuildContext context) => LayarPonsel(
    // CSS puts half the leading above and half below each line.
    child: DefaultTextStyle.merge(
      style: const TextStyle(leadingDistribution: TextLeadingDistribution.even),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KepalaPonsel(
            judul: 'Tampilkan nama (pengecualian)',
            anakJudul: 'Hanya Sekretaris Jemaat, dengan alasan, dan tercatat',
            kembaliKe: Layar.wartaEdisi,
            paramKembali: {'edisi': belumDipindahId},
            labelKembali: 'Kembali ke Warta Jemaat',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: BukaNamaPapan(
                stem: 'BukaNama',
                ke: Layar.wartaEdisi,
                param: {'edisi': belumDipindahId},
                web: false,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
