import 'package:palakat_shared/core/constants/date_range_preset.dart';
import 'package:palakat_shared/core/models/models.dart';
import 'package:palakat/features/approval/presentations/approval_item.dart';

/// Filter status for approval screen grouping
enum ApprovalFilterStatus {
  all,
  pendingMyAction,
  pendingOthers,
  approved,
  rejected,
}

class ApprovalState {
  const ApprovalState({
    this.membership,
    this.loadingScreen = true,
    this.isRefreshing = false,
    this.allApprovals = const <ApprovalItem>[],
    // Status-based grouping
    this.pendingMyAction = const <ApprovalItem>[],
    this.pendingOthers = const <ApprovalItem>[],
    this.approved = const <ApprovalItem>[],
    this.rejected = const <ApprovalItem>[],
    // Date filter fields
    this.filterStartDate,
    this.filterEndDate,
    this.datePreset = DateRangePreset.thisWeek,
    // Status filter
    this.statusFilter = ApprovalFilterStatus.pendingMyAction,
    // Computed/derived list based on filters
    this.filteredApprovals = const <ApprovalItem>[],
    this.errorMessage,
    // Pagination fields
    this.currentPage = 1,
    this.pageSize = 20,
    this.totalItems = 0,
    this.isLoadingMore = false,
    this.hasMoreData = true,
  });

  static const Object _unset = Object();

  final Membership? membership;
  final bool loadingScreen;
  final bool isRefreshing;
  final List<ApprovalItem> allApprovals;
  final List<ApprovalItem> pendingMyAction;
  final List<ApprovalItem> pendingOthers;
  final List<ApprovalItem> approved;
  final List<ApprovalItem> rejected;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  final DateRangePreset datePreset;
  final ApprovalFilterStatus statusFilter;
  final List<ApprovalItem> filteredApprovals;
  final String? errorMessage;
  final int currentPage;
  final int pageSize;
  final int totalItems;
  final bool isLoadingMore;
  final bool hasMoreData;

  int get activeFilterCount {
    var count = 0;
    if (statusFilter != ApprovalFilterStatus.all) {
      count += 1;
    }
    if (datePreset != DateRangePreset.allTime) {
      count += 1;
    }
    return count;
  }

  bool get hasActiveFilters => activeFilterCount > 0;

  ApprovalState copyWith({
    Object? membership = _unset,
    bool? loadingScreen,
    bool? isRefreshing,
    List<ApprovalItem>? allApprovals,
    List<ApprovalItem>? pendingMyAction,
    List<ApprovalItem>? pendingOthers,
    List<ApprovalItem>? approved,
    List<ApprovalItem>? rejected,
    Object? filterStartDate = _unset,
    Object? filterEndDate = _unset,
    DateRangePreset? datePreset,
    ApprovalFilterStatus? statusFilter,
    List<ApprovalItem>? filteredApprovals,
    Object? errorMessage = _unset,
    int? currentPage,
    int? pageSize,
    int? totalItems,
    bool? isLoadingMore,
    bool? hasMoreData,
  }) {
    return ApprovalState(
      membership: identical(membership, _unset)
          ? this.membership
          : membership as Membership?,
      loadingScreen: loadingScreen ?? this.loadingScreen,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      allApprovals: allApprovals ?? this.allApprovals,
      pendingMyAction: pendingMyAction ?? this.pendingMyAction,
      pendingOthers: pendingOthers ?? this.pendingOthers,
      approved: approved ?? this.approved,
      rejected: rejected ?? this.rejected,
      filterStartDate: identical(filterStartDate, _unset)
          ? this.filterStartDate
          : filterStartDate as DateTime?,
      filterEndDate: identical(filterEndDate, _unset)
          ? this.filterEndDate
          : filterEndDate as DateTime?,
      datePreset: datePreset ?? this.datePreset,
      statusFilter: statusFilter ?? this.statusFilter,
      filteredApprovals: filteredApprovals ?? this.filteredApprovals,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      totalItems: totalItems ?? this.totalItems,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMoreData: hasMoreData ?? this.hasMoreData,
    );
  }
}
