import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_shared/core/models/models.dart';
import 'package:palakat_shared/core/models/report_job.dart';

import '../data/operation_models.dart';

part 'operations_state.freezed.dart';

@freezed
abstract class OperationsState with _$OperationsState {
  const factory OperationsState({
    /// User's membership data containing positions
    Membership? membership,

    /// User's account name for display
    String? accountName,

    /// Whether the screen is currently loading
    @Default(true) bool loadingScreen,

    /// Error message if data fetch fails
    final String? errorMessage,

    /// List of operation categories (Publishing, Financial, Reports)
    @Default([]) List<OperationCategory> categories,

    /// Map tracking expansion state for each category by ID
    /// Key: category ID, Value: whether expanded
    @Default({}) Map<String, bool> categoryExpansionState,

    /// List of recent supervised activities (max 3)
    /// _Requirements: 1.1, 4.1, 4.2_
    @Default([]) List<Activity> supervisedActivities,

    /// Loading state for supervised activities section
    /// _Requirements: 4.1_
    @Default(false) bool loadingSupervisedActivities,

    /// Error message for supervised activities fetch
    /// _Requirements: 4.2_
    String? supervisedActivitiesError,

    /// Whether the supervised activities section is expanded
    @Default(false) bool supervisedActivitiesExpanded,

    /// List of recent reports created by the current user (max 5)
    @Default([]) List<Report> recentReports,

    /// Loading state for recent reports section
    @Default(false) bool loadingRecentReports,

    /// Error message for recent reports fetch
    String? recentReportsError,

    /// List of pending/processing report jobs for the current user
    @Default([]) List<ReportJob> pendingReportJobs,

    /// Loading state for pending report jobs section
    @Default(false) bool loadingPendingReportJobs,

    /// Error message for pending report jobs fetch
    String? pendingReportJobsError,
  }) = _OperationsState;
}
