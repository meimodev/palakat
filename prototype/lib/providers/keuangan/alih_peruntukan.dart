import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../actor.dart';
import '../clock.dart';
import '../repositories_keuangan.dart';
import '../revision.dart';

/// The read model of AlihPeruntukan and WebAlihPeruntukan (M3): a Kas/Bank's
/// book balance, in all and by peruntukan, today.
final saldoPeruntukanProvider = Provider.family<Map<String, int>, String>((
  ref,
  akun,
) {
  ref.watch(revisionProvider);
  return ref.watch(accountRepositoryProvider).balanceByFund(akun);
});

final saldoAkunProvider = Provider.family<int, String>((ref, akun) {
  ref.watch(revisionProvider);
  return ref.watch(accountRepositoryProvider).balance(akun);
});

/// "Periksa dan bukukan": a fundTransfer draft (or the saved [drafId]) on
/// [akun] from [dari] to [ke], dated today, [dasar] as its reference, then
/// Bukukan. Returns the draft id, the voucher once booked, and the refusal.
Future<({String? id, String? no, Refusal? pesan})> alihPeruntukan(
  WidgetRef ref, {
  String? drafId,
  required String akun,
  required String dari,
  required String ke,
  required int jumlah,
  required String dasar,
}) async {
  final a = ref.read(actorProvider);
  if (a == null) return (id: null, no: null, pesan: null);
  final tx = ref.read(transactionRepositoryProvider);
  String kunci() => kunciBaru(a.personId, ref.read(clockProvider));
  var t = drafId == null ? null : tx.get(drafId);
  if (t == null || !t.isDraft) {
    final r = await tx.createDraft(
      a,
      TransactionDraft(
        type: TransactionType.fundTransfer,
        effectiveDate: ref.read(hariIniProvider),
        description: 'Alih peruntukan · ${dasar.trim()}',
        accountId: akun,
        sourceRef: dasar.trim(),
        allocations: [
          Allocation(
            amount: jumlah,
            fundId: dari,
            toFundId: ke,
            scopeId: ScopeRef.jemaatId,
          ),
        ],
      ),
      idempotencyKey: kunci(),
    );
    if (r.refusal case final p?) return (id: null, no: null, pesan: p);
    t = r.value;
  }
  final f = await tx.finalize(
    a,
    t.id,
    expectedRevision: t.revision,
    idempotencyKey: kunci(),
  );
  return (id: t.id, no: f.isOk ? f.value : null, pesan: f.refusal);
}
