import 'package:flutter/material.dart';
import 'package:palakat_admin/constants.dart';
import 'package:palakat_admin/features/activity/presentation/state/activity_screen_state.dart';
import 'package:palakat_admin/features/auth/application/auth_controller.dart';
import 'package:palakat_admin/models.dart';
import 'package:palakat_admin/repositories.dart';
import 'package:palakat_admin/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'activity_controller.g.dart';

@riverpod
class ActivityController extends _$ActivityController {
  late final Debouncer _searchDebouncer;
  bool _isDisposed = false;
  int _fetchRequestId = 0;

  @override
  ActivityScreenState build() {
    _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));
    ref.onDispose(() {
      _isDisposed = true;
      _searchDebouncer.dispose();
    });

    final initial = const ActivityScreenState();
    Future.microtask(() {
      _fetchActivities();
    });
    return initial;
  }

  Church get church =>
      ref.read(authControllerProvider).value!.account.membership!.church!;

  Future<void> _fetchActivities() async {
    if (_isDisposed) return;
    final requestId = ++_fetchRequestId;

    final snapshot = state;
    state = snapshot.copyWith(activities: const AsyncLoading());
    try {
      final repository = ref.read(activityRepositoryProvider);

      // Calculate actual date range from preset
      DateTimeRange? actualDateRange;
      if (snapshot.dateRangePreset == DateRangePreset.custom) {
        actualDateRange = snapshot.customDateRange;
      } else if (snapshot.dateRangePreset != DateRangePreset.allTime) {
        actualDateRange = snapshot.dateRangePreset.getDateRange();
      }

      final churchId = church.id!;
      final searchQuery = snapshot.searchQuery;
      final activityTypeFilter = snapshot.activityTypeFilter;
      final currentPage = snapshot.currentPage;
      final pageSize = snapshot.pageSize;

      final result = await repository.fetchActivities(
        paginationRequest: PaginationRequestWrapper(
          data: GetFetchActivitiesRequest(
            churchId: churchId,
            search: searchQuery.isEmpty ? null : searchQuery,
            startDate: actualDateRange?.start,
            endDate: actualDateRange?.end,
            activityType: activityTypeFilter,
          ),
          page: currentPage,
          pageSize: pageSize,
          sortBy: 'id',
          sortOrder: 'desc',
        ),
      );

      if (_isDisposed || requestId != _fetchRequestId) return;

      result.when(
        onSuccess: (activities) {
          if (_isDisposed || requestId != _fetchRequestId) return;
          state = state.copyWith(activities: AsyncData(activities));
        },
        onFailure: (failure) {
          if (_isDisposed || requestId != _fetchRequestId) return;
          state = state.copyWith(
            activities: AsyncError(
              Exception(failure.message),
              StackTrace.current,
            ),
          );
        },
      );
    } catch (e, st) {
      if (_isDisposed || requestId != _fetchRequestId) return;
      state = state.copyWith(activities: AsyncError(e, st));
    }
  }

  void onChangedSearch(String value) {
    state = state.copyWith(
      searchQuery: value,
      currentPage: 1, // Reset to first page on search
    );
    _searchDebouncer(() => _fetchActivities());
  }

  void onChangedDateRangePreset(DateRangePreset preset) {
    state = state.copyWith(
      dateRangePreset: preset,
      currentPage: 1, // Reset to first page on filter change
    );
    _fetchActivities();
  }

  void onCustomDateRangeSelected(DateTimeRange? dateRange) {
    state = state.copyWith(
      customDateRange: dateRange,
      currentPage: 1, // Reset to first page on filter change
    );
    _fetchActivities();
  }

  void onChangedActivityType(ActivityType? activityType) {
    state = state.copyWith(
      activityTypeFilter: activityType,
      currentPage: 1, // Reset to first page on filter change
    );
    _fetchActivities();
  }

  void onChangedPageSize(int pageSize) {
    state = state.copyWith(
      pageSize: pageSize,
      currentPage: 1, // Reset to first page on page size change
    );
    _fetchActivities();
  }

  void onChangedPage(int page) {
    state = state.copyWith(currentPage: page);
    _fetchActivities();
  }

  void onPressedNextPage() {
    state = state.copyWith(currentPage: state.currentPage + 1);
    _fetchActivities();
  }

  void onPressedPrevPage() {
    if (state.currentPage > 1) {
      state = state.copyWith(currentPage: state.currentPage - 1);
      _fetchActivities();
    }
  }

  Future<void> refresh() async {
    await _fetchActivities();
  }

  // Fetch single activity detail (doesn't mutate state)
  Future<Activity?> fetchActivity(int activityId) async {
    final repository = ref.read(activityRepositoryProvider);
    final result = await repository.fetchActivity(activityId: activityId);
    return result.when(
      onSuccess: (activity) => activity,
      onFailure: (failure) => throw Exception(failure.message),
    );
  }

  // Save activity (create or update)
  Future<void> saveActivity(Activity activity) async {
    final repository = ref.read(activityRepositoryProvider);

    if (activity.id != null) {
      // Update existing activity
      final payload = activity.toJson();
      final result = await repository.updateActivity(
        activityId: activity.id!,
        update: payload,
      );
      result.when(
        onSuccess: (_) {},
        onFailure: (failure) => throw Exception(failure.message),
      );
    } else {
      // Create new activity using CreateActivityRequest
      final request = CreateActivityRequest(
        supervisorId: activity.supervisorId ?? activity.supervisor.id!,
        bipra: activity.bipra ?? Bipra.fathers,
        title: activity.title,
        description: activity.description,
        locationName: activity.location?.name,
        locationLatitude: activity.location?.latitude,
        locationLongitude: activity.location?.longitude,
        date: activity.date,
        note: activity.note,
        activityType: activity.activityType,
        reminder: activity.reminder,
      );
      final result = await repository.createActivity(request: request);
      result.when(
        onSuccess: (_) {},
        onFailure: (failure) => throw Exception(failure.message),
      );
    }

    await _fetchActivities();
  }

  // Delete activity
  Future<void> deleteActivity(int activityId) async {
    final repository = ref.read(activityRepositoryProvider);
    final result = await repository.deleteActivity(activityId: activityId);

    result.when(
      onSuccess: (_) {},
      onFailure: (failure) => throw Exception(failure.message),
    );

    // Refresh the list after delete
    await _fetchActivities();
  }
}
