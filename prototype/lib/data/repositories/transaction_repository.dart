import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';

/// The ledger (README 4.2, DM 5.1): DRAFT → REVIEWED → FINALIZED; a
/// material edit or redate returns to DRAFT; DRAFT/REVIEWED → CANCELLED;
/// REVERSED is derived from a posted reversal, only while every affected
/// period is OPEN. With the second-checker rule in force (D24), finalize
/// refuses a draft that someone other than its maker has not reviewed.
/// Queries filter for a Fund-only viewer: only transactions with a part in
/// their Funds (or that they made), sliced to those parts (README 3.5).
abstract interface class TransactionRepository {
  /// Transactions dated in [periodId] ('yyyy-mm'; every period when null),
  /// cancelled ones included, in date then posting order.
  List<Transaction> list(
    String? periodId, [
    TransactionFilter filter = const TransactionFilter(),
  ]);

  Transaction? get(String id);

  /// DRAFT and REVIEWED transactions, dated in [periodId] when given.
  List<Transaction> drafts({String? periodId});

  /// Every number of [series] in [year], 1 up to the last given: posted or
  /// allocated without a transaction (DM F12).
  List<VoucherEntry> voucherSeries(VoucherSeries series, int year);

  /// The numbers of [series] in [year] given without a posted transaction.
  List<VoucherEntry> gaps(VoucherSeries series, int year);

  /// A new DRAFT; several allocations make a split. No number yet.
  Future<Result<Transaction>> createDraft(
    Actor actor,
    TransactionDraft draft, {
    required String idempotencyKey,
  });

  Future<Result<Transaction>> editDraft(
    Actor actor,
    String id,
    TransactionPatch patch, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// "Tandai sudah diperiksa": the maker is not the checker, and a covering
  /// Operator is not the checker.
  Future<Result<Transaction>> review(
    Actor actor,
    String id, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// "Bukukan": returns the voucher ('BKU-{year}-{NNNN}'), the next free
  /// number of the effective date's year.
  Future<Result<String>> finalize(
    Actor actor,
    String id, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  Future<Result<Transaction>> cancel(
    Actor actor,
    String id, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// "Pindah tanggal" into an OPEN period (RD09).
  Future<Result<Transaction>> redate(
    Actor actor,
    String id,
    Tanggal newDate, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// A reversal DRAFT of a posted transaction, dated today; it reverses the
  /// original once finalized. [expectedRevision] is the original's.
  Future<Result<Transaction>> reverse(
    Actor actor,
    String id, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// A reversal DRAFT plus the [replacement] DRAFT linked to the original.
  Future<Result<Correction>> correct(
    Actor actor,
    String id,
    TransactionDraft replacement, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  });
}
