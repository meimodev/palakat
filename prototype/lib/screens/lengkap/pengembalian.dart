import 'package:flutter/material.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import 'pengembalian_isi.dart';
import '../../app/layar.dart';

/// 25 · Pengembalian (spec 07-kejadian.md): a refund saved as a Draf linked
/// to its original voucher, per kind (donatur / pemasok).
class PengembalianScreen extends StatefulWidget {
  const PengembalianScreen({super.key});

  @override
  State<PengembalianScreen> createState() => _PengembalianScreenState();
}

class _PengembalianScreenState extends State<PengembalianScreen> {
  final _k = KeadaanPengembalian();

  @override
  void dispose() {
    _k.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayarPonsel(
    layarKeuangan: true,
    child: ListenableBuilder(
      listenable: _k,
      builder: (context, _) {
        final c = _k.tab;
        final d = _k.jadi[c];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const KepalaPonsel(
              judul: 'Pengembalian',
              anakJudul: 'Terkait dengan transaksi asal',
              kembaliKe: Layar.keuangan,
              labelKembali: 'Kembali ke Beranda',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: chipJenis(_k, ponsel: true),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CatatanAturan(
                      c: c,
                      tautan: const Tautan(
                        ke: Layar.pengembalian,
                        child: SizedBox(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    KartuAsal(c: c),
                    if (d != null)
                      ...blokDraf(context, c, d)
                    else
                      for (final w in isianPengembalian(_k)) ...[
                        const SizedBox(height: 16),
                        w,
                      ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
