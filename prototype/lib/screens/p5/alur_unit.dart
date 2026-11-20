import 'package:flutter/material.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import 'alur_unit_isi.dart';
import '../../app/layar.dart';

/// 94 · Alur · Keuangan unit (spec 23, AlurUnit).
class AlurUnitScreen extends StatefulWidget {
  const AlurUnitScreen({super.key});

  @override
  State<AlurUnitScreen> createState() => _AlurUnitScreenState();
}

class _AlurUnitScreenState extends State<AlurUnitScreen>
    with AlurUnitLogika<AlurUnitScreen> {
  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Alur · Keuangan unit',
            anakJudul:
                'Bendahara Kolom 7 membukukan; Bendahara Jemaat '
                'menyelesaikan hambatan',
            kembaliKe: Layar.keuangan,
            labelKembali: 'Kembali ke Keuangan',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: KeyedSubtree(
                key: kunciAtas,
                child: kolomAlurUnit(blok(web: false), 16),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
