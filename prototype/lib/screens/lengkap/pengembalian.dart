import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/keuangan/pengembalian.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import 'pengembalian_isi.dart';
import '../../app/layar.dart';

/// 25 · Pengembalian (spec 07-kejadian.md, with AlurPengembalian merged in):
/// pick the original voucher, enter the refund, see it Draf or Dibukukan,
/// linked to the original (RD04).
class PengembalianScreen extends ConsumerStatefulWidget {
  const PengembalianScreen({super.key});

  @override
  ConsumerState<PengembalianScreen> createState() => _PengembalianScreenState();
}

class _PengembalianScreenState extends ConsumerState<PengembalianScreen> {
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
        final a = _k.asalId == null
            ? null
            : ref.watch(asalPengembalianProvider(_k.asalId!));
        final isi = <Widget>[
          if (a == null)
            ...daftarAsal(
              context,
              _k,
              ref.watch(daftarAsalPengembalianProvider),
            )
          else ...[
            CatatanAturan(c: JenisPengembalian.dari(a)),
            KartuAsal(a: a),
            if (_k.hasilId != null)
              ...blokDraf(context, ref, _k, a)
            else
              ...isianPengembalian(ref, _k, a),
          ],
        ];
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
                    for (final (i, w) in isi.indexed) ...[
                      if (i > 0 && w is! SizedBox) const SizedBox(height: 16),
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
