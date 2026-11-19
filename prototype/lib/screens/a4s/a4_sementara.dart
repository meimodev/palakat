import 'package:flutter/material.dart';

import '../../shell/halaman_a4.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/pita_laporan.dart';
import '../a4/a4_f14_tabel.dart';

/// A4 · F01 Laporan sementara. Static printed page, before month close.
class A4SementaraScreen extends StatelessWidget {
  const A4SementaraScreen({super.key});

  static const _kR = <double?>[null, 190];
  static const _kK = <double?>[null, 150, 190, 110];

  static const _ringkas = [
    ('Pendapatan ekonomi', null, 'Rp14.820.000'),
    ('Belanja ekonomi', null, '−Rp11.455.000'),
    ('Dana Transit masuk', '· titipan masuk', 'Rp2.400.000'),
    ('Dana Transit keluar', '· titipan disalurkan', '−Rp2.400.000'),
    ('Uang Muka diberikan', null, '−Rp1.500.000'),
    ('Pengembalian sisa uang muka', null, 'Rp350.000'),
  ];

  static const _kasBank = [
    ('Kas', 'Rp8.750.000', 'Hitung kas Rp8.750.000'),
    (
      'Bank BNI ··4821',
      'Rp24.600.000',
      'Rekening koran Rp24.100.000 + setoran dalam perjalanan Rp500.000',
    ),
    ('Bank SulutGo ··1107', 'Rp5.115.000', 'Rekening koran Rp5.115.000'),
  ];

  @override
  Widget build(BuildContext context) {
    return HalamanA4(
      ukuran: const Size(794, 1123),
      kode: 'F01 · LAPORAN SEMENTARA · BUKAN LAPORAN RESMI',
      judul: 'LAPORAN PERBENDAHARAAN BULANAN',
      subjudul: 'Jemaat Karunia · Periode laporan 1–31 Oktober 2026 · seluruh Jemaat: semua peruntukan dan semua Kas/Bank',
      kanan: const [
        'Belum punya ID laporan resmi',
        'Dibuat 14/11/2026 09.20',
        'Versi Mata Anggaran 2026.1',
      ],
      kakiKanan: 'F01 · halaman 1 dari 1',
      isi: [
        const PitaLaporan.a4Sementara(
          kalimat: 'Bukan laporan resmi. Angka masih dapat berubah sampai Oktober 2026 ditutup; file resmi dibuat setelah tutup buku.',
        ),
        BagianA4(
          anak: [
            const BarisA4(
              jenis: JenisBarisA4.kepala,
              kolom: _kR,
              kanan: {1},
              sel: ['Baris', 'Oktober 2026'],
            ),
            const BarisA4(
              jenis: JenisBarisA4.tebal,
              kolom: _kR,
              kanan: {1},
              mono: {1},
              sel: ['Saldo awal Kas/Bank', 'Rp36.250.000'],
            ),
            for (final (baris, tambah, jumlah) in _ringkas)
              BarisA4(
                kolom: _kR,
                kanan: const {1},
                mono: const {1},
                sel: [
                  tambah == null
                      ? baris
                      // Builder: read tinta2 under the page's light Theme, not the app's.
                      : Builder(
                          builder: (context) => Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: '$baris '),
                                TextSpan(
                                  text: tambah,
                                  style: TextStyle(color: context.warna.tinta2),
                                ),
                              ],
                            ),
                          ),
                        ),
                  jumlah,
                ],
              ),
            const BarisA4(
              jenis: JenisBarisA4.tebal,
              kolom: _kR,
              kanan: {1},
              mono: {1},
              sel: ['Saldo akhir Kas/Bank', 'Rp38.465.000'],
            ),
          ],
        ),
        BagianA4(
          anak: [
            const JudulA4(
              'Posisi dan kesimpulan rekonsiliasi per 31 Oktober 2026',
            ),
            const BarisA4(
              jenis: JenisBarisA4.kepala,
              kolom: _kK,
              kanan: {1, 3},
              sel: ['Kas/Bank', 'Saldo buku', 'Pembanding', 'Selisih'],
            ),
            for (final (nama, saldo, pembanding) in _kasBank)
              BarisA4(
                kolom: _kK,
                kanan: const {1, 3},
                mono: const {1, 3},
                sel: [nama, saldo, pembanding, 'Rp0'],
              ),
            const BarisA4(
              jenis: JenisBarisA4.tebal,
              kolom: _kK,
              kanan: {1, 3},
              mono: {1, 3},
              sel: ['Jumlah', 'Rp38.465.000', '', 'Rp0'],
            ),
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                'Kesimpulan rekonsiliasi baru menjadi resmi setelah tutup buku.',
              ),
            ),
          ],
        ),
        const BagianA4(
          anak: [
            Text('Catatan', style: TextStyle(fontWeight: FontWeight.w700)),
            SizedBox(height: 6),
            Text(
              'Hanya transaksi yang sudah dibukukan. Pencatatan dimulai 15 September 2026; laporan ini tidak memuat kegiatan sebelum tanggal itu.',
            ),
            SizedBox(height: 6),
            Text(
              'Nama baris uang muka mengikuti format laporan yang disetujui 03/10/2026.',
            ),
          ],
        ),
      ],
    );
  }
}
