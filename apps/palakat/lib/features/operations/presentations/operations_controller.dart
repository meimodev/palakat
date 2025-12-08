import 'package:palakat/core/constants/app_icons.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/models.dart';
import 'package:palakat_shared/core/repositories/repositories.dart';
import 'package:palakat_shared/core/services/local_storage_service_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/operation_models.dart';
import 'operations_state.dart';

part 'operations_controller.g.dart';

@riverpod
class OperationsController extends _$OperationsController {
  AuthRepository get _authRepository => ref.read(authRepositoryProvider);
  ActivityRepository get _activityRepository =>
      ref.read(activityRepositoryProvider);

  @override
  OperationsState build() {
    Future.microtask(() {
      fetchData();
    });
    return const OperationsState();
  }

  void fetchData() async {
    await fetchMembership();
    await fetchSupervisedActivities();
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
    final positions = membership?.membershipPositions ?? [];
    final hasPositions = positions.isNotEmpty;

    // Publishing category - available to all users with positions
    final publishingOperations = <OperationItem>[
      OperationItem(
        id: 'publish_service',
        title: 'Publish Service',
        description: 'Create and publish church service activities',
        icon: AppIcons.handshake,
        routeName: AppRoute.activityPublish,
        routeParams: {RouteParamKey.activityType: ActivityType.service},
        isEnabled: hasPositions,
      ),
      OperationItem(
        id: 'publish_event',
        title: 'Publish Event',
        description: 'Create and publish church events',
        icon: AppIcons.event,
        routeName: AppRoute.activityPublish,
        routeParams: {RouteParamKey.activityType: ActivityType.event},
        isEnabled: hasPositions,
      ),
      OperationItem(
        id: 'publish_announcement',
        title: 'Publish Announcement',
        description: 'Create and publish announcements',
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
        title: 'Add Revenue',
        description: 'Record church income and offerings',
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
        title: 'Add Expense',
        description: 'Record church expenses',
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
        id: 'generate_report',
        title: 'Generate Report',
        description: 'Create activity and financial reports',
        icon: AppIcons.assessment,
        routeName:
            AppRoute.operations, // Placeholder - update when route exists
        isEnabled: hasPositions,
      ),
    ];

    return [
      OperationCategory(
        id: 'publishing',
        title: 'Publishing',
        icon: AppIcons.publish,
        operations: publishingOperations,
      ),
      OperationCategory(
        id: 'financial',
        title: 'Financial',
        icon: AppIcons.wallet,
        operations: financialOperations,
      ),
      OperationCategory(
        id: 'reports',
        title: 'Reports',
        icon: AppIcons.barChart,
        operations: reportsOperations,
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
}
