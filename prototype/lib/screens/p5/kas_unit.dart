import 'package:flutter/material.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import 'kas_unit_isi.dart';

/// 99 · Alur · Kas/Bank unit (spec 23-alurunit.md, KasUnit).
class KasUnitScreen extends StatelessWidget {
  const KasUnitScreen({super.key});

  @override
  Widget build(BuildContext context) => const Material(
    type: MaterialType.transparency,
    child: LayarPonsel(
      child: CssLeading(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KepalaPonsel(
              judul: 'Alur · Kas/Bank unit',
              anakJudul: 'Menetapkan Kas/Bank yang dikelola sebuah unit',
              kembaliKe: 'Lainnya',
              labelKembali: 'Kembali ke Pengaturan',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: KasUnitIsi(),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
