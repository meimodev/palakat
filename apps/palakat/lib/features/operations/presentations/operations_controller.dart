import 'package:palakat/core/constants/app_icons.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/models.dart';
import 'package:palakat_shared/core/models/report_job.dart';
import 'package:palakat_shared/core/repositories/repositories.dart';
import 'package:palakat_shared/services.dart';
import 'package:palakat_shared/l10n/generated/app_localizations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/operation_models.dart';
import 'operations_state.dart';

part 'operations_controller.g.dart';

AppLocalizations _l10n() {
  final localeName = intl.Intl.getCurrentLocale();
  final languageCode = localeName.split(RegExp('[_-]')).first;
  return lookupAppLocalizations(
    Locale(languageCode.isEmpty ? 'en' : languageCode),
  );
}

@riverpod
class OperationsController extends _$OperationsController {
  AuthRepository get _authRepository => ref.read(authRepositoryProvider);
  ActivityRepository get _activityRepository =>
      ref.read(activityRepositoryProvider);
  ReportRepository get _reportRepository => ref.read(reportRepositoryProvider);

  @override
  OperationsState build() {
    Future.microtask(() {
      fetchData();
    });

    ref.listen(realtimeEventProvider, (_, next) {
      final e = next.asData?.value;
      if (e == null) return;

      if (e.name == 'reportJob.created' ||
          e.name == 'reportJob.updated' ||
          e.name == 'report.ready') {
        Future.microtask(() => fetchReportData());
      }
    });

    return const OperationsState();
  }

  void fetchData() async {
    await fetchMembership();
    await fetchSupervisedActivities();
    await fetchReportData();
  }

  /// Fetches both recent reports and pending report jobs.
  Future<void> fetchReportData() async {
    await Future.wait([fetchRecentReports(), fetchPendingReportJobs()]);
  }

  /// Refreshes report data - called when returning from report generation.
  Future<void> refreshReportData() async {
    await fetchReportData();
  }

