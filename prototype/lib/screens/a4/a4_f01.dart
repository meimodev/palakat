import 'package:flutter/material.dart';

import '../../mock/mock.dart';
import '../../shell/halaman_a4.dart';
import '../../theme/palakat_tema.dart';
import 'a4_f01_tabel.dart';

/// A4 · F01 Laporan Perbendaharaan Bulanan: a static printed page.
class A4F01Screen extends StatelessWidget {
  const A4F01Screen({super.key});

  static const _ringkas = [
    KolomA4(null),
    KolomA4(190, kanan: true, mono: true),
  ];
  static const _rekon = [
    KolomA4(null),
    KolomA4(150, kanan: true, mono: true),
    KolomA4(190),
    KolomA4(110, kanan: true, mono: true),
  ];

  @override
  Widget build(BuildContext context) {
    const lap = laporanOktober;
    return HalamanA4(
      ukuran: const Size(794, 1123),
      kode: 'F01 · LAPORAN RESMI',
      judul: 'LAPORAN PERBENDAHARAAN BULANAN',
      subjudul:
          'Jemaat Karunia · ${lap.periode} · seluruh Jemaat: semua peruntukan dan semua Kas/Bank',
      kanan: [
        'ID ${lap.id}',
        'Dibekukan ${lap.dibekukan}',
        'Versi Mata Anggaran ${lap.versiMA}',
      ],
      kakiKanan: 'F01 · halaman 1 dari 1',
      isi: [
        DefaultTextStyle.merge(
          style: const TextStyle(fontSize: 15),
          child: Builder(builder: _ringkasan),
        ),
        DefaultTextStyle.merge(
          style: const TextStyle(fontSize: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 6, bottom: 2),
                child: Text(
                  'Posisi dan kesimpulan rekonsiliasi per 31 Oktober 2026',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const BarisA4(_rekon, [
                'Kas/Bank',
                'Saldo buku',
                'Pembanding',
                'Selisih',
              ], jenis: JenisBarisA4.kepala),
              for (final (i, b) in f10Oktober.indexed)
                BarisA4(
                  _rekon,
                  b,
                  jenis: i == f10Oktober.length - 1
                      ? JenisBarisA4.tebal
                      : JenisBarisA4.isi,
                ),
              const SizedBox(height: 6),
              const Text(
                'Ketiga Kas/Bank sudah dipastikan. Hasil hitung kas dan saldo rekening koran dicetak terpisah dan tidak dijumlahkan.',
              ),
            ],
          ),
        ),
        DefaultTextStyle.merge(
          style: const TextStyle(fontSize: 15),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 6,
            children: [
              Text('Catatan', style: TextStyle(fontWeight: FontWeight.w700)),
              Text(
                'Hanya transaksi yang sudah dibukukan. Pencatatan dimulai 15 September 2026; laporan ini tidak memuat kegiatan sebelum tanggal itu.',
              ),
              Text(
                'Nama baris uang muka mengikuti format laporan yang disetujui 03/10/2026.',
              ),
              Text(
                'Disiapkan oleh Meiske Lumentut, Bendahara. Persetujuan format laporan sudah dicatat: Pdt. Lidya Rondonuwu, Ketua BPMJ, 03/10/2026.',
              ),
              Text(
                'Halaman ini tidak memuat tanda tangan. Tanda tangan basah, bila diminta, dibubuhkan di atas kertas oleh orangnya sendiri.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _ringkasan(BuildContext context) {
    final c = context.warna;
    final akhir = f01Oktober.length - 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const BarisA4(_ringkas, [
          'Baris',
          'Oktober 2026',
        ], jenis: JenisBarisA4.kepala),
        for (final (i, b) in f01Oktober.indexed)
          BarisA4(
            _ringkas,
            [_label(b[0], c.tinta2), b[1]],
            jenis: i == 0 || i == akhir ? JenisBarisA4.tebal : JenisBarisA4.isi,
          ),
      ],
    );
  }

  // 'Dana Transit masuk · titipan masuk': the suffix is tinta2.
  static Object _label(String teks, Color redup) {
    final i = teks.indexOf(' · ');
    if (i < 0) return teks;
    return Text.rich(
      TextSpan(
        text: teks.substring(0, i),
        children: [
          TextSpan(
            text: teks.substring(i),
            style: TextStyle(color: redup),
          ),
        ],
      ),
    );
  }
}
