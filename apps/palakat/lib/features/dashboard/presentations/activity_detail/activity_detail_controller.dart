import 'package:palakat/features/dashboard/presentations/activity_detail/activity_detail_state.dart';
import 'package:palakat_shared/core/models/models.dart';
import 'package:palakat_shared/core/repositories/repositories.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'activity_detail_controller.g.dart';

@riverpod
class ActivityDetailController extends _$ActivityDetailController {
  @override
  ActivityDetailState build(int activityId) {
    Future.microtask(() => _initialize());
    return const ActivityDetailState();
  }

  ActivityRepository get _activityRepo => ref.read(activityRepositoryProvider);
  AuthRepository get _authRepo => ref.read(authRepositoryProvider);
  ApproverRepository get _approverRepo => ref.read(approverRepositoryProvider);

  /// Initializes the controller by fetching both the activity and current membership.
  Future<void> _initialize() async {
    await Future.wait([fetchActivity(), _fetchCurrentMembership()]);
  }

  /// Fetches the current user's membership for self-approval detection.
  /// Requirements: 8.1
  Future<void> _fetchCurrentMembership() async {
    final result = await _authRepo.getSignedInAccount();
    result.when(
      onSuccess: (account) {
        state = state.copyWith(currentMembership: account?.membership);
      },
      onFailure: (_) {
        // Silently fail - self-approval features will be disabled
      },
    );
  }

  Future<void> fetchActivity() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _activityRepo.fetchActivity(activityId: activityId);

    result.when(
      onSuccess: (activity) {
        state = state.copyWith(isLoading: false, activity: activity);
      },
      onFailure: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
    );
  }

  /// Approves the supervisor's own approver record.
  /// Requirements: 8.3
  Future<bool> approveSelfApproval() async {
    final approverRecord = state.supervisorApproverRecord;
    if (approverRecord == null || approverRecord.id == null) return false;

    state = state.copyWith(isApprovalLoading: true);

    final result = await _approverRepo.updateApprover(
      approverId: approverRecord.id!,
      update: {'status': ApprovalStatus.approved.name.toUpperCase()},
    );

    bool success = false;
    result.when(
      onSuccess: (updatedApprover) {
        _updateApproverInActivity(updatedApprover);
        state = state.copyWith(isApprovalLoading: false);
        success = true;
      },
      onFailure: (failure) {
        state = state.copyWith(
          isApprovalLoading: false,
          errorMessage: failure.message,
        );
      },
    );
    return success;
  }

  /// Rejects the supervisor's own approver record.
  /// Requirements: 8.4
  Future<bool> rejectSelfApproval() async {
    final approverRecord = state.supervisorApproverRecord;
    if (approverRecord == null || approverRecord.id == null) return false;

    state = state.copyWith(isApprovalLoading: true);

    final result = await _approverRepo.updateApprover(
      approverId: approverRecord.id!,
      update: {'status': ApprovalStatus.rejected.name.toUpperCase()},
    );

    bool success = false;
    result.when(
      onSuccess: (updatedApprover) {
        _updateApproverInActivity(updatedApprover);
        state = state.copyWith(isApprovalLoading: false);
        success = true;
      },
      onFailure: (failure) {
        state = state.copyWith(
          isApprovalLoading: false,
          errorMessage: failure.message,
        );
      },
    );
    return success;
  }

  /// Updates the approver in the activity's approvers list after a status change.
  void _updateApproverInActivity(Approver updatedApprover) {
    final activity = state.activity;
    if (activity == null) return;

    final updatedApprovers = activity.approvers.map((a) {
      if (a.id == updatedApprover.id) {
        return updatedApprover;
      }
      return a;
    }).toList();

    state = state.copyWith(
      activity: activity.copyWith(approvers: updatedApprovers),
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
