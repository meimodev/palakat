import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/tanggal.dart';
import '../../data/repositories/master_repository.dart';
import '../../domain/finance/finance.dart';
import '../core_repositories.dart';
import '../repositories_keuangan.dart';
import '../revision.dart';
import 'beranda.dart';

/// The status chips of Transaksi (Main, WebTransaksi, TabTransaksi).
enum SaringTransaksi {
  /// Every row, cancelled ones included.
  semua,

  /// DRAFT and REVIEWED.
  draf,

  /// Posted and not reversed (a "Dibalik" row is hidden here, as drawn).
  dibukukan,
}

/// What a transaction list shows: a month ('yyyy-mm', every month when
/// null), a chip, and optionally one Kas/Bank or peruntukan.
typedef KunciDaftar = ({
  String? periodId,
  SaringTransaksi saring,
  String? accountId,
  String? fundId,
});

/// One row of a transaction list, as the boards print it.
class BarisTransaksi {
  const BarisTransaksi({
    required this.transaksi,
    required this.status,
    required this.nomor,
    required this.tanggal,
    required this.kasBank,
    required this.jumlah,
    this.catatan,
  });

  final Transaction transaksi;

  /// 'Dibukukan', 'Draf', 'Sudah diperiksa', 'Dibalik', 'Dibatalkan'.
  final String status;

  /// The voucher, or 'Belum ada No. Bukti'.
  final String nomor;

  /// 'dd/mm/yyyy'.
  final String tanggal;

  /// 'Kas', 'Bank BNI ··4821', 'Kas ke Bank BNI'.
  final String kasBank;

  /// Signed as printed: Belanja negative, Pendapatan positive, a transfer
  /// negative (the board's `jm`).
  final int jumlah;

  /// 'Belum masuk saldo' on a draft; 'Dibalik oleh No. Bukti …'.
  final String? catatan;
}

/// The rows of [k], newest first (date, then posting order, reversed).
final daftarTransaksiProvider =
    Provider.family<List<BarisTransaksi>, KunciDaftar>((ref, k) {
      ref.watch(revisionProvider);
      final tx = ref.watch(transactionRepositoryProvider);
      final akun = ref.watch(accountRepositoryProvider);
      final semua = tx.list(
        k.periodId,
        TransactionFilter(accountId: k.accountId, fundId: k.fundId),
      );
      Account? cariAkun(String? id) => akun
          .accounts(includeInactive: true)
          .where((a) => a.id == id)
          .firstOrNull;
      return [
        for (final t in semua.reversed)
          if (switch (k.saring) {
            SaringTransaksi.semua => true,
            SaringTransaksi.draf => t.isDraft,
            SaringTransaksi.dibukukan => t.isPosted && !t.isReversed,
          })
            barisTransaksi(t, cariAkun, (id) => tx.get(id)?.voucher),
      ];
    });

/// Drafts dated in an OPEN month before the running one, newest first.
/// Transaksi lists them after the running month's rows, so the home's
/// "N draf belum dibukukan" (every open month) leads to each draft it counts.
final drafBulanLaluProvider = Provider<List<BarisTransaksi>>((ref) {
  final bulan = ref.watch(bulanBukuProvider);
  final berjalan = bulan.berjalan;
  return [
    if (berjalan != null)
      for (final p in bulan.semua.reversed)
        if (!p.isClosed && p.end < berjalan.start)
          ...ref.watch(
            daftarTransaksiProvider((
              periodId: p.id,
              saring: SaringTransaksi.draf,
              accountId: null,
              fundId: null,
            )),
          ),
  ];
});

/// [t] as a list row; [akun] resolves a Kas/Bank, [nomorDari] a
/// transaction's voucher; [kasBank] overrides the Kas/Bank text.
BarisTransaksi barisTransaksi(
  Transaction t,
  Account? Function(String? id) akun,
  String? Function(String id) nomorDari, {
  String? kasBank,
}) {
  final s = signedAmount(t);
  return BarisTransaksi(
    transaksi: t,
    status: switch (t.status) {
      TransactionStatus.draft => 'Draf',
      TransactionStatus.reviewed => 'Sudah diperiksa',
      TransactionStatus.cancelled => 'Dibatalkan',
      TransactionStatus.finalized => t.isReversed ? 'Dibalik' : 'Dibukukan',
    },
    nomor: t.voucher ?? 'Belum ada No. Bukti',
    tanggal: tanggalDaftar(t.effectiveDate),
    kasBank: kasBank ?? namaKasBank(t, akun),
    jumlah: s != 0 ? s : -t.total,
    catatan: t.isDraft
        ? 'Belum masuk saldo'
        : t.isReversed
        ? 'Dibalik oleh No. Bukti ${nomorDari(t.reversedBy!) ?? ''}'
        : null,
  );
}

/// The drafts (DRAFT and REVIEWED) dated in [periodId], every month when
/// null, oldest first.
final drafKeuanganProvider = Provider.family<List<Transaction>, String?>((
  ref,
  periodId,
) {
  ref.watch(revisionProvider);
  return ref.watch(transactionRepositoryProvider).drafts(periodId: periodId);
});

/// "{Belanja|Pendapatan} {kode} {nama}" of a Mata Anggaran code in the
/// version in force at [at]; the code alone when it is not there.
String labelMataAnggaran(MasterRepository master, String code, Tanggal at) {
  final jenis = code.startsWith('1') || code.startsWith('2')
      ? MasterKind.pendapatan
      : MasterKind.belanja;
  final nama = master
      .pickerRows(jenis, at)
      .where((r) => r.code == code)
      .firstOrNull
      ?.name;
  final pohon = jenis == MasterKind.pendapatan ? 'Pendapatan' : 'Belanja';
  return nama == null ? '$pohon $code' : '$pohon $code $nama';
}

/// The short name a finance board prints for a person ('Meiske L.').
final namaPendekProvider = Provider.family<String, String>((ref, personId) {
  final p = ref.watch(peopleRepositoryProvider).person(personId);
  return p?.shortName ?? p?.name ?? personId;
});
