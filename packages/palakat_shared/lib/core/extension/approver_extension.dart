import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/approver.dart';

enum ApprovalOverrideStatus {
  approved,
  rejected;

  static ApprovalOverrideStatus? fromString(String? value) {
    if (value == null) return null;
    return ApprovalOverrideStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => ApprovalOverrideStatus.approved,
    );
  }

  String get serverValue => name.toUpperCase();
}

/// Extension methods for List of approver
extension ApproverListExtension on List<Approver> {
  /// Calculate overall approval status from individual approver decisions.
  ///
  /// When the parent entity has [isOverridden] == true the override status
  /// already supersedes this computation, but we retain the normal logic here
  /// so it is still useful for UI display of individual approver chips.
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

/// Resolves the "effective" approval status for an entity that may have been
/// overridden by a church admin.
///
/// Call this instead of [ApproverListExtension.approvalStatus] whenever you
/// need the canonical approval outcome displayed prominently in the UI.
ApprovalStatus effectiveApprovalStatus({
  required List<Approver> approvers,
  required bool isOverridden,
  required ApprovalOverrideStatus? overrideStatus,
}) {
  if (isOverridden && overrideStatus != null) {
    return overrideStatus == ApprovalOverrideStatus.approved
        ? ApprovalStatus.approved
        : ApprovalStatus.rejected;
  }
  return approvers.approvalStatus;
}
