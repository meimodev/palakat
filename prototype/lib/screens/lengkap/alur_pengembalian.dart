import 'package:flutter/widgets.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import 'alur_pengembalian_alur.dart';

/// 102 · Alur · Pengembalian (screens/13, AlurPengembalian): pick the
/// original voucher, enter the refund, see it Dibukukan or Draf. The three
/// steps change under one fixed header; they are not routes.
class AlurPengembalianScreen extends StatelessWidget {
  const AlurPengembalianScreen({super.key});

  @override
  Widget build(BuildContext context) => const LayarPonsel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KepalaPonsel(
          judul: 'Alur · Pengembalian',
          anakJudul:
              'Uang kembali dari pemasok, atau dikembalikan kepada donatur',
          kembaliKe: 'Pengembalian',
          labelKembali: 'Kembali ke Pengembalian',
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: AlurPengembalianAlur(web: false),
          ),
        ),
      ],
    ),
  );
}
