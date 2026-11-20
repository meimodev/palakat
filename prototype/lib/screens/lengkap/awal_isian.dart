import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../providers/keuangan/pengaturan.dart';
import 'awal_isian_isi.dart';
import '../../app/layar.dart';

/// 24 · Pengaturan awal: identitas dan daftar (phone).
class AwalIsianScreen extends ConsumerStatefulWidget {
  const AwalIsianScreen({super.key});

  @override
  ConsumerState<AwalIsianScreen> createState() => _AwalIsianScreenState();
}

class _AwalIsianScreenState extends ConsumerState<AwalIsianScreen> {
  late final _k = KeadaanAwalIsian(ref.read(awalProvider));

  @override
  void dispose() {
    _k.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Pengaturan awal Jemaat',
            anakJudul: 'Identitas, Kas/Bank, peruntukan, Lingkup',
            kembaliKe: Layar.awal,
            labelKembali: 'Kembali ke langkah',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: ListenableBuilder(
                listenable: _k,
                builder: (context, _) => kolomAwal([
                  KartuIdentitas(_k),
                  DaftarAwal(_k),
                  ...akhirAwal(context, _k),
                ], 16),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
