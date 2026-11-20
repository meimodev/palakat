import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../data/memory/memory_case_repository.dart'
    show refundIsSupplier, refundedOf;
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../actor.dart';
import '../clock.dart';
import '../core_repositories.dart';
import '../repositories_keuangan.dart';
import '../revision.dart';
import 'beranda.dart';
import 'transaksi.dart';

/// The read model of Pengembalian and WebPengembalian (M3, RD04): the
/// posted transactions a refund may follow, and the refund drafts linked to
/// them by voucher.
class AsalPengembalian {
  const AsalPengembalian({
    required this.t,
    required this.pemasok,
    required this.boleh,
    required this.ma,
    required this.kasBank,
    required this.bulan,
    required this.bulanSama,
  });

  final Transaction t;

  /// Uang kembali dari pemasok (a Belanja); else kembali kepada donatur.
  final bool pemasok;

  /// The original total minus what is already refunded.
  final int boleh;

  /// 'Belanja 5.08.02.00 Pemeliharaan gedung'.
  final String ma;
  final String kasBank;

  /// '{Bulan yyyy} · Belum ditutup' of the original.
  final String bulan;

  /// The original is in the month the refund is dated in (today's).
  final bool bulanSama;

  String get id => t.id;
  String get no => t.voucher ?? '';
}

/// Every posted Belanja, and every Pendapatan from a named donor, in the
/// open months with something left to refund; newest first.
final daftarAsalPengembalianProvider = Provider<List<AsalPengembalian>>((ref) {
  ref.watch(revisionProvider);
  final tx = ref.watch(transactionRepositoryProvider);
  final semua = tx.list(null);
  final hasil = <AsalPengembalian>[
    for (final t in semua.reversed)
      if (t.isPosted && !t.isReversed && _bisa(t)) ?asalPengembalian(ref, t.id),
  ];
  return [
    for (final a in hasil)
      if (a.boleh > 0) a,
  ];
});

bool _bisa(Transaction t) => switch (refundIsSupplier(t)) {
  true => t.type == TransactionType.expense,
  false => t.allocations.any((a) => a.partyId != null),
  null => false,
};

/// Transaction [id] as a refund's original; null when it cannot be one or
/// its month is closed.
AsalPengembalian? asalPengembalian(Ref ref, String id) {
  final tx = ref.watch(transactionRepositoryProvider);
  final t = tx.get(id);
  if (t == null || !t.isPosted) return null;
  final pemasok = refundIsSupplier(t);
  if (pemasok == null) return null;
  final p = ref
      .watch(periodRepositoryProvider)
      .periods()
      .where((x) => x.contains(t.effectiveDate))
      .firstOrNull;
  if (p == null || p.isClosed) return null;
  final akun = ref.watch(accountRepositoryProvider);
  final kode = t.allocations.first.masterCode;
  return AsalPengembalian(
    t: t,
    pemasok: pemasok,
    boleh: t.total - refundedOf(tx.list(null), t),
    ma: kode == null
        ? ''
        : labelMataAnggaran(
            ref.watch(masterRepositoryProvider),
            kode,
            t.effectiveDate,
          ),
    kasBank: namaKasBank(
      t,
      (i) => akun
          .accounts(includeInactive: true)
          .where((a) => a.id == i)
          .firstOrNull,
    ),
    bulan: '${namaBulan(p)} · Belum ditutup',
    bulanSama: p.contains(ref.watch(hariIniProvider)),
  );
}

final asalPengembalianProvider = Provider.family<AsalPengembalian?, String>((
  ref,
  id,
) {
  ref.watch(revisionProvider);
  return asalPengembalian(ref, id);
});

/// What a booked refund changed: the month's Belanja or Pendapatan and the
/// book balance of every Kas/Bank.
final pengaruhPengembalianProvider =
    Provider<({String bulan, int belanja, int pendapatan, int saldo})>((ref) {
      ref.watch(revisionProvider);
      final b = ref.watch(bulanBukuProvider).berjalan;
      final r = b == null ? null : ref.watch(ringkasanBulanProvider(b.id));
      final akun = ref.watch(accountRepositoryProvider);
      return (
        bulan: b == null ? '' : namaBulan(b),
        belanja: r?.belanja ?? 0,
        pendapatan: r?.pendapatan ?? 0,
        saldo: akun.accounts().fold(0, (s, a) => s + akun.balance(a.id)),
      );
    });

/// The reason of refund [id] (its audit line), '' when there is none.
final alasanPengembalianProvider = Provider.family<String, String>((ref, id) {
  ref.watch(revisionProvider);
  return ref
          .watch(auditRepositoryProvider)
          .list(AuditFilter(ref: RecordRef('transaction', id)))
          .where((x) => x.action == 'finance.txn.refund')
          .firstOrNull
          ?.reason ??
      '';
});

/// "Simpan sebagai draf" ([bukukan] false) or "Periksa dan bukukan": the
/// refund draft of [a], then Bukukan. Returns the draft id (null when
/// refused) and the refusal, if any.
Future<({String? id, Refusal? pesan})> catatPengembalian(
  WidgetRef ref,
  AsalPengembalian a, {
  required int jumlah,
  required String alasan,
  required bool bukukan,
}) async {
  final orang = ref.read(actorProvider);
  if (orang == null) return (id: null, pesan: null);
  String kunci() => kunciBaru(orang.personId, ref.read(clockProvider));
  final r = await ref
      .read(caseRepositoryProvider)
      .refund(orang, a.id, jumlah, reason: alasan, idempotencyKey: kunci());
  if (r.refusal case final p?) return (id: null, pesan: p);
  final id = r.value;
  return (id: id, pesan: bukukan ? await bukukanPengembalian(ref, id) : null);
}

/// Bukukan of refund draft [id].
Future<Refusal?> bukukanPengembalian(WidgetRef ref, String id) async {
  final orang = ref.read(actorProvider);
  final tx = ref.read(transactionRepositoryProvider);
  final t = tx.get(id);
  if (orang == null || t == null || !t.isDraft) return null;
  final r = await tx.finalize(
    orang,
    id,
    expectedRevision: t.revision,
    idempotencyKey: kunciBaru(orang.personId, ref.read(clockProvider)),
  );
  return r.refusal;
}

/// 'Rp500.000' left of [a]: the form's "paling banyak".
String palingBanyak(AsalPengembalian a) => rp(a.boleh);
