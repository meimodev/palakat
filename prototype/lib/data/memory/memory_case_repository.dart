import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../repositories/case_repository.dart';
import 'memory_finance.dart';

/// Advances, transit and claims with derived figures. Commands: M3.
class MemoryCaseRepository implements CaseRepository {
  MemoryCaseRepository(this.f);
  final MemoryFinance f;

  List<CaseView> _of(CaseKind kind) => [
    for (final c in f.k.cases)
      if (c.kind == kind) f.k.caseView(c, f.today),
  ];

  @override
  List<CaseView> advances() => _of(CaseKind.advance);

  @override
  List<CaseView> transits() => _of(CaseKind.transit);

  @override
  List<CaseView> claims() => _of(CaseKind.claim);

  @override
  CaseView? caseById(String id) {
    final c = f.k.kase(id);
    return c == null ? null : f.k.caseView(c, f.today);
  }

  @override
  Future<Result<String>> issueAdvance(
    Actor actor,
    CaseDraft caseDraft, {
    required String idempotencyKey,
  }) => f.notYet('Beri uang muka');

  @override
  Future<Result<String>> settle(
    Actor actor,
    String caseId,
    CaseEntryDraft draft, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.notYet('Catat pertanggungjawaban');

  @override
  Future<Result<String>> returnUnused(
    Actor actor,
    String caseId,
    CaseEntryDraft draft, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.notYet('Catat pengembalian sisa');

  @override
  Future<Result<String>> collectTransit(
    Actor actor,
    String caseId,
    CaseEntryDraft draft, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.notYet('Catat titipan');

  @override
  Future<Result<String>> remit(
    Actor actor,
    String caseId,
    CaseEntryDraft draft, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.notYet('Salurkan titipan');

  @override
  Future<Result<String>> recordClaim(
    Actor actor,
    ClaimDraft claimDraft, {
    required String idempotencyKey,
  }) => f.notYet('Catat klaim');

  @override
  Future<Result<String>> payClaim(
    Actor actor,
    String claimId,
    CaseEntryDraft draft, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.notYet('Bayar penggantian biaya');

  @override
  Future<Result<String>> refund(
    Actor actor,
    String originalTxnId,
    int amount, {
    required String reason,
    required String idempotencyKey,
  }) => f.notYet('Catat pengembalian');
}
