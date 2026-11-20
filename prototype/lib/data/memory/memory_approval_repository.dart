import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../repositories/approval_repository.dart';
import 'memory_finance.dart';

/// External approvals. Commands: M3.
class MemoryApprovalRepository implements ApprovalRepository {
  MemoryApprovalRepository(this.f);
  final MemoryFinance f;

  @override
  List<ApprovalRecord> forTransaction(String id) => [
    for (final a in f.k.approvals)
      if (a.transactionId == id) a,
  ];

  @override
  Future<Result<ApprovalRecord>> recordExternal(
    Actor actor,
    String txnId,
    ApprovalDeclaration declaration, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.notYet('Catat persetujuan');

  @override
  Future<Result<ApprovalRecord>> supersede(
    Actor actor,
    String approvalId,
    ApprovalDeclaration declaration, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.notYet('Ganti persetujuan');
}
