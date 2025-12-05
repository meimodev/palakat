import 'package:palakat_shared/core/models/request/get_fetch_activity_request.dart';
import 'package:palakat_shared/core/models/request/pagination_request_wrapper.dart';
import 'package:palakat_shared/core/repositories/activity_repository.dart';
import 'package:palakat_shared/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'activity_picker_state.dart';

part 'activity_picker_controller.g.dart';

/// Controller for the Activity Picker dialog.
/// Manages fetching activities with pagination, infinite scrolling, and search.
/// Activities are sorted by date in descending order (newest first).
@riverpod
class ActivityPickerController extends _$ActivityPickerController {
  ActivityRepository get _activityRepository =>
      ref.read(activityRepositoryProvider);
  LocalStorageService get _localStorage =>
      ref.read(localStorageServiceProvider);

  static const int _pageSize = 15;

  @override
  ActivityPickerState build() {
    Future.microtask(() => _initialize());
    return const ActivityPickerState();
  }

  /// Initializes the controller by fetching the membership ID and activities.
  Future<void> _initialize() async {
    final membership = _localStorage.currentMembership;

    if (membership == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Session expired. Please sign in again.',
      );
      return;
    }

    state = state.copyWith(membershipId: membership.id);
    await fetchActivities();
  }

  /// Fetches activities with current search query and pagination.
  /// If [refresh] is true, resets to page 1.
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

  /// Updates the search query and refreshes the list.
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    fetchActivities(refresh: true);
  }

  /// Builds the pagination request with current search query.
  /// Sorted by date in descending order (newest first).
  /// Filters to show only activities without financial records (available for attaching finances).
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
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        // Filter to show only activities without financial records
        // so users can attach new finances to them
        hasExpense: false,
        hasRevenue: false,
      ),
    );
  }
}
