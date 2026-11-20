import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';

/// External approvals (README 4.2, DM 5.2): NOT_REQUIRED; EXTERNAL MISSING →
/// RECORDED, superseded on change; a material change voids it.
abstract interface class ApprovalRepository {
  /// Every record of the transaction, oldest first (superseded included).
  List<ApprovalRecord> forTransaction(String id);

  /// [expectedRevision] is the transaction's.
  Future<Result<ApprovalRecord>> recordExternal(
    Actor actor,
    String txnId,
    ApprovalDeclaration declaration, {
    required int expectedRevision,
    required String idempotencyKey,
  });

  /// "Ganti": the old record stays in Riwayat as "Digantikan".
  Future<Result<ApprovalRecord>> supersede(
    Actor actor,
    String approvalId,
    ApprovalDeclaration declaration, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  });
}
