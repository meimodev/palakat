import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';

/// Bank reconciliation and cash counts (README 4.2, DM 5.5, 6.3): session
/// OPEN → REVIEWED → CONFIRMED; a book change invalidates the confirmation
/// (`PeriodRepository.blockers` reports it stale); matching is on exact
/// amounts and confirmed by a person.
abstract interface class ReconciliationRepository {
  ReconSession? session(String accountId, String periodId);
  List<StatementLine> statementLines(String sessionId);

  /// Newest first.
  List<CashCount> cashCounts(String accountId);

  Future<Result<ReconSession>> importStatement(
    Actor actor,
    String accountId,
    String periodId,
    SampleStatement statement, {
    required String idempotencyKey,
  });

  Future<Result<ReconSession>> match(
    Actor actor,
    String sessionId,
    List<String> lineIds,
    List<String> txnIds, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// 'Setoran dalam perjalanan', carried to the next period.
  Future<Result<ReconSession>> markTimingItem(
    Actor actor,
    String sessionId,
    String txnId, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// "Buat transaksi dari mutasi ini": a DRAFT.
  Future<Result<Transaction>> createTxnFromLine(
    Actor actor,
    String lineId,
    TransactionDraft draft, {
    required String idempotencyKey,
  });

  Future<Result<ReconSession>> review(
    Actor actor,
    String sessionId, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  Future<Result<ReconSession>> confirm(
    Actor actor,
    String sessionId, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// [denominations]: denomination → sheets. An observed zero is explicit.
  Future<Result<CashCount>> recordCashCount(
    Actor actor,
    String accountId,
    Map<int, int> denominations,
    List<String> counters, {
    required String idempotencyKey,
  });
}
