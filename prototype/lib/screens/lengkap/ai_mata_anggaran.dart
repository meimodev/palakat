import 'package:flutter/material.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/prototipe_state.dart';
import 'ai_mata_anggaran_isi.dart';

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
      mode: context.tweak<String>('AIMataAnggaran', 'usulan'),
      ubah: setState,
      keBagi: 'Bagi',
    );
    final jk = context.prototipe.jabatanKosong;
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
        jabatanKosong: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const KepalaPonsel(
              judul: 'Belanja',
              anakJudul: 'Pilih Mata Anggaran',
              kembaliKe: 'Main',
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
