import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/finance/finance.dart';
import '../../providers/repositories_keuangan.dart';
import '../../theme/palakat_tema.dart';
import '../lanjut/laporan_tabel.dart';
import 'a4_f14_tabel.dart';
import 'a4_laporan.dart';

/// A4 · F14 Lampiran Laporan Bulanan of the route's month: the eight
/// attachments of the F14 dataset, each listing its transactions or cases,
/// "Nihil" when empty, paginated.
class A4F14Screen extends ConsumerWidget {
  const A4F14Screen({super.key});

  static const _k = <double?>[120, 100, null, 120];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = laporanRute(context, ref);
    if (l == null) return const SizedBox.shrink();
    final tx = ref.watch(transactionRepositoryProvider);
    final kasus = ref.watch(caseRepositoryProvider);
    final blok = <BlokA4>[];
    for (final r in l.data(ReportForm.f14).rows) {
      final n = r['n'] as int;
      final items = (r['items'] as List).cast<String>();
      final (judul, _) = lampiranF14[n - 1];
      final baris = <Widget>[
        JudulA4('$n · $judul', atas: blok.isEmpty ? 0 : 6),
      ];
      if (n == 8) {
        baris.add(
          Text(
            '${r['count']} dari 8 syarat tutup buku terpenuhi.'
            '${items.isEmpty ? '' : ' Belum terpenuhi: ${items.length}.'}',
          ),
        );
      } else if (items.isEmpty) {
        baris.add(const _Nihil());
      } else if (n == 1) {
        baris.add(
          const BarisA4(
            jenis: JenisBarisA4.kepala,
            kolom: <double?>[null, 160],
            kanan: {1},
            sel: ['Uang Muka', 'Sisa'],
          ),
        );
        for (final id in items) {
          final k = kasus.caseById(id);
          baris.add(
            BarisA4(
              kolom: const <double?>[null, 160],
              kanan: const {1},
              mono: const {1},
              sel: [k?.kase.title ?? id, k == null ? '' : rp(k.outstanding)],
            ),
          );
        }
      } else {
        baris.add(
          const BarisA4(
            jenis: JenisBarisA4.kepala,
            kolom: _k,
            kanan: {3},
            sel: ['No. Bukti', 'Tanggal', 'Uraian', 'Jumlah'],
          ),
        );
        for (final id in items) {
          final t = tx.get(id);
          baris.add(
            BarisA4(
              kolom: _k,
              kanan: const {3},
              mono: const {0, 3},
              sel: [
                t?.voucher ?? '',
                t == null ? '' : '${t.effectiveDate}',
                t?.description ?? id,
                t == null ? '' : rp(signedAmount(t)),
              ],
            ),
          );
        }
        if (n == 5) {
          baris.add(
            const _Keterangan(
              'Status dicetak seperti saat tutup buku. Dokumen susulan tidak '
              'mengubah halaman ini.',
            ),
          );
        }
      }
      blok.add((
        berat: 2 + (n == 8 || items.isEmpty ? 1 : items.length),
        isi: BagianA4(anak: baris),
      ));
    }
    blok.add((
      berat: 1,
      isi: const BagianA4(
        anak: [
          _Keterangan(
            'Lampiran tanpa isi dicetak sebagai “Nihil”, bukan halaman kosong.',
          ),
        ],
      ),
    ));
    return HalamanA4Bertingkat(
      ukuran: const Size(794, 1123),
      form: 'F14',
      kode: kodeA4(l, 'F14'),
      judul: 'LAMPIRAN LAPORAN BULANAN',
      subjudul: subjudulA4(l),
      kanan: kananA4(l),
      halaman: bagiHalaman(blok, 30),
    );
  }
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
