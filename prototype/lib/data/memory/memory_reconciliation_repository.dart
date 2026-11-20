import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../repositories/reconciliation_repository.dart';
import 'memory_finance.dart';

/// Reconciliation sessions, statement lines and cash counts. Commands: M4.
class MemoryReconciliationRepository implements ReconciliationRepository {
  MemoryReconciliationRepository(this.f);
  final MemoryFinance f;

  @override
  ReconSession? session(String accountId, String periodId) => f.k.reconSessions
      .where((s) => s.accountId == accountId && s.periodId == periodId)
      .lastOrNull;

  @override
  List<StatementLine> statementLines(String sessionId) => [
    for (final l in f.k.statementLines)
      if (l.sessionId == sessionId) l,
  ];

  @override
  List<CashCount> cashCounts(String accountId) =>
      f.k.cashCounts.where((c) => c.accountId == accountId).toList()
        ..sort((a, b) => b.countedAt.compareTo(a.countedAt));

  @override
  Future<Result<ReconSession>> importStatement(
    Actor actor,
    String accountId,
    String periodId,
    SampleStatement statement, {
    required String idempotencyKey,
  }) => f.notYet('Unggah rekening koran');

  @override
  Future<Result<ReconSession>> match(
    Actor actor,
    String sessionId,
    List<String> lineIds,
    List<String> txnIds, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.notYet('Cocokkan');

  @override
  Future<Result<ReconSession>> markTimingItem(
    Actor actor,
    String sessionId,
    String txnId, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.notYet('Tandai dalam perjalanan');

  @override
  Future<Result<Transaction>> createTxnFromLine(
    Actor actor,
    String lineId,
    TransactionDraft draft, {
    required String idempotencyKey,
  }) => f.notYet('Buat transaksi dari mutasi ini');

  @override
  Future<Result<ReconSession>> review(
    Actor actor,
    String sessionId, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.notYet('Tandai sudah diperiksa');

  @override
  Future<Result<ReconSession>> confirm(
    Actor actor,
    String sessionId, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.notYet('Pastikan rekonsiliasi');

  @override
  Future<Result<CashCount>> recordCashCount(
    Actor actor,
    String accountId,
    Map<int, int> denominations,
    List<String> counters, {
    required String idempotencyKey,
  }) => f.notYet('Simpan hasil hitung');
}
