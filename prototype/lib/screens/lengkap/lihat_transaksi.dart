import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/keuangan/laporan.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../widgets/chip_pilihan.dart';
import 'lihat_transaksi_rinci.dart';
import '../../app/layar.dart';

/// 42 · Lihat transaksi di balik angka laporan (phone).
class LihatTransaksiScreen extends ConsumerStatefulWidget {
  const LihatTransaksiScreen({super.key});

  @override
  ConsumerState<LihatTransaksiScreen> createState() =>
      _LihatTransaksiScreenState();
}

class _LihatTransaksiScreenState extends ConsumerState<LihatTransaksiScreen> {
  String? _pilih;

  @override
  Widget build(BuildContext context) {
    final angka = ref.watch(angkaLaporanProvider);
    final pilih = angka.any((x) => x.id == _pilih)
        ? _pilih!
        : angka.firstOrNull?.id ?? '';
    return Material(
      type: MaterialType.transparency,
      child: LayarPonsel(
        layarKeuangan: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const KepalaPonsel(
              judul: 'Lihat transaksi',
              anakJudul: 'Dari angka di laporan',
              kembaliKe: Layar.laporan,
              labelKembali: 'Kembali ke Laporan',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
              child: ChipPilihan<String>(
                pilihan: [for (final x in angka) (nilai: x.id, teks: x.pendek)],
                terpilih: pilih,
                onPilih: (v) => setState(() => _pilih = v),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: RinciAngkaLaporan(pilih: pilih, ke: Layar.pilihBulan),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
