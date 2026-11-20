import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';

/// Supporting documents (README 4.2, DM 5.3): status changes only, no
/// checksum. Uploaded is not verified.
abstract interface class EvidenceRepository {
  /// The decision lines of a transaction, oldest first.
  List<EvidenceItem> forTransaction(String id);

  /// Transactions dated in [periodId] with their evidence status; [status]
  /// narrows. Cancelled transactions are left out.
  List<({Transaction transaction, EvidenceStatus status})> list(
    String periodId,
    EvidenceStatus? status,
  );

  /// [expectedRevision] is the transaction's.
  Future<Result<EvidenceItem>> upload(
    Actor actor,
    String txnId,
    SampleFile file, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  Future<Result<EvidenceItem>> verify(
    Actor actor,
    String evidenceId, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  Future<Result<EvidenceItem>> reject(
    Actor actor,
    String evidenceId, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// "Dikecualikan" with a reason. [expectedRevision] is the transaction's.
  Future<Result<EvidenceItem>> acceptException(
    Actor actor,
    String txnId, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  });

  Future<Result<EvidenceItem>> release(
    Actor actor,
    String evidenceId, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  });
}
