import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/models.dart';
import 'package:palakat_shared/core/models/request/request.dart';
import 'package:palakat_shared/core/repositories/repositories.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'supervised_activities_list_state.dart';

part 'supervised_activities_list_controller.g.dart';

/// Controller for the Supervised Activities List screen.
/// Manages fetching activities with pagination and filtering.
///
/// Requirements: 2.3, 3.1, 3.2, 3.3, 3.4
@riverpod
class SupervisedActivitiesListController
    extends _$SupervisedActivitiesListController {
  ActivityRepository get _activityRepository =>
      ref.read(activityRepositoryProvider);
  AuthRepository get _authRepository => ref.read(authRepositoryProvider);

  static const int _pageSize = 10;

  @override
  SupervisedActivitiesListState build() {
    Future.microtask(() => _initialize());
    return const SupervisedActivitiesListState();
  }

  /// Initializes the controller by fetching the membership ID and activities.
  Future<void> _initialize() async {
    final accountResult = await _authRepository.getSignedInAccount();
    accountResult.when(
      onSuccess: (account) {
        final membershipId = account?.membership?.id;
        state = state.copyWith(membershipId: membershipId);
        fetchActivities();
      },
      onFailure: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
    );
  }

  /// Fetches activities with current filters and pagination.
  /// If [refresh] is true, resets to page 1.
  ///
  /// Requirements: 2.3, 3.3
  Future<void> fetchActivities({bool refresh = false}) async {
    if (state.membershipId == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load activities: membership not found',
      );
      return;
    }

    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        currentPage: 1,
        activities: [],
        errorMessage: null,
      );
    } else {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    final request = _buildRequest(page: 1);
    final result = await _activityRepository.fetchActivities(
      paginationRequest: request,
    );

    result.when(
      onSuccess: (response) {
        state = state.copyWith(
          activities: response.data,
          isLoading: false,
          currentPage: response.pagination.page,
          totalPages: response.pagination.totalPages,
          hasMorePages: response.pagination.hasNext,
          errorMessage: null,
        );
      },
      onFailure: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
    );
  }

  /// Loads more activities for infinite scroll.
  /// Appends new activities to the existing list.
  ///
  /// Requirements: 2.3
  Future<void> loadMoreActivities() async {
    if (state.isLoadingMore || !state.hasMorePages) return;

    state = state.copyWith(isLoadingMore: true);

    final nextPage = state.currentPage + 1;
    final request = _buildRequest(page: nextPage);

    final result = await _activityRepository.fetchActivities(
      paginationRequest: request,
    );

    result.when(
      onSuccess: (response) {
        state = state.copyWith(
          activities: [...state.activities, ...response.data],
          isLoadingMore: false,
          currentPage: response.pagination.page,
          totalPages: response.pagination.totalPages,
          hasMorePages: response.pagination.hasNext,
        );
      },
      onFailure: (failure) {
        state = state.copyWith(
          isLoadingMore: false,
          // Don't overwrite existing data on load more failure
        );
      },
    );
  }

  /// Sets the activity type filter and refreshes the list.
  ///
  /// Requirements: 3.1, 3.3
  void setActivityTypeFilter(ActivityType? type) {
    state = state.copyWith(filterActivityType: type);
    fetchActivities(refresh: true);
  }

  /// Sets the date range filter and refreshes the list.
  ///
  /// Requirements: 3.2, 3.3
  void setDateRangeFilter(DateTime? start, DateTime? end) {
    state = state.copyWith(filterStartDate: start, filterEndDate: end);
    fetchActivities(refresh: true);
  }

  /// Sets the financial filter and refreshes the list.
  /// [hasExpense] filters by expense status (true = has expense, false = no expense, null = no filter)
  /// [hasRevenue] filters by revenue status (true = has revenue, false = no revenue, null = no filter)
  ///
  /// Requirements: 1.1, 1.2, 1.3, 1.4, 1.8
  void setFinancialFilter({bool? hasExpense, bool? hasRevenue}) {
    state = state.copyWith(
      filterHasExpense: hasExpense,
      filterHasRevenue: hasRevenue,
    );
    fetchActivities(refresh: true);
  }

  /// Clears all filters and refreshes the list.
  ///
  /// Requirements: 3.4, 1.5
  void clearFilters() {
    state = state.copyWith(
      filterActivityType: null,
      filterStartDate: null,
      filterEndDate: null,
      filterHasExpense: null,
      filterHasRevenue: null,
    );
    fetchActivities(refresh: true);
  }

  /// Builds the pagination request with current filters.
  ///
  /// Requirements: 1.1, 1.2, 1.3, 1.4, 1.8
  PaginationRequestWrapper<GetFetchActivitiesRequest> _buildRequest({
    required int page,
  }) {
    return PaginationRequestWrapper(
      page: page,
      pageSize: _pageSize,
      sortBy: 'date',
      sortOrder: 'desc',
      data: GetFetchActivitiesRequest(
        membershipId: state.membershipId,
        activityType: state.filterActivityType,
        startDate: state.filterStartDate,
        endDate: state.filterEndDate,
        hasExpense: state.filterHasExpense,
        hasRevenue: state.filterHasRevenue,
      ),
    );
  }
}
