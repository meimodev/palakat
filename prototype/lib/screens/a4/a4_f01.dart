import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/finance/finance.dart';
import '../../providers/keuangan/laporan.dart';
import '../../shell/halaman_a4.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/pita_laporan.dart';
import '../lanjut/laporan_tabel.dart';
import 'a4_f14_tabel.dart';
import 'a4_laporan.dart';

/// A4 · F01 Laporan Perbendaharaan Bulanan of the route's month, read from
/// its datasets: official after the close, provisional before it (the
/// A4Sementara page).
class A4F01Screen extends ConsumerWidget {
  const A4F01Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = laporanRute(context, ref);
    return l == null ? const SizedBox.shrink() : HalamanF01(l);
  }
}

/// F01 of [l] on one portrait page.
class HalamanF01 extends StatelessWidget {
  const HalamanF01(this.l, {super.key});
  final LaporanBulan l;

  static const _kR = <double?>[null, 190];
  static const _kK = <double?>[null, 150, 190, 110];

  @override
  Widget build(BuildContext context) {
    final bulan = namaBulanLaporan(l);
    final f01 = tabelLaporan(l, ReportForm.f01);
    final f10 = l.data(ReportForm.f10);
    final f = l.format;
    String pembanding(Map<String, Object?> r) => [
      if (r['cashCount'] != null) 'Hitung kas ${rp(r['cashCount'] as int)}',
      if (r['statement'] != null) 'Rekening koran ${rp(r['statement'] as int)}',
      if (r['inTransit'] != null && r['inTransit'] != 0)
        'dalam perjalanan ${rp(r['inTransit'] as int)}',
    ].join(' + ');
    return HalamanA4(
      ukuran: const Size(794, 1123),
      kode: kodeA4(l, 'F01'),
      judul: 'LAPORAN PERBENDAHARAAN BULANAN',
      subjudul: subjudulA4(
        l,
        'seluruh Jemaat: semua peruntukan dan semua Kas/Bank',
      ),
      kanan: kananA4(l),
      kakiKanan: 'F01 · halaman 1 dari 1',
      isi: [
        if (!l.resmi)
          PitaLaporan.a4Sementara(
            kalimat:
                'Bukan laporan resmi. Angka masih dapat berubah sampai '
                '$bulan ditutup; file resmi dibuat setelah tutup buku.',
          ),
        BagianA4(
          anak: [
            BarisA4(
              jenis: JenisBarisA4.kepala,
              kolom: _kR,
              kanan: const {1},
              sel: f01.cols,
            ),
            for (final r in f01.rows)
              BarisA4(
                jenis: r.last is int ? JenisBarisA4.tebal : JenisBarisA4.isi,
                kolom: _kR,
                kanan: const {1},
                mono: const {1},
                sel: [
                  switch (r[0]) {
                    'Dana Transit masuk' => _tambah(
                      r[0] as String,
                      '· titipan masuk',
                    ),
                    'Dana Transit keluar' => _tambah(
                      r[0] as String,
                      '· titipan disalurkan',
                    ),
                    _ => r[0],
                  },
                  r[1],
                ],
              ),
          ],
        ),
        BagianA4(
          anak: [
            JudulA4(
              'Posisi dan kesimpulan rekonsiliasi per '
              '${tglPanjang(l.periode.end.awal)}',
            ),
            const BarisA4(
              jenis: JenisBarisA4.kepala,
              kolom: _kK,
              kanan: {1, 3},
              sel: ['Kas/Bank', 'Saldo buku', 'Pembanding', 'Selisih'],
            ),
            for (final r in f10.rows)
              BarisA4(
                kolom: _kK,
                kanan: const {1, 3},
                mono: const {1, 3},
                sel: [
                  l.akun(r['accountId'] as String?),
                  rp(r['book'] as int),
                  pembanding(r),
                  r['difference'] == null ? '' : rp(r['difference'] as int),
                ],
              ),
            BarisA4(
              jenis: JenisBarisA4.tebal,
              kolom: _kK,
              kanan: const {1, 3},
              mono: const {1, 3},
              sel: [
                'Jumlah',
                rp(f10.totals['book'] as int? ?? 0),
                '',
                rp(f10.totals['difference'] as int? ?? 0),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                l.resmi
                    ? 'Hasil hitung kas dan saldo rekening koran dicetak '
                          'terpisah dan tidak dijumlahkan.'
                    : 'Kesimpulan rekonsiliasi baru menjadi resmi setelah '
                          'tutup buku.',
              ),
            ),
          ],
        ),
        BagianA4(
          anak: [
            const Text(
              'Catatan',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Hanya transaksi yang sudah dibukukan, sejak awal pencatatan; '
              'laporan ini tidak memuat kegiatan sebelumnya.',
            ),
            const SizedBox(height: 6),
            Text(f01.kaki),
            if (l.resmi) ...[
              const SizedBox(height: 6),
              Text(
                'Disiapkan oleh ${l.penutup}, Bendahara.'
                '${f == null ? '' : ' Persetujuan format laporan sudah dicatat oleh ${l.pencatatFormat}, ${tgl(f.acceptedAt!)}.'}',
              ),
              const SizedBox(height: 6),
              const Text(
                'Halaman ini tidak memuat tanda tangan. Tanda tangan basah, '
                'bila diminta, dibubuhkan di atas kertas oleh orangnya sendiri.',
              ),
            ],
          ],
        ),
      ],
    );
  }

  // 'Dana Transit masuk · titipan masuk': the suffix is tinta2.
  static Widget _tambah(String teks, String ekor) => Builder(
    builder: (context) => Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '$teks '),
          TextSpan(
            text: ekor,
            style: TextStyle(color: context.warna.tinta2),
          ),
        ],
      ),
    ),
  );
}
