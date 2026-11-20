import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../../providers/actor.dart';
import '../../providers/clock.dart';
import '../../providers/repositories_keuangan.dart';

/// The commands the AI boards share (AIFoto, BantuanAI, AIMataAnggaran and
/// their web twins). Each reads what it needs before its first await, so it
/// is safe to call from a callback of a screen that may be left meanwhile.

Refused<T> _tanpaSesi<T>(String aksi) =>
    Refused(Refusal(action: aksi, because: 'Sesi sudah berakhir.'));

/// Asks the AI for a proposal; completes after the board's delay (the
/// repository's timer) with the READY proposal, or a refusal (budget used
/// up).
Future<Result<AiProposal>> mintaUsulan(
  WidgetRef ref,
  AiKind kind,
  AiInput input,
) {
  final a = ref.read(actorProvider);
  if (a == null) return Future.value(_tanpaSesi('Buat usulan'));
  return ref
      .read(aiRepositoryProvider)
      .propose(
        a,
        kind,
        input,
        idempotencyKey: kunciBaru(a.personId, ref.read(clockProvider)),
      );
}

/// "Abaikan": records the disposition; nothing is filled.
Future<Result<AiProposal>> abaikanUsulan(WidgetRef ref, AiProposal p) {
  final a = ref.read(actorProvider);
  if (a == null) return Future.value(_tanpaSesi('Abaikan'));
  return ref
      .read(aiRepositoryProvider)
      .dispose(
        a,
        p.id,
        AiDisposition.rejected,
        expectedRevision: p.revision,
        idempotencyKey: kunciBaru(a.personId, ref.read(clockProvider)),
      );
}

/// "Pakai" / "Ubah" on a receipt or sentence proposal: records the
/// disposition, then saves it as a Belanja draft (or into [drafId], the
/// draft an earlier "Pakai" saved). Kas/Bank, peruntukan and Lingkup are
/// never filled (D01); the draft stays unbooked.
Future<Result<Transaction>> isiDrafDariUsulan(
  WidgetRef ref,
  AiProposal p,
  AiDisposition d, {
  String? drafId,
}) async {
  final a = ref.read(actorProvider);
  if (a == null) return _tanpaSesi('Pakai usulan');
  final ai = ref.read(aiRepositoryProvider);
  final tx = ref.read(transactionRepositoryProvider);
  final jam = ref.read(clockProvider);
  final hari = ref.read(hariIniProvider);
  String kunci() => kunciBaru(a.personId, jam);

  final r = await ai.dispose(
    a,
    p.id,
    d,
    expectedRevision: p.revision,
    idempotencyKey: kunci(),
  );
  if (r case Refused(:final refusal)) return Refused(refusal);
  final h = p.result!;
  final bagian = [
    for (final l in h.lines)
      Allocation(amount: l.amount ?? h.amount ?? 0, masterCode: l.masterCode),
  ];
  final uraian = h.payee ?? 'Belanja';
  final lama = drafId == null ? null : tx.get(drafId);
  if (lama != null && lama.isDraft) {
    return tx.editDraft(
      a,
      lama.id,
      TransactionPatch(
        effectiveDate: h.date,
        description: uraian,
        payee: h.payee,
        allocations: bagian,
      ),
      expectedRevision: lama.revision,
      idempotencyKey: kunci(),
    );
  }
  return tx.createDraft(
    a,
    TransactionDraft(
      type: TransactionType.expense,
      effectiveDate: h.date ?? hari,
      description: uraian,
      payee: h.payee,
      allocations: bagian,
      aiProposalId: p.id,
    ),
    idempotencyKey: kunci(),
  );
}
