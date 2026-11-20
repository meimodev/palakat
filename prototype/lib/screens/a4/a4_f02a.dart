import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/finance/finance.dart';
import '../../providers/keuangan/laporan.dart';
import '../../theme/palakat_tema.dart';
import '../lanjut/laporan_tabel.dart';
import 'a4_f14_tabel.dart';
import 'a4_laporan.dart';

/// A4 · F02 Buku Kas Umum of the route's month as one paginated document
/// (the boards' A4F02a–c): [_muat] rows a page, the page totals carried
/// over ("Dipindahkan ke halaman …", "Pindahan dari halaman …"), and on the
/// last page the closing balance per Kas/Bank. A reversal prints negative
/// in its original's column (D12).
class A4F02aScreen extends ConsumerWidget {
  const A4F02aScreen({super.key});

  static const _muat = 11;
  static const _kolom = <double?>[74, 112, 96, null, 122, 102, 102, 116];
  static const _kanan = {5, 6, 7};
  static const _mono = {1, 2, 5, 6, 7};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = laporanRute(context, ref);
    if (l == null) return const SizedBox.shrink();
    final d = l.data(ReportForm.f02);
    final rows = d.rows;
    final n = rows.isEmpty ? 1 : (rows.length + _muat - 1) ~/ _muat;
    String uang(Object? v) => v == 0 || v == null ? '' : rp(v as int);
    BarisA4 tebal(String ur, int masuk, int keluar, int saldo) => BarisA4(
      jenis: JenisBarisA4.tebal,
      kolom: _kolom,
      kanan: _kanan,
      mono: _mono,
      sel: ['', '', '', ur, '', uang(masuk), uang(keluar), rp(saldo)],
    );
    var masuk = 0, keluar = 0, saldo = d.totals['opening'] as int;
    final halaman = <List<Widget>>[];
    for (var h = 0; h < n; h++) {
      final isi = rows.skip(h * _muat).take(_muat);
      final baris = <Widget>[
        const BarisA4(
          jenis: JenisBarisA4.kepala,
          kolom: _kolom,
          kanan: _kanan,
          sel: [
            'Tanggal',
            'No. Bukti',
            'No. MA',
            'Uraian',
            'Kas/Bank',
            'Penerimaan',
            'Pengeluaran',
            'Saldo semua Kas/⁠Bank', // keep 'Kas/Bank' whole
          ],
        ),
        h == 0
            ? tebal('Saldo awal Kas/Bank', 0, 0, saldo)
            : tebal('Pindahan dari halaman $h', masuk, keluar, saldo),
        for (final r in isi)
          BarisA4(
            kolom: _kolom,
            kanan: _kanan,
            mono: _mono,
            sel: [
              '${r['date']}',
              '${r['voucher'] ?? ''}',
              (r['codes'] as List).isEmpty
                  ? kosong
                  : (r['codes'] as List).join('\n'),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '${r['description']}'),
                    for (final t in tandaRantai(r)) ...[
                      const TextSpan(text: ' '),
                      tagCetak(context, t),
                    ],
                  ],
                ),
              ),
              (r['accountIds'] as List)
                  .map((a) => l.akun(a as String))
                  .join('\n'),
              uang(r['in']),
              uang(r['out']),
              rp(r['balance'] as int),
            ],
          ),
      ];
      for (final r in isi) {
        masuk += r['in'] as int;
        keluar += r['out'] as int;
        saldo = r['balance'] as int;
      }
      final akhir = h == n - 1;
      baris.add(
        akhir
            ? tebal('Jumlah dan saldo akhir Kas/Bank', masuk, keluar, saldo)
            : tebal('Dipindahkan ke halaman ${h + 2}', masuk, keluar, saldo),
      );
      halaman.add([
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: baris),
        if (akhir) _Penutup(l: l, jumlah: rows.length),
      ]);
    }
    return HalamanA4Bertingkat(
      ukuran: const Size(1123, 794),
      form: 'F02',
      kode: kodeA4(l, 'F02'),
      judul: 'BUKU KAS UMUM',
      subjudul: subjudulA4(l, 'semua Kas/Bank'),
      kanan: kananA4(l),
      halaman: halaman,
    );
  }
}

/// The last page's closing balance per Kas/Bank and the note of D13.
class _Penutup extends StatelessWidget {
  const _Penutup({required this.l, required this.jumlah});
  final LaporanBulan l;
  final int jumlah;

  @override
  Widget build(BuildContext context) {
    final t = l.data(ReportForm.f03).totals;
    final akun = [
      for (final k in t.keys)
        if (k.startsWith('closing:')) k.substring('closing:'.length),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Text(
                  'Saldo akhir per Kas/Bank',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              for (final a in akun)
                Row(
                  children: [
                    Text(l.akun(a)),
                    const SizedBox(width: 28),
                    Expanded(
                      child: Text(
                        rp(t['closing:$a'] as int),
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontFamily: PalakatText.mono),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          child: Text(
            '$jumlah baris. Pembayaran yang dibagi ke beberapa Mata Anggaran '
            'dicetak satu kali dengan semua nomornya. Pembalikan dicetak '
            'sebagai angka negatif di kolom yang sama dengan transaksi '
            'asalnya. Nomor yang tidak tampil di sini bukan arus kas/bank '
            '${namaBulanLaporan(l)}; semuanya terdaftar di F12 Daftar Bukti '
            'Kas.',
            style: TextStyle(color: context.warna.tinta2),
          ),
        ),
      ],
    );
  }
}
