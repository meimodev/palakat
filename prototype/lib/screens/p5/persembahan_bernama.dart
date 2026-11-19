import 'package:flutter/material.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import 'persembahan_bernama_blok.dart';

/// 93 · Persembahan bernama (spec 22): attaching a giver to a named envelope.
class PersembahanBernamaScreen extends StatefulWidget {
  const PersembahanBernamaScreen({super.key});

  @override
  State<PersembahanBernamaScreen> createState() =>
      _PersembahanBernamaScreenState();
}

class _PersembahanBernamaScreenState extends State<PersembahanBernamaScreen>
    with KeadaanPemberi {
  @override
  Widget build(BuildContext context) {
    final i = ki(context, 'PersembahanBernama');
    return Material(
      type: MaterialType.transparency,
      child: LayarPonsel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const KepalaPonsel(
              judul: 'Persembahan bernama',
              anakJudul: 'Nama pemberi dicatat hanya bila sampulnya bernama',
              kembaliKe: 'Main',
              labelKembali: 'Kembali ke Keuangan',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  key: kunciIsi,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: [
                    const KartuSampul(),
                    ...blokPemberi(
                      context,
                      ki: i,
                      pilih: pilih,
                      ke: 'PersembahanSaya',
                    ),
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
