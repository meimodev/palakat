import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layar.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import 'alur_unit_isi.dart';
import 'selesaikan_unit_isi.dart';

/// KeuanganUnit + AlurUnit (spec 23): the unit treasurer's money, or the
/// church Bendahara clearing unit blockers.
class KeuanganUnitScreen extends ConsumerStatefulWidget {
  const KeuanganUnitScreen({super.key});

  @override
  ConsumerState<KeuanganUnitScreen> createState() => _KeuanganUnitState();
}

class _KeuanganUnitState extends ConsumerState<KeuanganUnitScreen>
    with KeadaanSelesaikan, KeuanganUnitLogika {
  @override
  Widget build(BuildContext context) {
    final isi = blok(web: false);
    final bendahara = sisiBendahara;
    return Material(
      type: MaterialType.transparency,
      child: LayarPonsel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KepalaPonsel(
              judul: bendahara ? 'Keuangan unit' : 'Keuangan $namaUnit',
              anakJudul: bendahara
                  ? 'Bendahara unit membukukan; Bendahara Jemaat '
                        'menyelesaikan hambatan'
                  : 'Layar keuangan yang sama, terbatas pada peruntukan dan '
                        'Kas/Bank unit',
              kembaliKe: bendahara ? Layar.keuangan : Layar.beranda,
              labelKembali: bendahara
                  ? 'Kembali ke Keuangan'
                  : 'Kembali ke Beranda',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: KeyedSubtree(
                  key: kunciIsi,
                  child: kolomAlurUnit(isi, 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
