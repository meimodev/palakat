import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';

/// Months and the close (README 4.2, DM 5.5, 6.4, RD01, RD08, RD12):
/// OPEN → CLOSED, irreversible, in calendar order.
abstract interface class PeriodRepository {
  /// Calendar order.
  List<Period> periods();
  Period? period(String id);

  /// Computed against state (DM 6.4); empty when it can close.
  List<Blocker> blockers(String periodId);

  /// The Funds that need a readiness attestation for the period, with state.
  List<ReadinessView> attestations(String periodId);

  /// Recording order.
  List<CloseIncident> incidents();

  /// "Nyatakan siap" by the Fund's scoped preparer.
  Future<Result<ReadinessAttestation>> attest(
    Actor actor,
    String fundId,
    String periodId, {
    required String idempotencyKey,
  });

  /// The workspace Treasurer waives a missing attestation (DL33).
  /// [expectedRevision] is the period's.
  Future<Result<ReadinessAttestation>> waive(
    Actor actor,
    String fundId,
    String periodId, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// The church Bendahara clears a unit's blocker with a reason and the unit
  /// gets a notice (DL33). [expectedRevision] is the target's.
  Future<Result<void>> clearUnitBlocker(
    Actor actor,
    BlockerKind kind,
    String targetId, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// Returns the snapshot `SNP-{y}-{mm}-01`.
  Future<Result<ReportSnapshot>> close(
    Actor actor,
    String periodId,
    String confirmation, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// `K-{y}-NN`; a settlement is a DRAFT in the open month.
  Future<Result<CloseIncident>> recordIncident(
    Actor actor,
    String periodId,
    IncidentExplanation explanation,
    TransactionDraft? settlementDraft, {
    required String idempotencyKey,
  });
}
