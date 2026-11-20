import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../repositories/evidence_repository.dart';
import 'memory_finance.dart';

/// Supporting documents. Commands: M3.
class MemoryEvidenceRepository implements EvidenceRepository {
  MemoryEvidenceRepository(this.f);
  final MemoryFinance f;

  @override
  List<EvidenceItem> forTransaction(String id) => [
    for (final e in f.k.evidence)
      if (e.transactionId == id) e,
  ];

  @override
  List<({Transaction transaction, EvidenceStatus status})> list(
    String periodId,
    EvidenceStatus? status,
  ) {
    final p = f.k.periodById(periodId);
    if (p == null) return const [];
    final boleh = f.visibleFundIds();
    return [
      for (final t in f.k.transactions)
        if (p.contains(t.effectiveDate) &&
            t.status != TransactionStatus.cancelled)
          if ((f.visible(t, boleh), f.k.evidenceStatus(t))
              case (final v?, final s) when status == null || s == status)
            (transaction: v, status: s),
    ];
  }

  @override
  Future<Result<EvidenceItem>> upload(
    Actor actor,
    String txnId,
    SampleFile file, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.notYet('Unggah dokumen');

  @override
  Future<Result<EvidenceItem>> verify(
    Actor actor,
    String evidenceId, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.notYet('Verifikasi');

  @override
  Future<Result<EvidenceItem>> reject(
    Actor actor,
    String evidenceId, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.notYet('Tolak dokumen');

  @override
  Future<Result<EvidenceItem>> acceptException(
    Actor actor,
    String txnId, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.notYet('Terima pengecualian');

  @override
  Future<Result<EvidenceItem>> release(
    Actor actor,
    String evidenceId, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.notYet('Lepaskan dokumen');
}
