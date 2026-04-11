import 'package:flutter/material.dart';
import 'package:palakat/features/approval/presentations/approval_item.dart';
import 'package:palakat/features/approval/presentations/approval_state.dart';
import 'package:palakat_shared/core/constants/date_range_preset.dart';
import 'package:palakat_shared/core/models/models.dart';
import 'package:palakat_shared/core/repositories/repositories.dart';
import 'package:palakat_shared/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'approval_controller.g.dart';

@riverpod
class ApprovalController extends _$ApprovalController {
  AuthRepository get _authRepository => ref.read(authRepositoryProvider);
  ActivityRepository get _activityRepository =>
      ref.read(activityRepositoryProvider);
  ApproverRepository get _approverRepository =>
      ref.read(approverRepositoryProvider);
  FinanceRepository get _financeRepository =>
      ref.read(financeRepositoryProvider);

  @override
  ApprovalState build() {
    final socket = ref.read(socketServiceProvider);
    var previousConnectionStatus = socket.connectionStatus;

    void onSocketStatusChanged() {
      final nextStatus = socket.connectionStatus;
      final didReconnect =
          previousConnectionStatus != SocketConnectionStatus.connected &&
          nextStatus == SocketConnectionStatus.connected;
      previousConnectionStatus = nextStatus;

      if (!didReconnect) {
        return;
      }

      if (state.membership == null) {
        return;
      }

      Future.microtask(_refreshFirstPageFromRealtime);
    }

    socket.connectionStatusListenable.addListener(onSocketStatusChanged);
    ref.onDispose(() {
      socket.connectionStatusListenable.removeListener(onSocketStatusChanged);
    });

    ref.listen(realtimeEventProvider, (_, next) {
      final event = next.asData?.value;
      if (event == null) {
        return;
      }

      if (!_shouldRefreshForRealtimeEvent(event)) {
        return;
      }

      Future.microtask(_refreshFirstPageFromRealtime);
    });

    final initialState = _createInitialState();
    Future.microtask(fetchData);
    return initialState;
  }

  bool _isActivityEventName(String eventName) {
    return eventName == 'activity.created' ||
        eventName == 'activity.updated' ||
        eventName == 'activity.deleted';
  }

  bool _isFinanceEventName(String eventName) {
    return eventName == 'finance.created' ||
        eventName == 'finance.updated' ||
        eventName == 'finance.deleted';
  }

