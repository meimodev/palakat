import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import 'ai_mata_anggaran_isi.dart';
import '../../app/layar.dart';

/// 43 · Bantuan AI: usulan Mata Anggaran dan pembagian (spec 12).
class AIMataAnggaranScreen extends ConsumerStatefulWidget {
  const AIMataAnggaranScreen({super.key});

  @override
  ConsumerState<AIMataAnggaranScreen> createState() =>
      _AIMataAnggaranScreenState();
}

class _AIMataAnggaranScreenState extends ConsumerState<AIMataAnggaranScreen> {
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
      ref: ref,
      k: _k,
      ubah: (f) {
        if (mounted) setState(f);
      },
      keBagi: Layar.bagi,
    );
    final kosong = isi.kosong;
    final bagian = kosong != null
        ? [kosong]
        : [isi.draf, isi.uraian, isi.mataAnggaran, ?isi.panel, ?isi.abai];
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
