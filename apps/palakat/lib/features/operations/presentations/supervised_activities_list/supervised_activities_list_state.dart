import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/models.dart';

part 'supervised_activities_list_state.freezed.dart';

/// State for the Supervised Activities List screen.
/// Manages activities list, pagination, and filter state.
///
/// Requirements: 2.3, 3.1, 3.2, 3.5
@freezed
abstract class SupervisedActivitiesListState
    with _$SupervisedActivitiesListState {
  const SupervisedActivitiesListState._();

  const factory SupervisedActivitiesListState({
    /// List of supervised activities
    @Default([]) List<Activity> activities,

    /// Whether the initial data is loading
    @Default(true) bool isLoading,

    /// Error message if fetch fails
    String? errorMessage,

    // Pagination fields
    /// Current page number (1-indexed)
    @Default(1) int currentPage,

    /// Total number of pages available
    @Default(1) int totalPages,

    /// Whether there are more pages to load
    @Default(false) bool hasMorePages,

    /// Whether currently loading more items
    @Default(false) bool isLoadingMore,

    // Filter fields
    /// Filter by activity type (service, event, announcement)
    /// Requirements: 3.1
    ActivityType? filterActivityType,

    /// Filter by start date (inclusive)
    /// Requirements: 3.2
    DateTime? filterStartDate,

    /// Filter by end date (inclusive)
    /// Requirements: 3.2
    DateTime? filterEndDate,

    /// Filter by expense status (true = has expense, false = no expense)
    /// Requirements: 1.1, 1.2
    bool? filterHasExpense,

    /// Filter by revenue status (true = has revenue, false = no revenue)
    /// Requirements: 1.3, 1.4
    bool? filterHasRevenue,

    /// The user's membership ID for filtering supervised activities
    int? membershipId,
  }) = _SupervisedActivitiesListState;

  /// Indicates if any filter is currently active.
  /// Returns true when filterActivityType, filterStartDate, filterEndDate,
  /// filterHasExpense, or filterHasRevenue is set.
  ///
  /// Requirements: 3.5, 1.1, 1.2, 1.3, 1.4
  bool get hasActiveFilters =>
      filterActivityType != null ||
      filterStartDate != null ||
      filterEndDate != null ||
      filterHasExpense != null ||
      filterHasRevenue != null;
}