  Map<String, dynamic>? _extractEventData(RealtimeEvent event) {
    final data = event.payload['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  List<int> _extractAffectedMembershipIds(RealtimeEvent event) {
    final data = _extractEventData(event);
    final rawIds = data?['affectedMembershipIds'];
    if (rawIds is! List) {
      return const [];
    }

    return rawIds
        .map((value) => value is int ? value : int.tryParse('$value'))
        .whereType<int>()
        .toList(growable: false);
  }

  bool _shouldRefreshForRealtimeEvent(RealtimeEvent event) {
    if (!_isActivityEventName(event.name) && !_isFinanceEventName(event.name)) {
      return false;
    }

    final membershipId = state.membership?.id;
    if (membershipId == null) {
      return false;
    }

    final affectedMembershipIds = _extractAffectedMembershipIds(event);
    return affectedMembershipIds.contains(membershipId);
  }

  Future<void> _refreshFirstPageFromRealtime() async {
    if (state.membership == null) {
      return;
    }

    state = state.copyWith(
      currentPage: 1,
      hasMoreData: true,
      isLoadingMore: false,
    );

    await fetchApprovals(isLoadMore: false);
  }

  ApprovalState _createInitialState() {
    final dateRange = _resolveDateRange(DateRangePreset.thisWeek);
    return ApprovalState(
      statusFilter: ApprovalFilterStatus.pendingMyAction,
      datePreset: DateRangePreset.thisWeek,
      filterStartDate: dateRange?.start,
      filterEndDate: dateRange?.end,
    );
  }

  void fetchData() async {
    await fetchMembership();
    await fetchApprovals();
  }

  Future<void> fetchMembership() async {
    final result = await _authRepository.getSignedInAccount();
    result.when(
      onSuccess: (account) {
        state = state.copyWith(membership: account?.membership);
      },
      onFailure: (failure) {
        state = state.copyWith(
          loadingScreen: false,
          errorMessage: failure.message,
        );
      },
    );
  }

  Future<void> fetchApprovals({bool isLoadMore = false}) async {
    final membership = state.membership;
    if (membership == null) {
      state = state.copyWith(loadingScreen: false);
      return;
    }

    if (isLoadMore && (state.isLoadingMore || !state.hasMoreData)) {
      return;
    }

    if (isLoadMore) {
      state = state.copyWith(isLoadingMore: true);
    }

    final page = isLoadMore ? state.currentPage + 1 : 1;
    final activityRequest = PaginationRequestWrapper<GetFetchActivitiesRequest>(
      page: page,
      pageSize: state.pageSize,
      data: GetFetchActivitiesRequest(
        membershipId: membership.id,
        startDate: state.filterStartDate,
        endDate: state.filterEndDate,
      ),
    );
    final financeRequest =
        PaginationRequestWrapper<GetFetchFinanceEntriesRequest>(
          page: page,
          pageSize: state.pageSize,
          data: GetFetchFinanceEntriesRequest(
            startDate: state.filterStartDate,
            endDate: state.filterEndDate,
          ),
        );

    final activityResult = await _activityRepository.fetchActivities(
      paginationRequest: activityRequest,
    );
    final financeResult = await _financeRepository.fetchApprovalFinanceEntries(
      paginationRequest: financeRequest,
    );

    PaginationResponseWrapper<Activity>? activityResponse;
    PaginationResponseWrapper<FinanceEntry>? financeResponse;
    Failure? failure;

    activityResult.when(
      onSuccess: (response) {
        activityResponse = response;
      },
      onFailure: (err) {
        failure = err;
      },
    );
    financeResult.when(
      onSuccess: (response) {
        financeResponse = response;
      },
      onFailure: (err) {
        failure ??= err;
      },
    );

    if (failure != null ||
        activityResponse == null ||
        financeResponse == null) {
      state = state.copyWith(
        loadingScreen: false,
        isLoadingMore: false,
        errorMessage: failure?.message ?? 'Failed to load approvals',
      );
      return;
    }

    final newItems = <ApprovalItem>[
      ...activityResponse!.data.map(ApprovalItem.activity),
      ...financeResponse!.data.map(ApprovalItem.finance),
    ];

    List<ApprovalItem> updatedItems;
    if (isLoadMore) {
      updatedItems = _dedupeApprovalItems([...state.allApprovals, ...newItems]);
    } else {
      updatedItems = _dedupeApprovalItems(newItems);
    }
    updatedItems.sort(_compareApprovalItems);

    state = state.copyWith(
      allApprovals: updatedItems,
      loadingScreen: false,
      isLoadingMore: false,
      currentPage: page,
      totalItems:
          activityResponse!.pagination.total +
          financeResponse!.pagination.total,
      hasMoreData:
          activityResponse!.pagination.hasNext ||
          financeResponse!.pagination.hasNext,
      errorMessage: null,
    );
    _groupApprovalsByStatus();
    _applyFilters();
  }

  List<ApprovalItem> _dedupeApprovalItems(List<ApprovalItem> items) {
    final map = <String, ApprovalItem>{};
    for (final item in items) {
      map[item.uniqueKey] = item;
    }
    return map.values.toList(growable: false);
  }

  int _compareApprovalItems(ApprovalItem a, ApprovalItem b) {
    final aDate = a.updatedAtValue ?? a.createdAtValue ?? a.displayDate;
    final bDate = b.updatedAtValue ?? b.createdAtValue ?? b.displayDate;

    if (aDate == null && bDate == null) return 0;
    if (aDate == null) return 1;
    if (bDate == null) return -1;
    return bDate.compareTo(aDate);
  }

  Future<void> loadMore() async {
    await fetchApprovals(isLoadMore: true);
  }

  void _groupApprovalsByStatus() {
    final membership = state.membership;
    if (membership == null) return;

    final pendingMyAction = <ApprovalItem>[];
    final pendingOthers = <ApprovalItem>[];
    final approved = <ApprovalItem>[];
    final rejected = <ApprovalItem>[];

    for (final item in state.allApprovals) {
      final status = _getApprovalStatusForUser(item, membership.id);
      switch (status) {
        case _ApprovalUserStatus.pendingMyAction:
          pendingMyAction.add(item);
          break;
        case _ApprovalUserStatus.pendingOthers:
          pendingOthers.add(item);
          break;
        case _ApprovalUserStatus.approved:
          approved.add(item);
          break;
        case _ApprovalUserStatus.rejected:
          rejected.add(item);
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

  _ApprovalUserStatus _getApprovalStatusForUser(
    ApprovalItem item,
    int? membershipId,
  ) {
    final approvers = item.approvers;
    if (approvers.isEmpty) {
      return _ApprovalUserStatus.pendingOthers;
    }

    final hasRejection = approvers.any(
      (a) => a.status == ApprovalStatus.rejected,
    );
    if (hasRejection) {
      return _ApprovalUserStatus.rejected;
    }

    final allApproved = approvers.every(
      (a) => a.status == ApprovalStatus.approved,
    );
    if (allApproved) {
      return _ApprovalUserStatus.approved;
    }

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
      return _ApprovalUserStatus.pendingMyAction;
    }

    return _ApprovalUserStatus.pendingOthers;
  }

  Future<void> applyFilters({
    required ApprovalFilterStatus statusFilter,
    required DateRangePreset datePreset,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final normalizedStart = startDate == null ? null : _atStartOfDay(startDate);
    final normalizedEnd = endDate == null ? null : _atEndOfDay(endDate);
    final dateChanged =
        state.datePreset != datePreset ||
        !_isSameDateTime(state.filterStartDate, normalizedStart) ||
        !_isSameDateTime(state.filterEndDate, normalizedEnd);

    state = state.copyWith(
      statusFilter: statusFilter,
      datePreset: datePreset,
      filterStartDate: normalizedStart,
      filterEndDate: normalizedEnd,
      currentPage: dateChanged ? 1 : state.currentPage,
      hasMoreData: dateChanged ? true : state.hasMoreData,
      isLoadingMore: false,
    );
    _applyFilters();

    if (!dateChanged) {
      return;
    }

    state = state.copyWith(loadingScreen: true);
    await fetchApprovals(isLoadMore: false);
  }

  void setStatusFilter(ApprovalFilterStatus status) {
    state = state.copyWith(statusFilter: status);
    _applyFilters();
  }

  Future<void> refresh() async {
    state = state.copyWith(
      isRefreshing: true,
      currentPage: 1,
      hasMoreData: true,
    );
    await fetchApprovals(isLoadMore: false);
    state = state.copyWith(isRefreshing: false);
  }

  void _applyFilters() {
    final statusFilter = state.statusFilter;

    List<ApprovalItem> baseList;
    switch (statusFilter) {
      case ApprovalFilterStatus.all:
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

    state = state.copyWith(filteredApprovals: baseList);
  }

  DateTimeRange? _resolveDateRange(DateRangePreset preset) {
    return preset.getDateRange();
  }

  bool _isSameDateTime(DateTime? first, DateTime? second) {
    if (first == null && second == null) return true;
    if (first == null || second == null) return false;
    return first.isAtSameMomentAs(second);
  }

  DateTime _atStartOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime _atEndOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59, 999);

  Future<void> approveItem(ApprovalItem item, int approverId) async {
    final result = item.isActivity
        ? await _approverRepository.updateApprover(
            approverId: approverId,
            update: {'status': 'APPROVED'},
          )
        : await _financeRepository.updateFinanceApprover(
            approverId: approverId,
            type: item.financeEntry!.type,
            status: ApprovalStatus.approved,
          );

    result.when(
      onSuccess: (_) {
        fetchApprovals();
      },
      onFailure: (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
    );
  }

  Future<void> rejectItem(ApprovalItem item, int approverId) async {
    final result = item.isActivity
        ? await _approverRepository.updateApprover(
            approverId: approverId,
            update: {'status': 'REJECTED'},
          )
        : await _financeRepository.updateFinanceApprover(
            approverId: approverId,
            type: item.financeEntry!.type,
            status: ApprovalStatus.rejected,
          );

    result.when(
      onSuccess: (_) {
        fetchApprovals();
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

enum _ApprovalUserStatus { pendingMyAction, pendingOthers, approved, rejected }
