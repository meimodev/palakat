import 'package:palakat_shared/core/models/models.dart';
import 'package:palakat_shared/core/repositories/repositories.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat/features/approval/presentations/approval_state.dart';

part 'approval_controller.g.dart';

@riverpod
class ApprovalController extends _$ApprovalController {
  AuthRepository get _authRepository => ref.read(authRepositoryProvider);
  ActivityRepository get _activityRepository =>
      ref.read(activityRepositoryProvider);
  ApproverRepository get _approverRepository =>
      ref.read(approverRepositoryProvider);

  @override
  ApprovalState build() {
    fetchData();
    return const ApprovalState();
  }

  void fetchData() async {
    await fetchMembership();
    await fetchActivities();
  }

  Future<void> fetchMembership() async {
    final result = await _authRepository.getSignedInAccount();
    result.when(
      onSuccess: (account) {
        state = state.copyWith(
          membership: account?.membership,
          loadingScreen: false,
        );
      },
      onFailure: (failure) {
        state = state.copyWith(
          loadingScreen: false,
          errorMessage: failure.message,
        );
      },
    );
  }

  /// Fetch activities from the API and group them by status
  /// [isLoadMore] - if true, appends to existing list; if false, replaces list
  Future<void> fetchActivities({bool isLoadMore = false}) async {
    final membership = state.membership;
    if (membership == null) return;

    // Don't fetch if already loading more or no more data
    if (isLoadMore && (state.isLoadingMore || !state.hasMoreData)) return;

    if (isLoadMore) {
      state = state.copyWith(isLoadingMore: true);
    }

    final page = isLoadMore ? state.currentPage + 1 : 1;

    final request = PaginationRequestWrapper<GetFetchActivitiesRequest>(
      page: page,
      pageSize: state.pageSize,
      data: GetFetchActivitiesRequest(membershipId: membership.id),
    );

    final result = await _activityRepository.fetchActivities(
      paginationRequest: request,
    );

    result.when(
      onSuccess: (response) {
        final newActivities = response.data;
        final total = response.pagination.total;

        // Determine if there's more data to load
        final hasMore = response.pagination.hasNext;

        List<Activity> updatedActivities;
        if (isLoadMore) {
          // Append new activities to existing list
          updatedActivities = [...state.allActivities, ...newActivities];
        } else {
          // Replace with new activities
          updatedActivities = newActivities;
        }

        state = state.copyWith(
          allActivities: updatedActivities,
          loadingScreen: false,
          isLoadingMore: false,
          currentPage: page,
          totalItems: total,
          hasMoreData: hasMore,
        );
        _groupActivitiesByStatus();
        _applyFilters();
      },
      onFailure: (failure) {
        state = state.copyWith(
          loadingScreen: false,
          isLoadingMore: false,
          errorMessage: failure.message,
        );
      },
    );
  }

  /// Load more activities for infinite scrolling
  Future<void> loadMore() async {
    await fetchActivities(isLoadMore: true);
  }

  /// Group activities by their approval status relative to the current user
  void _groupActivitiesByStatus() {
    final membership = state.membership;
    if (membership == null) return;

    final pendingMyAction = <Activity>[];
    final pendingOthers = <Activity>[];
    final approved = <Activity>[];
    final rejected = <Activity>[];

    for (final activity in state.allActivities) {
      final status = _getActivityStatusForUser(activity, membership.id);
      switch (status) {
        case _ActivityUserStatus.pendingMyAction:
          pendingMyAction.add(activity);
          break;
        case _ActivityUserStatus.pendingOthers:
          pendingOthers.add(activity);
          break;
        case _ActivityUserStatus.approved:
          approved.add(activity);
          break;
        case _ActivityUserStatus.rejected:
          rejected.add(activity);
          break;
      }
    }

    state = state.copyWith(
      pendingMyAction: pendingMyAction,
      pendingOthers: pendingOthers,
      approved: approved,
      rejected: rejected,
    );
  }

