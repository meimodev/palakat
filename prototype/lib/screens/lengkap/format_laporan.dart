import 'package:flutter/material.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import 'format_laporan_bagian.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';

/// 23 · Persetujuan format laporan (screens/07-kejadian.md).
class FormatLaporanScreen extends StatefulWidget {
  const FormatLaporanScreen({super.key});

  @override
  State<FormatLaporanScreen> createState() => _FormatLaporanScreenState();
}

class _FormatLaporanScreenState extends State<FormatLaporanScreen> {
  final _d = DataFormatLaporan();

  @override
  void dispose() {
    _d.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anak = [
      ...bagianPersetujuan(context, _d, setState),
      ...kartuFormat(context, [
        tombolContoh('Lihat contoh PDF', ke: Layar.laporan),
        tombolContoh(
          'Lihat contoh Excel',
          ke: Layar.laporanResmi,
          param: {'periode': belumDipindahId, 'bentuk': 'excel'},
        ),
      ]),
    ];
    return LayarPonsel(
      layarKeuangan: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Format laporan',
            anakJudul:
                'Wajib sebelum tutup buku pertama · contoh 3 Oktober 2026',
            kembaliKe: Layar.pengaturan,
            labelKembali: 'Kembali ke Lainnya',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < anak.length; i++) ...[
                    if (i > 0) const SizedBox(height: 16),
                    anak[i],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
