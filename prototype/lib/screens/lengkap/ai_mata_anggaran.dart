import 'package:flutter/material.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import 'ai_mata_anggaran_isi.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';

/// 43 · Bantuan AI: usulan Mata Anggaran dan pembagian (spec 12).
class AIMataAnggaranScreen extends StatefulWidget {
  const AIMataAnggaranScreen({super.key});

  @override
  State<AIMataAnggaranScreen> createState() => _AIMataAnggaranScreenState();
}

class _AIMataAnggaranScreenState extends State<AIMataAnggaranScreen> {
  final _k = KeadaanUsulanMA();

  @override
  void dispose() {
    _k.uraian.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isi = IsiUsulanMA(
      context: context,
      k: _k,
      mode: belumDipindah<String>('Satu baris'),
      ubah: setState,
      keBagi: Layar.bagi,
    );
    final jk = belumDipindah(false);
    final bagian = [
      isi.draf,
      isi.uraian,
      isi.mataAnggaran(jk),
      ?isi.panel,
      ?isi.abai,
    ];
    // Material outside LayarPonsel: its DefaultTextStyle must win.
    return Material(
      type: MaterialType.transparency,
      child: LayarPonsel(
        layarKeuangan: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const KepalaPonsel(
              judul: 'Belanja',
              anakJudul: 'Pilih Mata Anggaran',
              kembaliKe: Layar.keuangan,
              labelKembali: 'Kembali ke isian',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (i, b) in bagian.indexed) ...[
                      if (i > 0) const SizedBox(height: 16),
                      b,
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
