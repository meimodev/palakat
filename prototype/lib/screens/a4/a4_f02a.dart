import 'package:flutter/material.dart';

import '../../mock/format.dart';
import '../../mock/mock.dart';
import '../../shell/halaman_a4.dart';
import 'a4_f01_tabel.dart';

/// A4 · F02 Buku Kas Umum, halaman 1 dari 3: a static printed page.
class A4F02aScreen extends StatelessWidget {
  const A4F02aScreen({super.key});

  static const _kolom = [
    KolomA4(74, bungkus: false),
    KolomA4(112, mono: true),
    KolomA4(96, mono: true),
    KolomA4(null),
    KolomA4(122),
    KolomA4(102, kanan: true, mono: true),
    KolomA4(102, kanan: true, mono: true),
    KolomA4(116, kanan: true, mono: true),
  ];

  static String _uang(int n) => n == 0 ? '' : rp(n);

  @override
  Widget build(BuildContext context) {
    const lap = laporanOktober;
    return HalamanA4(
      ukuran: const Size(1123, 794),
      kode: 'F02 · LAPORAN RESMI',
      judul: 'BUKU KAS UMUM',
      subjudul: 'Jemaat Karunia · ${lap.periode} · semua Kas/Bank',
      kanan: [
        'ID ${lap.id}',
        'Dibekukan ${lap.dibekukan}',
        'Versi Mata Anggaran ${lap.versiMA}',
      ],
      kakiKanan: 'F02 · halaman 1 dari 3',
      isi: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const BarisA4(_kolom, [
              'Tanggal',
              'No. Bukti',
              'No. MA',
              'Uraian',
              'Kas/Bank',
              'Penerimaan',
              'Pengeluaran',
              'Saldo semua Kas/\u2060Bank', // keep 'Kas/Bank' whole, as Chrome does
            ], jenis: JenisBarisA4.kepala),
            BarisA4(_kolom, [
              '',
              '',
              '',
              'Saldo awal Kas/Bank',
              '',
              '',
              '',
              rp(f02SaldoAwal),
            ], jenis: JenisBarisA4.tebal),
            for (final (i, t) in f02Oktober.take(11).indexed)
              BarisA4(_kolom, [
                t.tanggal ?? '',
                t.noBukti ?? '',
                (t.kodeMA ?? kosong).replaceAll('; ', '\n'),
                t.tandaRantai == null
                    ? t.uraian
                    : Text.rich(
                        TextSpan(
                          text: '${t.uraian} ',
                          children: [tandaCetak(context, t.tandaRantai!)],
                        ),
                      ),
                t.kasBank.replaceAll('; ', '\n'),
                _uang(t.masuk),
                _uang(t.keluar),
                rp(f02SaldoSetelah[i]),
              ]),
            BarisA4(_kolom, [
              '',
              '',
              '',
              'Dipindahkan ke halaman 2',
              '',
              rp(f02Halaman1.masuk),
              rp(f02Halaman1.keluar),
              rp(f02SaldoSetelah[10]),
            ], jenis: JenisBarisA4.tebal),
          ],
        ),
      ],
    );
  }
}
