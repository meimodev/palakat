import 'package:flutter/material.dart';

import '../../shell/halaman_a4.dart';
import '../../theme/palakat_tema.dart';
import 'a4_f14_tabel.dart';

/// A4 · F14 Lampiran, halaman 2 dari 3. Static printed page.
class A4F14Screen extends StatelessWidget {
  const A4F14Screen({super.key});

  static const _k5 = <double?>[120, null, 120];
  static const _k6 = <double?>[120, 100, null, 120];

  @override
  Widget build(BuildContext context) => HalamanA4(
    ukuran: const Size(794, 1123),
    kode: 'F14 · LAPORAN RESMI',
    judul: 'LAMPIRAN LAPORAN BULANAN',
    subjudul: 'Jemaat Karunia · Periode laporan 1–31 Oktober 2026',
    kanan: const [
      'ID SNP-2026-10-01',
      'Dibekukan 16/11/2026 11.05',
      'Versi Mata Anggaran 2026.1',
    ],
    kakiKanan: 'F14 · halaman 2 dari 3',
    isi: [
      const BagianA4(
        anak: [JudulA4('4 · Penggantian Biaya', atas: 0), _Nihil()],
      ),
      BagianA4(
        anak: [
          const JudulA4('5 · Pengecualian Dokumen Pendukung'),
          const BarisA4(
            jenis: JenisBarisA4.kepala,
            kolom: _k5,
            kanan: {2},
            sel: [
              'No. Bukti',
              'Uraian, alasan dan pemberi pengecualian',
              'Jumlah',
            ],
          ),
          Builder(
            builder: (context) => BarisA4(
              kolom: _k5,
              kanan: const {2},
              mono: const {0, 2},
              sel: [
                'BKU-2026-0116',
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Pemeliharaan atap gedung\n'),
                      TextSpan(
                        text: 'Alasan: kuitansi menyusul · Pemberi pengecualian: Ketua BPMJ · dicatat 22/10/2026',
                        style: TextStyle(color: context.warna.tinta2),
                      ),
                    ],
                  ),
                ),
                '−Rp5.500.000',
              ],
            ),
          ),
          const _Keterangan(
            'Status dicetak seperti saat tutup buku. Dokumen susulan tidak mengubah halaman ini.',
          ),
        ],
      ),
      BagianA4(
        anak: [
          const JudulA4('6 · Pembalikan dan Koreksi'),
          const BarisA4(
            jenis: JenisBarisA4.kepala,
            kolom: _k6,
            kanan: {3},
            sel: ['No. Bukti', 'Tanggal', 'Uraian', 'Pengeluaran'],
          ),
          Builder(
            builder: (context) => BarisA4(
              kolom: _k6,
              kanan: const {3},
              mono: const {0, 3},
              sel: [
                'BKU-2026-0105',
                '09/10/2026',
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Konsumsi rapat majelis · No. MA 5.02.01.00 ',
                      ),
                      tagCetak(context, 'Dibalik'),
                    ],
                  ),
                ),
                'Rp750.000',
              ],
            ),
          ),
          const BarisA4(
            kolom: _k6,
            kanan: {3},
            mono: {0, 3},
            sel: [
              'BKU-2026-0109',
              '12/10/2026',
              'Pembalikan BKU-2026-0105 · alasan: Mata Anggaran keliru',
              '−Rp750.000',
            ],
          ),
          const BarisA4(
            kolom: _k6,
            kanan: {3},
            mono: {0, 3},
            sel: [
              'BKU-2026-0110',
              '12/10/2026',
              'Transaksi koreksi · Konsumsi rapat majelis · No. MA 5.04.01.00',
              'Rp750.000',
            ],
          ),
        ],
      ),
      const BagianA4(
        anak: [
          JudulA4('7 · Saldo Awal Pencatatan'),
          _Nihil(),
          _Keterangan(
            'Lampiran tanpa isi dicetak sebagai “Nihil”, bukan halaman kosong.',
          ),
        ],
      ),
    ],
  );
}

/// An empty attachment: 1 `tinta` border, square corners, padding 10 14, 600.
class _Nihil extends StatelessWidget {
  const _Nihil();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(border: Border.all(color: context.warna.tinta)),
    child: const Text('Nihil', style: TextStyle(fontWeight: FontWeight.w600)),
  );
}

class _Keterangan extends StatelessWidget {
  const _Keterangan(this.teks);
  final String teks;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Text(teks, style: TextStyle(color: context.warna.tinta2)),
  );
}
