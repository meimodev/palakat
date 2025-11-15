import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/approver.dart';

/// Extension methods for List of approver
extension ApproverListExtension on List<Approver> {
  /// Calculate overall approval status from individual approver decisions
  ///
  /// Returns:
  /// - [ApprovalStatus.approved] if all approvers have approved status
  /// - [ApprovalStatus.rejected] if any approver has rejected status
  /// - [ApprovalStatus.unconfirmed] otherwise (including empty list)
  ApprovalStatus get approvalStatus {
    if (isEmpty) return ApprovalStatus.unconfirmed;

    // Check if any approver rejected
    final hasRejected = any(
      (approver) => approver.status == ApprovalStatus.rejected,
    );
    if (hasRejected) return ApprovalStatus.rejected;

    // Check if all approvers approved
    final allApproved = every(
      (approver) => approver.status == ApprovalStatus.approved,
    );
    if (allApproved) return ApprovalStatus.approved;

    // Otherwise unconfirmed (some pending or mixed states)
    return ApprovalStatus.unconfirmed;
  }

  DateTime get approvalDate {
    if (isEmpty) return DateTime.now();

    final dates = where((approver) => approver.updatedAt != null)
        .map((approver) => approver.updatedAt!)
        .toList();

    if (dates.isEmpty) return DateTime.now();

    dates.sort((a, b) => b.compareTo(a));
    return dates.first;
  }
}
