import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/keuangan/laporan.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import 'format_laporan_bagian.dart';
import '../../app/layar.dart';

/// 23 · Persetujuan format laporan (screens/07-kejadian.md).
class FormatLaporanScreen extends ConsumerStatefulWidget {
  const FormatLaporanScreen({super.key});

  @override
  ConsumerState<FormatLaporanScreen> createState() =>
      _FormatLaporanScreenState();
}

class _FormatLaporanScreenState extends ConsumerState<FormatLaporanScreen> {
  final _d = DataFormatLaporan();

  @override
  void dispose() {
    _d.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anak = [
      ...bagianPersetujuan(context, ref, _d, setState),
      ...kartuFormat(context, ref, [
        tombolContoh('Lihat contoh PDF', ke: Layar.laporan),
        tombolContoh(
          'Lihat contoh Excel',
          ke: Layar.laporanResmi,
          param: {
            'periode': ref.watch(laporanBulanProvider)?.periode.id ?? '',
            'bentuk': 'excel',
          },
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
            anakJudul: 'Wajib sebelum tutup buku pertama',
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
