import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat/features/song_book/data/song_category_model.dart';
import 'package:palakat_shared/core/models/models.dart';

part 'song_book_state.freezed.dart';

/// State for the Song Book screen with category-based organization.
/// Supports collapsible category sections and search functionality.
/// Requirements: 1.1, 7.1, 7.4
@freezed
abstract class SongBookState with _$SongBookState {
  const factory SongBookState({
    /// All songs fetched from the backend
    @Default([]) List<Song> songs,

    /// Songs filtered by search query (used in search results view)
    @Default([]) List<Song> filteredSongs,

    /// Loading state for API calls
    @Default(false) bool isLoading,

    /// Whether the user is currently searching
    @Default(false) bool isSearching,

    /// Current search query text
    @Default('') String searchQuery,

    /// Error message from failed API calls
    @Default(null) String? errorMessage,

    /// List of song categories (NNBT, KJ, NKB, DSL)
    /// Requirements: 1.1, 1.2
    @Default([]) List<SongCategory> categories,

    /// Map tracking expansion state for each category by ID
    /// Key: category ID, Value: whether the category is expanded
    /// Requirements: 7.1, 7.3, 7.4
    @Default({}) Map<String, bool> categoryExpansionState,
  }) = _SongBookState;
}
