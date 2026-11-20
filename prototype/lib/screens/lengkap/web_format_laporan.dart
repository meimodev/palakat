import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/keuangan/laporan.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import 'format_laporan_bagian.dart';
import '../../app/layar.dart';

/// Web · Persetujuan format laporan (screens/07-kejadian.md).
class WebFormatLaporanScreen extends ConsumerStatefulWidget {
  const WebFormatLaporanScreen({super.key});

  @override
  ConsumerState<WebFormatLaporanScreen> createState() =>
      _WebFormatLaporanScreenState();
}

class _WebFormatLaporanScreenState
    extends ConsumerState<WebFormatLaporanScreen> {
  final _d = DataFormatLaporan();

  @override
  void dispose() {
    _d.dispose();
    super.dispose();
  }

  static Widget _kolom(double jarak, List<Widget> anak) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (var i = 0; i < anak.length; i++) ...[
        if (i > 0) SizedBox(height: jarak),
        anak[i],
      ],
    ],
  );

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return HalamanWeb(
      layarKeuangan: true,
      nav: const NavSamping(item: navKeuangan, aktif: 5),
      isi: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Inline breadcrumb: a 44 target drawn on the 14 px line.
            const MarginNegatif(
              atas: 12,
              bawah: 12,
              child: Tautan(
                ke: Layar.paketLaporan,
                cara: Cara.naik,
                child: Center(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: TautanTeks('Laporan', ukuran: 14),
                ),
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Format laporan',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            ),
            Text(
              'Wajib dicatat sebelum tutup buku pertama.',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ],
        ),
        BarisLentur(
          jarak: 24,
          anak: [
            Lentur(
              dasar: 460,
              tumbuh: 999,
              child: _kolom(
                16,
                kartuFormat(context, ref, [
                  tombolContoh('Lihat contoh PDF', ke: Layar.paketLaporan),
                  tombolContoh(
                    'Lihat contoh Excel',
                    ke: Layar.laporanResmi,
                    param: {
                      'periode':
                          ref.watch(laporanBulanProvider)?.periode.id ?? '',
                      'bentuk': 'excel',
                    },
                  ),
                ]),
              ),
            ),
            Lentur(
              dasar: 380,
              child: _kolom(14, bagianPersetujuan(context, ref, _d, setState)),
            ),
          ],
        ),
      ],
    );
  }
}
