import 'package:flutter/widgets.dart';

import '../../app/layar.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import 'warta_arsip_bagian.dart';

/// 68 · Warta Jemaat (spec 18, WartaArsip).
class WartaArsipScreen extends StatelessWidget {
  const WartaArsipScreen({super.key});

  @override
  Widget build(BuildContext context) => const LayarPonsel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KepalaPonsel(
          judul: 'Warta Jemaat',
          anakJudul:
              'Edisi yang sudah diterbitkan, persis seperti saat diterbitkan',
          kembaliKe: Layar.beranda,
          labelKembali: 'Kembali ke Beranda',
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: IsiWartaArsip(web: false),
          ),
        ),
      ],
    ),
  );
}
