import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_shared/core/models/activity.dart';

part 'activity_picker_state.freezed.dart';

/// State for the Activity Picker dialog.
/// Manages activities list, pagination, and search state.
@freezed
abstract class ActivityPickerState with _$ActivityPickerState {
  const factory ActivityPickerState({
    /// List of activities
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

    // Search field
    /// Current search query
    @Default('') String searchQuery,

    /// The user's membership ID for filtering supervised activities
    int? membershipId,
  }) = _ActivityPickerState;
}
