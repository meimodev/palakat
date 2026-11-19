import 'package:flutter/material.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import 'selesaikan_unit_isi.dart';

/// 87 · Hambatan dari unit (spec 21): the Bendahara Jemaat clears the two
/// Kolom 7 blockers of the October 2026 close. Five views in place.
class SelesaikanUnitScreen extends StatefulWidget {
  const SelesaikanUnitScreen({super.key});

  @override
  State<SelesaikanUnitScreen> createState() => _SelesaikanUnitState();
}

class _SelesaikanUnitState extends State<SelesaikanUnitScreen>
    with KeadaanSelesaikan {
  @override
  String get stem => 'SelesaikanUnit';

  @override
  Widget build(BuildContext context) {
    final blok = blokSelesaikan(context, this, web: false);
    return Material(
      type: MaterialType.transparency,
      child: LayarPonsel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const KepalaPonsel(
              judul: 'Hambatan dari unit',
              anakJudul:
                  'Supaya satu unit tidak menahan tutup buku seluruh Jemaat',
              kembaliKe: 'TutupBuku',
              labelKembali: 'Kembali ke Tutup buku',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  key: kunciIsi,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < blok.length; i++) ...[
                      if (i > 0) const SizedBox(height: 16),
                      blok[i],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
