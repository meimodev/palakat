import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';

/// Advances, transit and claims (README 4.2, DM 5.4). Every command but
/// [recordClaim] creates the linked transaction as a DRAFT through
/// `TransactionRepository.createDraft` and returns its id; it goes through
/// the normal review and finalize. Outstanding amounts and states come from
/// FINALIZED linked transactions only. The draft uses the case's Fund (EC06).
abstract interface class CaseRepository {
  List<CaseView> advances();
  List<CaseView> transits();
  List<CaseView> claims();

  /// With derived outstanding and an overdue flag at today.
  CaseView? caseById(String id);

  /// Opens an advance case and drafts its "Uang Muka diberikan".
  Future<Result<String>> issueAdvance(
    Actor actor,
    CaseDraft caseDraft, {
    required String idempotencyKey,
  });

  /// Accepted spending; above the outstanding it is refused and offered as
  /// Penggantian biaya.
  Future<Result<String>> settle(
    Actor actor,
    String caseId,
    CaseEntryDraft draft, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  Future<Result<String>> returnUnused(
    Actor actor,
    String caseId,
    CaseEntryDraft draft, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  Future<Result<String>> collectTransit(
    Actor actor,
    String caseId,
    CaseEntryDraft draft, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  Future<Result<String>> remit(
    Actor actor,
    String caseId,
    CaseEntryDraft draft, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// Returns the claim case id; no transaction (a claim is pre-post).
  Future<Result<String>> recordClaim(
    Actor actor,
    ClaimDraft claimDraft, {
    required String idempotencyKey,
  });

  /// "Cek klaim": records who checked the claim; no balance changes.
  Future<Result<FinanceCase>> checkClaim(
    Actor actor,
    String claimId, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  Future<Result<String>> payClaim(
    Actor actor,
    String claimId,
    CaseEntryDraft draft, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// A new transaction linked to [originalTxnId] (`refundOf`), at most its
  /// amount less earlier refunds (D25, pending RD04), on [accountId] or the
  /// original's Kas/Bank.
  Future<Result<String>> refund(
    Actor actor,
    String originalTxnId,
    int amount, {
    String? accountId,
    required String reason,
    required String idempotencyKey,
  });
}
