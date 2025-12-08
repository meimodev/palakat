import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_shared/core/models/models.dart';

part 'approval_state.freezed.dart';

/// Filter status for approval screen grouping
enum ApprovalFilterStatus {
  all,
  pendingMyAction,
  pendingOthers,
  approved,
  rejected,
}

@freezed
abstract class ApprovalState with _$ApprovalState {
  const factory ApprovalState({
    Membership? membership,
    @Default(true) bool loadingScreen,
    @Default(false) bool isRefreshing,
    @Default(<Activity>[]) List<Activity> allActivities,
    // Status-based grouping
    @Default(<Activity>[]) List<Activity> pendingMyAction,
    @Default(<Activity>[]) List<Activity> pendingOthers,
    @Default(<Activity>[]) List<Activity> approved,
    @Default(<Activity>[]) List<Activity> rejected,
    // Date filter fields
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    // Status filter
    @Default(ApprovalFilterStatus.all) ApprovalFilterStatus statusFilter,
    // Computed/derived list based on filters
    @Default(<Activity>[]) List<Activity> filteredApprovals,
    final String? errorMessage,
    // Pagination fields
    @Default(1) int currentPage,
    @Default(20) int pageSize,
    @Default(0) int totalItems,
    @Default(false) bool isLoadingMore,
    @Default(true) bool hasMoreData,
  }) = _ApprovalState;
}
