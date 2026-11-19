import 'package:flutter/material.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../widgets/chip_pilihan.dart';
import 'lihat_transaksi_rinci.dart';

/// 42 · Lihat transaksi di balik angka laporan (phone).
class LihatTransaksiScreen extends StatefulWidget {
  const LihatTransaksiScreen({super.key});

  @override
  State<LihatTransaksiScreen> createState() => _LihatTransaksiScreenState();
}

class _LihatTransaksiScreenState extends State<LihatTransaksiScreen> {
  String _pilih = 'atk';

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: LayarPonsel(
        jabatanKosong: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const KepalaPonsel(
              judul: 'Lihat transaksi',
              anakJudul: 'Dari angka di laporan',
              kembaliKe: 'Laporan',
              labelKembali: 'Kembali ke Laporan',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
              child: ChipPilihan<String>(
                pilihan: [
                  for (final x in angkaLaporanOktober)
                    (nilai: x.id, teks: x.pendek),
                ],
                terpilih: _pilih,
                onPilih: (v) => setState(() => _pilih = v),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: RinciAngkaLaporan(pilih: _pilih, ke: 'PilihBulan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