  /// Determine the status of an activity for the current user
  _ActivityUserStatus _getActivityStatusForUser(
    Activity activity,
    int? membershipId,
  ) {
    final approvers = activity.approvers;
    if (approvers.isEmpty) {
      return _ActivityUserStatus.pendingOthers;
    }

    // Check if any approver has rejected
    final hasRejection = approvers.any(
      (a) => a.status == ApprovalStatus.rejected,
    );
    if (hasRejection) {
      return _ActivityUserStatus.rejected;
    }

    // Check if all approvers have approved
    final allApproved = approvers.every(
      (a) => a.status == ApprovalStatus.approved,
    );
    if (allApproved) {
      return _ActivityUserStatus.approved;
    }

    // Check if current user has pending action
    final userApprover = approvers.firstWhere(
      (a) => a.membership?.id == membershipId,
      orElse: () => const Approver(
        id: -1,
        status: ApprovalStatus.approved,
        createdAt: null,
        updatedAt: null,
      ),
    );

    if (userApprover.id != -1 &&
        userApprover.status == ApprovalStatus.unconfirmed) {
      return _ActivityUserStatus.pendingMyAction;
    }

    return _ActivityUserStatus.pendingOthers;
  }

  // Date filter controls
  void setDateRange({DateTime? start, DateTime? end}) {
    state = state.copyWith(filterStartDate: start, filterEndDate: end);
    _applyFilters();
  }

  void clearDateFilter() {
    state = state.copyWith(filterStartDate: null, filterEndDate: null);
    _applyFilters();
  }

  /// Set the status filter and update the filtered list
  void setStatusFilter(ApprovalFilterStatus status) {
    state = state.copyWith(statusFilter: status);
    _applyFilters();
  }

  /// Refresh the activity list (for pull-to-refresh)
  Future<void> refresh() async {
    state = state.copyWith(
      isRefreshing: true,
      currentPage: 1,
      hasMoreData: true,
    );
    await fetchActivities(isLoadMore: false);
    state = state.copyWith(isRefreshing: false);
  }

  void _applyFilters() {
    final start = state.filterStartDate;
    final end = state.filterEndDate;
    final statusFilter = state.statusFilter;

    // Get the base list based on status filter
    List<Activity> baseList;
    switch (statusFilter) {
      case ApprovalFilterStatus.all:
        // Combine all lists with pending my action first
        baseList = [
          ...state.pendingMyAction,
          ...state.pendingOthers,
          ...state.approved,
          ...state.rejected,
        ];
        break;
      case ApprovalFilterStatus.pendingMyAction:
        baseList = state.pendingMyAction;
        break;
      case ApprovalFilterStatus.pendingOthers:
        baseList = state.pendingOthers;
        break;
      case ApprovalFilterStatus.approved:
        baseList = state.approved;
        break;
      case ApprovalFilterStatus.rejected:
        baseList = state.rejected;
        break;
    }

    // Apply date filter if set
    if (start == null && end == null) {
      state = state.copyWith(filteredApprovals: baseList);
      return;
    }

    bool inRange(DateTime d) {
      final sOk = start == null || !d.isBefore(_atStartOfDay(start));
      final eOk = end == null || !d.isAfter(_atEndOfDay(end));
      return sOk && eOk;
    }

    final filtered = baseList.where((a) {
      final activityDate = a.createdAt;
      return inRange(activityDate);
    }).toList();

    state = state.copyWith(filteredApprovals: filtered);
  }

  DateTime _atStartOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime _atEndOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59, 999);

  /// Approve an activity by updating the approver status
  Future<void> approveActivity(int activityId, int approverId) async {
    final result = await _approverRepository.updateApprover(
      approverId: approverId,
      update: {'status': 'APPROVED'},
    );

    result.when(
      onSuccess: (_) {
        // Refresh the activity list after approval
        fetchActivities();
      },
      onFailure: (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
    );
  }

  /// Reject an activity by updating the approver status
  Future<void> rejectActivity(int activityId, int approverId) async {
    final result = await _approverRepository.updateApprover(
      approverId: approverId,
      update: {'status': 'REJECTED'},
    );

    result.when(
      onSuccess: (_) {
        // Refresh the activity list after rejection
        fetchActivities();
      },
      onFailure: (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Internal enum for activity status relative to current user
enum _ActivityUserStatus { pendingMyAction, pendingOthers, approved, rejected }
