import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_shared/core/models/models.dart';

part 'activity_detail_state.freezed.dart';

@freezed
abstract class ActivityDetailState with _$ActivityDetailState {
  const ActivityDetailState._();

  const factory ActivityDetailState({
    @Default(true) bool isLoading,
    Activity? activity,
    String? errorMessage,

    /// Current user's membership for self-approval detection
    Membership? currentMembership,

    /// Loading state for approval action
    @Default(false) bool isApprovalLoading,
  }) = _ActivityDetailState;

  /// Checks if the current user (supervisor) is also an approver for this activity.
  /// Returns true if the current user's membership ID is in the approvers list.
  /// Requirements: 8.1
  bool get isSupervisorAlsoApprover {
    if (currentMembership == null || activity == null) return false;
    final currentMembershipId = currentMembership!.id;
    return activity!.approvers.any(
      (a) => a.membershipId == currentMembershipId,
    );
  }

  /// Gets the approver record for the current user (supervisor) if they are an approver.
  /// Returns null if the supervisor is not an approver.
  /// Requirements: 8.1
  Approver? get supervisorApproverRecord {
    if (currentMembership == null || activity == null) return null;
    final currentMembershipId = currentMembership!.id;
    return activity!.approvers.cast<Approver?>().firstWhere(
      (a) => a?.membershipId == currentMembershipId,
      orElse: () => null,
    );
  }

  /// Checks if the supervisor's approver record is pending (unconfirmed).
  /// Returns true if the supervisor is an approver and their status is unconfirmed.
  bool get isSupervisorApprovalPending {
    final record = supervisorApproverRecord;
    return record != null && record.status == ApprovalStatus.unconfirmed;
  }
}
