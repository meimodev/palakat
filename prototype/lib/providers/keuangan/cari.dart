import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../domain/finance/finance.dart';
import '../actor.dart';
import '../repositories_keuangan.dart';
import '../revision.dart';
import 'transaksi.dart';

/// One posted record Cari lists.
class BarisCari {
  const BarisCari({required this.baris, required this.jumlah});

  /// The list row (voucher, date, Kas/Bank, title).
  final BarisTransaksi baris;

  /// The amount this record adds to the answer: the matching parts only
  /// when the query read as a Mata Anggaran (0098's Kas part), else the
  /// whole signed amount.
  final int jumlah;
}

/// Cari and WebCari (D33): how the query was read, the posted records it
/// finds, and their total, computed by the app from those records.
class HasilCari {
  const HasilCari({
    required this.kueri,
    required this.baris,
    this.dibacaSebagai,
  });

  final String kueri;

  /// 'Pendapatan 1.3.53.07.00 Persembahan Ibadah Minggu · {Bulan} {tahun} ·
  /// pagi'; null for an empty query.
  final String? dibacaSebagai;
  final List<BarisCari> baris;

  bool get cocok => baris.isNotEmpty;

  /// "Jumlah dari {n} transaksi yang sudah dibukukan": the sum of [baris].
  int get jumlah => baris.fold(0, (n, b) => n + b.jumlah);
}

const _bulan = [
  'januari',
  'februari',
  'maret',
  'april',
  'mei',
  'juni',
  'juli',
  'agustus',
  'september',
  'oktober',
  'november',
  'desember',
];

const _abaikan = {
  'bulan',
  'tahun',
  'di',
  'dari',
  'ke',
  'yang',
  'dan',
  'untuk',
  'pada',
  'semua',
  'transaksi',
};

/// The search over posted records in everyday words. A month name (with an
/// optional year) narrows to that month, the most recent one up to today
/// when no year is given. Two words of a Mata Anggaran name (or one, when
/// it is the only word) read the query as that Mata Anggaran; otherwise
/// every word must be in the description, payee or voucher.
final cariKeuanganProvider = Provider.family<HasilCari, String>((ref, kueri) {
  ref.watch(revisionProvider);
  final kata = kueri
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9.\-]+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (kata.isEmpty) return HasilCari(kueri: kueri, baris: const []);

  // The month.
  final hari = ref.watch(hariIniProvider);
  final iBulan = kata.indexWhere(_bulan.contains);
  final tahunDitulis = kata
      .map((w) => RegExp(r'^20\d\d$').hasMatch(w) ? int.parse(w) : null)
      .nonNulls
      .firstOrNull;
  ({int y, int m})? bulan;
  if (iBulan >= 0) {
    final m = _bulan.indexOf(kata[iBulan]) + 1;
    final y = tahunDitulis ?? (m <= hari.bulan ? hari.tahun : hari.tahun - 1);
    bulan = (y: y, m: m);
  }
  final isi = [
    for (final w in kata)
      if (!_bulan.contains(w) &&
          !_abaikan.contains(w) &&
          !RegExp(r'^20\d\d$').hasMatch(w))
        w,
  ];

  // The Mata Anggaran, from the published versions.
  final master = ref.watch(masterRepositoryProvider);
  MasterRow? ma;
  var skor = 0;
  final dipakai = <String>{};
  for (final jenis in MasterKind.values) {
    for (final v in master.versions(jenis)) {
      if (v.status != MasterVersionStatus.published) continue;
      for (final r in master.rows(v.id)) {
        if (!r.postable) continue;
        final nama = r.name.toLowerCase().split(RegExp(r'[^a-z0-9]+'));
        final kena = {
          for (final w in isi)
            if (w.length >= 3 && nama.any((n) => n.startsWith(w))) w,
        };
        if (kena.length > skor) {
          ma = r;
          skor = kena.length;
          dipakai
            ..clear()
            ..addAll(kena);
        }
      }
    }
  }
  final pakaiMa = ma != null && (skor >= 2 || isi.length == 1);

  final tx = ref.watch(transactionRepositoryProvider);
  final akun = ref.watch(accountRepositoryProvider);
  Account? cariAkun(String? id) =>
      akun.accounts(includeInactive: true).where((a) => a.id == id).firstOrNull;
  final daftar = tx.list(
    null,
    TransactionFilter(
      statuses: const {TransactionStatus.finalized},
      masterCode: pakaiMa ? ma.code : null,
      text: pakaiMa || isi.isEmpty ? null : isi.join(' '),
      from: bulan == null ? null : Tanggal(bulan.y, bulan.m, 1),
      to: bulan == null
          ? null
          : Tanggal.dari(DateTime.utc(bulan.y, bulan.m + 1, 0)),
    ),
  );
  final baris = [
    for (final t in daftar)
      BarisCari(
        baris: barisTransaksi(
          t,
          cariAkun,
          (id) => tx.get(id)?.voucher,
          // Only the Kas/Bank of the matching parts (0098's Kas part).
          kasBank: pakaiMa
              ? {
                  for (final a in t.allocations)
                    if (a.masterCode == ma.code)
                      cariAkun(t.accountOf(a))?.name ?? '',
                }.join('; ')
              : null,
        ),
        jumlah: pakaiMa
            ? effectsOf(t)
                  .where((e) => e.allocation.masterCode == ma!.code)
                  .fold(
                    0,
                    (n, e) =>
                        n + e.income + e.transitIn - e.expense - e.transitOut,
                  )
            : signedAmount(t),
      ),
  ];

  final sisa = isi.where((w) => !dipakai.contains(w)).join(' ');
  final bagian = <String>[
    if (pakaiMa) labelMataAnggaran(master, ma.code, hari),
    if (!pakaiMa && isi.isNotEmpty) 'Uraian berisi “${isi.join(' ')}”',
    if (bulan != null) bulanTahun(bulan.y, bulan.m),
    if (pakaiMa && sisa.isNotEmpty) sisa,
  ];
  return HasilCari(
    kueri: kueri,
    baris: baris,
    dibacaSebagai: bagian.isEmpty ? null : bagian.join(' · '),
  );
});
