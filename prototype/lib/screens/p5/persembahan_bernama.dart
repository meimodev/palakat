import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/keuangan/persembahan_bernama.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import 'persembahan_bernama_blok.dart';
import '../../app/layar.dart';

/// 93 · Persembahan bernama (spec 22): attaching a giver to a named envelope.
class PersembahanBernamaScreen extends ConsumerStatefulWidget {
  const PersembahanBernamaScreen({super.key});

  @override
  ConsumerState<PersembahanBernamaScreen> createState() =>
      _PersembahanBernamaScreenState();
}

class _PersembahanBernamaScreenState
    extends ConsumerState<PersembahanBernamaScreen>
    with KeadaanPemberi {
  @override
  Widget build(BuildContext context) {
    final s = ref.watch(sampulProvider);
    final i = ki(s);
    return Material(
      type: MaterialType.transparency,
      child: LayarPonsel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const KepalaPonsel(
              judul: 'Persembahan bernama',
              anakJudul: 'Nama pemberi dicatat hanya bila sampulnya bernama',
              kembaliKe: Layar.keuangan,
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
                    if (s != null) ...[
                      KartuSampul(s),
                      ...blokPemberi(
                        context,
                        ref,
                        s: s,
                        ki: i,
                        k: this,
                        ke: Layar.persembahanSaya,
                      ),
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
