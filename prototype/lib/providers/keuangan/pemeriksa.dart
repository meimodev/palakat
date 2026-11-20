import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../actor.dart';
import '../repositories_keuangan.dart';
import '../revision.dart';
import 'beranda.dart';
import 'transaksi.dart';

/// One draft in the Pemeriksa queue (Pemeriksa, WebPemeriksa; DP33).
class BarisPemeriksa {
  const BarisPemeriksa({
    required this.transaksi,
    required this.pencatat,
    required this.kasBank,
    required this.jumlah,
    required this.mataAnggaran,
    required this.peruntukan,
    required this.milikSendiri,
    this.pemeriksa,
  });

  final Transaction transaksi;

  /// The maker's short name ('Meiske L.'); the time is
  /// `transaksi.createdAt`.
  final String pencatat;
  final String kasBank;

  /// Signed as the lists print it.
  final int jumlah;

  /// 'Belanja 5.05.02.00 Sewa peralatan' per part, joined with '; '; null
  /// while none is chosen.
  final String? mataAnggaran;

  /// The peruntukan names, joined.
  final String peruntukan;

  /// The viewer made it: they cannot mark it ("Anda yang mencatat …").
  final bool milikSendiri;

  /// Who marked it "Sudah diperiksa" (short name), when REVIEWED; the time
  /// is `transaksi.reviewedAt`.
  final String? pemeriksa;

  bool get sudahDiperiksa => transaksi.status == TransactionStatus.reviewed;

  /// "Tandai sudah diperiksa" applies (the command still checks the rest).
  bool get bisaDitandai => !milikSendiri && !sudahDiperiksa;
}

/// Every draft in an open month waiting for, or holding, a second check,
/// newest first: the church's and the units' (Jefry checks every booking,
/// README 5.6).
final antreanPemeriksaProvider = Provider<List<BarisPemeriksa>>((ref) {
  ref.watch(revisionProvider);
  final bulan = ref.watch(bulanBukuProvider);
  final tx = ref.watch(transactionRepositoryProvider);
  final akun = ref.watch(accountRepositoryProvider);
  final master = ref.watch(masterRepositoryProvider);
  final dana = ref.watch(fundRepositoryProvider);
  final saya = ref.watch(actorProvider)?.personId;
  Account? cariAkun(String? id) =>
      akun.accounts(includeInactive: true).where((a) => a.id == id).firstOrNull;
  final daftar = [
    for (final p in bulan.semua)
      if (!p.isClosed) ...tx.drafts(periodId: p.id),
  ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return [
    for (final t in daftar)
      BarisPemeriksa(
        transaksi: t,
        pencatat: ref.watch(namaPendekProvider(t.createdBy)),
        kasBank: namaKasBank(t, cariAkun),
        jumlah: barisTransaksi(t, cariAkun, (_) => null).jumlah,
        mataAnggaran: t.allocations.every((a) => a.masterCode == null)
            ? null
            : {
                for (final a in t.allocations)
                  if (a.masterCode != null)
                    labelMataAnggaran(master, a.masterCode!, t.effectiveDate),
              }.join('; '),
        peruntukan: {
          for (final a in t.allocations) dana.fund(a.fundId ?? '')?.name ?? '',
        }.where((n) => n.isNotEmpty).join(', '),
        milikSendiri: t.createdBy == saya,
        pemeriksa: t.reviewedBy == null
            ? null
            : ref.watch(namaPendekProvider(t.reviewedBy!)),
      ),
  ];
});

/// The drafts the signed-in actor may mark now ("N draf menunggu
/// pemeriksaan"): not their own, not yet checked. Empty when they cannot
/// review.
final menungguPemeriksaanProvider = Provider<List<BarisPemeriksa>>((ref) {
  final a = ref.watch(actorProvider);
  if (a == null) return const [];
  final boleh = ref
      .watch(canProvider)
      .can(
        a,
        Capability.financeReview,
        ScopeRef.jemaat,
        at: ref.watch(hariIniProvider),
      );
  if (!boleh) return const [];
  return [
    for (final b in ref.watch(antreanPemeriksaProvider))
      if (b.bisaDitandai) b,
  ];
});
