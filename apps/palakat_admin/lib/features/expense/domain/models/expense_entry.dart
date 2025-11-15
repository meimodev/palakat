import 'package:palakat_admin/models.dart' hide Column;

class ExpenseEntry {
  final String accountId;
  final DateTime date;
  final String notes;
  final double amount;

  // Approval metadata
  final String approvalId;
  final ApprovalStatus approvalStatus;
  final DateTime? approvedAt;
  final List<Approver> approvers;

  const ExpenseEntry({
    required this.accountId,
    required this.date,
    required this.notes,
    required this.amount,
    required this.approvalId,
    required this.approvalStatus,
    this.approvedAt,
    this.approvers = const [],
  });
}
