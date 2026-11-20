import '../../domain/collaboration/collaboration.dart';
import '../../domain/core/core.dart';

/// The approver table (README 4.5, DL29): defaults until filled.
abstract interface class ApproverTableRepository {
  ApproverTable table();

  /// One row of the table, and the church's threshold.
  Future<Result<ApproverTable>> set(
    Actor actor,
    ScopeType unitType,
    ApproverChoice approverRole,
    int threshold, {
    required int expectedRevision,
    required String idempotencyKey,
  });
}