  Future<void> fetchMembership() async {
    final result = await _authRepository.getSignedInAccount();
    result.when(
      onSuccess: (account) {
        final membership = account!.membership;
        final categories = _buildCategories(membership);
        final expansionState = _initializeCategoryExpansionState(categories);

        state = state.copyWith(
          membership: membership,
          accountName: account.name,
          categories: categories,
          categoryExpansionState: expansionState,
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

  /// Fetches the 5 most recent reports created by the current user.
  Future<void> fetchRecentReports() async {
    state = state.copyWith(
      loadingRecentReports: true,
      recentReportsError: null,
    );

    final result = await _reportRepository.fetchMyReports(page: 1, pageSize: 5);

    result.when(
      onSuccess: (response) {
        state = state.copyWith(
          recentReports: response.data,
          loadingRecentReports: false,
          recentReportsError: null,
        );
      },
      onFailure: (failure) {
        state = state.copyWith(
          loadingRecentReports: false,
          recentReportsError: failure.message,
        );
      },
    );
  }

  /// Fetches pending/processing report jobs for the current user.
  Future<void> fetchPendingReportJobs() async {
    state = state.copyWith(
      loadingPendingReportJobs: true,
      pendingReportJobsError: null,
    );

    // Fetch both pending and processing jobs
    final pendingResult = await _reportRepository.fetchMyReportJobs(
      page: 1,
      pageSize: 10,
      status: ReportJobStatus.pending,
    );

    final processingResult = await _reportRepository.fetchMyReportJobs(
      page: 1,
      pageSize: 10,
      status: ReportJobStatus.processing,
    );

    final List<ReportJob> allPendingJobs = [];
    String? errorMessage;

    pendingResult.when(
      onSuccess: (response) {
        allPendingJobs.addAll(response.data);
      },
      onFailure: (failure) {
        errorMessage = failure.message;
      },
    );

    processingResult.when(
      onSuccess: (response) {
        allPendingJobs.addAll(response.data);
      },
      onFailure: (failure) {
        errorMessage ??= failure.message;
      },
    );

    // Sort by createdAt descending (newest first)
    allPendingJobs.sort((a, b) {
      final aTime = a.createdAt ?? DateTime(1970);
      final bTime = b.createdAt ?? DateTime(1970);
      return bTime.compareTo(aTime);
    });

    state = state.copyWith(
      pendingReportJobs: allPendingJobs,
      loadingPendingReportJobs: false,
      pendingReportJobsError: errorMessage,
    );
  }

  /// Fetches the 3 most recent supervised activities for the current user.
  /// Uses the membershipId to filter activities where the user is the supervisor.
  /// _Requirements: 1.1, 4.1, 4.2_
  Future<void> fetchSupervisedActivities() async {
    final membership = state.membership;
    if (membership?.id == null) {
      state = state.copyWith(loadingSupervisedActivities: false);
      return;
    }

    // Get churchId from localStorage (has full membership data with church)
    final localStorage = ref.read(localStorageServiceProvider);
    final storedMembership = localStorage.currentMembership;
    final churchId = storedMembership?.church?.id ?? membership?.church?.id;

    state = state.copyWith(
      loadingSupervisedActivities: true,
      supervisedActivitiesError: null,
    );

    final request = PaginationRequestWrapper(
      page: 1,
      pageSize: 3,
      sortBy: 'id',
      sortOrder: 'desc',
      data: GetFetchActivitiesRequest(
        membershipId: membership!.id,
        churchId: churchId,
      ),
    );

    final result = await _activityRepository.fetchActivities(
      paginationRequest: request,
    );

    result.when(
      onSuccess: (response) {
        state = state.copyWith(
          supervisedActivities: response.data,
          loadingSupervisedActivities: false,
          supervisedActivitiesError: null,
        );
      },
      onFailure: (failure) {
        state = state.copyWith(
          loadingSupervisedActivities: false,
          supervisedActivitiesError: failure.message,
        );
      },
    );
  }

  /// Builds the list of operation categories based on user's membership positions.
  /// Categories: Publishing, Financial, Reports
  /// _Requirements: 4.1, 4.2, 4.3_
  List<OperationCategory> _buildCategories(Membership? membership) {
    final l10n = _l10n();
    final positions = membership?.membershipPositions ?? [];
    final hasPositions = positions.isNotEmpty;

    // Publishing category - available to all users with positions
    final publishingOperations = <OperationItem>[
      OperationItem(
        id: 'publish_service',
        title: l10n.operationsItem_publish_service_title,
        description: l10n.operationsItem_publish_service_desc,
        icon: AppIcons.handshake,
        routeName: AppRoute.activityPublish,
        routeParams: {RouteParamKey.activityType: ActivityType.service},
        isEnabled: hasPositions,
      ),
      OperationItem(
        id: 'publish_event',
        title: l10n.operationsItem_publish_event_title,
        description: l10n.operationsItem_publish_event_desc,
        icon: AppIcons.event,
        routeName: AppRoute.activityPublish,
        routeParams: {RouteParamKey.activityType: ActivityType.event},
        isEnabled: hasPositions,
      ),
      OperationItem(
        id: 'publish_announcement',
        title: l10n.operationsItem_publish_announcement_title,
        description: l10n.operationsItem_publish_announcement_desc,
        icon: AppIcons.announcement,
        routeName: AppRoute.activityPublish,
        routeParams: {RouteParamKey.activityType: ActivityType.announcement},
        isEnabled: hasPositions,
      ),
    ];

    // Financial category - available to users with positions
    // Requirements: 4.1 - Standalone finance creation
    final financialOperations = <OperationItem>[
      OperationItem(
        id: 'add_income',
        title: l10n.operationsItem_add_income_title,
        description: l10n.operationsItem_add_income_desc,
        icon: AppIcons.revenue,
        routeName: AppRoute.financeCreate,
        routeParams: {
          RouteParamKey.financeType: FinanceType.revenue,
          RouteParamKey.isStandalone: true,
        },
        isEnabled: hasPositions,
      ),
      OperationItem(
        id: 'add_expense',
        title: l10n.operationsItem_add_expense_title,
        description: l10n.operationsItem_add_expense_desc,
        icon: AppIcons.expense,
        routeName: AppRoute.financeCreate,
        routeParams: {
          RouteParamKey.financeType: FinanceType.expense,
          RouteParamKey.isStandalone: true,
        },
        isEnabled: hasPositions,
      ),
    ];

    // Reports category - available to users with positions
    final reportsOperations = <OperationItem>[
      OperationItem(
        id: 'report_incoming_document',
        title: l10n.reportType_incomingDocument,
        description: l10n.reportDesc_incomingDocument,
        icon: AppIcons.document,
        routeName: AppRoute.reportGenerate,
        routeParams: {
          RouteParamKey.reportType: ReportGenerateType.incomingDocument,
        },
        isEnabled: hasPositions,
      ),
      OperationItem(
        id: 'report_congregation',
        title: l10n.reportType_congregation,
        description: l10n.reportDesc_congregation,
        icon: AppIcons.church,
        routeName: AppRoute.reportGenerate,
        routeParams: {
          RouteParamKey.reportType: ReportGenerateType.congregation,
        },
        isEnabled: hasPositions,
      ),
      OperationItem(
        id: 'report_activity',
        title: l10n.reportType_activity,
        description: l10n.reportDesc_activity,
        icon: AppIcons.event,
        routeName: AppRoute.reportGenerate,
        routeParams: {RouteParamKey.reportType: ReportGenerateType.activity},
        isEnabled: hasPositions,
      ),
      OperationItem(
        id: 'report_financial',
        title: l10n.reportType_financial,
        description: l10n.reportDesc_financial,
        icon: AppIcons.wallet,
        routeName: AppRoute.reportGenerate,
        routeParams: {RouteParamKey.reportType: ReportGenerateType.financial},
        isEnabled: hasPositions,
      ),
    ];

    // Membership category - for managing church members
    final membershipOperations = <OperationItem>[
      OperationItem(
        id: 'view_members',
        title: l10n.operationsItem_view_members_title,
        description: l10n.operationsItem_view_members_desc,
        icon: AppIcons.group,
        routeName: AppRoute.membersList,
        isEnabled: hasPositions,
      ),
      OperationItem(
        id: 'member_birthdays',
        title: l10n.tbl_birth,
        description: 'View member birthdays',
        icon: AppIcons.birthday,
        routeName: AppRoute.memberBirthdays,
        isEnabled: hasPositions,
      ),
      OperationItem(
        id: 'invite_member',
        title: l10n.operationsItem_invite_member_title,
        description: l10n.operationsItem_invite_member_desc,
        icon: AppIcons.addCircle,
        routeName: AppRoute.memberInvite,
        isEnabled: hasPositions,
      ),
    ];

    return [
      OperationCategory(
        id: 'publishing',
        title: l10n.operationsCategory_publishing,
        icon: AppIcons.publish,
        operations: publishingOperations,
      ),
      OperationCategory(
        id: 'financial',
        title: l10n.operationsCategory_financial,
        icon: AppIcons.wallet,
        operations: financialOperations,
      ),
      OperationCategory(
        id: 'reports',
        title: l10n.operationsCategory_reports,
        icon: AppIcons.barChart,
        operations: reportsOperations,
      ),
      OperationCategory(
        id: 'membership',
        title: l10n.operationsCategory_membership,
        icon: AppIcons.group,
        operations: membershipOperations,
      ),
    ];
  }

  /// Initializes the category expansion state map.
  /// All categories start collapsed by default.
  Map<String, bool> _initializeCategoryExpansionState(
    List<OperationCategory> categories,
  ) {
    return {for (final category in categories) category.id: false};
  }

  /// Toggles the expansion state of a category.
  /// Implements accordion behavior - only one category can be expanded at a time.
  /// _Requirements: 4.4, 4.5_
  void toggleCategoryExpansion(String categoryId) {
    final currentState = state.categoryExpansionState[categoryId] ?? false;
    final willExpand = !currentState;

    // Accordion behavior: collapse all categories, then expand only the selected one
    final newExpansionState = <String, bool>{};
    for (final key in state.categoryExpansionState.keys) {
      newExpansionState[key] = (key == categoryId) ? willExpand : false;
    }

    // Update the category's isExpanded property as well
    final updatedCategories = state.categories.map((category) {
      if (category.id == categoryId) {
        return category.copyWith(isExpanded: willExpand);
      }
      // Collapse all other categories
      return category.copyWith(isExpanded: false);
    }).toList();

    state = state.copyWith(
      categoryExpansionState: newExpansionState,
      categories: updatedCategories,
    );
  }

  /// Returns whether a category is currently expanded.
  bool isCategoryExpanded(String categoryId) {
    return state.categoryExpansionState[categoryId] ?? false;
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Toggles the expansion state of the supervised activities section.
  void toggleSupervisedActivitiesExpansion() {
    state = state.copyWith(
      supervisedActivitiesExpanded: !state.supervisedActivitiesExpanded,
    );
  }
}
