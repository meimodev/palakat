import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layar.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import 'buka_nama_bagian.dart';
import 'warta_arsip_bagian.dart';

/// 67 · Tampilkan nama (pengecualian) (spec 18, BukaNama).
class BukaNamaScreen extends ConsumerWidget {
  const BukaNamaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => LayarPonsel(
    // CSS puts half the leading above and half below each line.
    child: Material(
      type: MaterialType.transparency,
      child: DefaultTextStyle.merge(
        style: const TextStyle(
          leadingDistribution: TextLeadingDistribution.even,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KepalaPonsel(
              judul: 'Tampilkan nama (pengecualian)',
              anakJudul: 'Hanya Sekretaris Jemaat, dengan alasan, dan tercatat',
              kembaliKe: Layar.wartaEdisi,
              paramKembali: {'edisi': edisiDariRute(context)},
              labelKembali: 'Kembali ke Warta Jemaat',
            ),
            const Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: BukaNamaPapan(web: false),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
