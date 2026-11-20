import '../../domain/collaboration/collaboration.dart';
import '../../domain/core/core.dart';

/// Panitia (README 4.5; rulebook 14.4, DL27): PLANNING → ACTIVE → EVENT
/// COMPLETED → FINANCIAL CLOSING → CLOSED → ARCHIVED. The authorized church
/// officer creates and moves it; the church Bendahara approves where its
/// leftover money goes.
abstract interface class PanitiaRepository {
  /// Oldest first.
  List<Panitia> list();
  Panitia? get(String id);

  /// Its money from the ledger (DP27). Beyond README 4.5: Panitia,
  /// AlurPanitia and LaporanLintas show it.
  PanitiaMoney money(String id);

  /// [name] is beyond README 4.5 (AlurPanitiaBaru types it). Refused
  /// without a decision document in Dokumen gereja or without three distinct
  /// officers. Creates the Panitia's scope; starts in PLANNING.
  Future<Result<Panitia>> create(
    Actor actor,
    String name,
    String skDocumentId,
    PanitiaOfficers officers, {
    required String idempotencyKey,
  });

  /// To the next stage. ACTIVE creates its peruntukan and tells the
  /// officers; CLOSED needs every advance accounted for, the Fund at Rp0 and
  /// the leftover's destination approved.
  Future<Result<Panitia>> advanceStage(
    Actor actor,
    String id, {
    String? reason,
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// During FINANCIAL CLOSING, once every advance is accounted for.
  Future<Result<Panitia>> approveLeftover(
    Actor actor,
    String id,
    String destinationFundId, {
    required int expectedRevision,
    required String idempotencyKey,
  });
}
