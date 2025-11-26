import 'package:palakat/features/song_book/data/song_category_model.dart';
import 'package:palakat/features/song_book/presentations/song_book_state.dart';
import 'package:palakat_shared/core/models/models.dart';
import 'package:palakat_shared/core/repositories/song_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'song_book_controller.g.dart';

@riverpod
class SongBookController extends _$SongBookController {
  /// Repository for song API calls (Requirements 5.1, 5.2)
  SongRepository get _songRepo => ref.read(songRepositoryProvider);

  @override
  SongBookState build() {
    // Schedule fetchSongs to run after build completes
    // This avoids the "uninitialized provider" error
    Future.microtask(() => fetchSongs());

    return SongBookState(
      songs: [],
      filteredSongs: [],
      isLoading: true,
      isSearching: false,
      searchQuery: '',
      errorMessage: null,
      categories: _initializeCategories(),
      categoryExpansionState: _initializeCategoryExpansionState(),
    );
  }

  /// Initialize song categories from predefined list
  /// Requirements: 1.1, 1.2
  List<SongCategory> _initializeCategories() {
    return SongCategories.all;
  }

  /// Initialize all categories to collapsed state
  /// Requirements: 7.4 - All categories start collapsed on new session
  Map<String, bool> _initializeCategoryExpansionState() {
    return {for (final category in SongCategories.all) category.id: false};
  }

  /// Fetch songs from the backend API (Requirements 1.2, 4.1, 4.2)
  Future<void> fetchSongs() async {
    // Check if provider is still mounted before accessing state
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _songRepo.getSongs(
      paginationRequest: PaginationRequestWrapper(
        page: 1,
        pageSize: 50,
        data: GetFetchSongsRequest(),
      ),
    );

    // Check again after async operation
    if (!ref.mounted) return;

    result.when(
      onSuccess: (response) {
        if (!ref.mounted) return null;
        state = state.copyWith(
          songs: response.data,
          filteredSongs: response.data,
          isLoading: false,
        );
        return null;
      },
      onFailure: (failure) {
        if (!ref.mounted) return;
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
    );
  }

  /// Search songs by title or content via API
  /// Requirements: 3.1, 3.2, 3.4
  ///
  /// This method handles the search state transition:
  /// - When query is empty: returns to category view (isSearching = false)
  /// - When query is non-empty: displays search results (isSearching = true)
  ///
  /// The 500ms debounce is handled by the UI layer to avoid excessive API calls.
  Future<void> searchSongs(String query) async {
    // Check if provider is still mounted before accessing state
    if (!ref.mounted) return;

    final trimmedQuery = query.trim();

    // Clear search state for empty queries (Requirement 3.4)
    // Returns to category view when search field is cleared
    if (trimmedQuery.isEmpty) {
      state = state.copyWith(
        filteredSongs: state.songs,
        searchQuery: '',
        isSearching: false,
      );
      return;
    }

    // Set searching state before API call (Requirement 3.4)
    // Transitions from category view to search results view
    state = state.copyWith(
      isLoading: true,
      searchQuery: trimmedQuery,
      isSearching: true,
    );

    final result = await _songRepo.searchSongs(query: trimmedQuery);

    // Check again after async operation
    if (!ref.mounted) return;

    result.when(
      onSuccess: (response) {
        if (!ref.mounted) return null;
        // Filter results to contain only songs matching the query
        // Requirements: 3.2 - filter songs across all categories
        state = state.copyWith(filteredSongs: response.data, isLoading: false);
        return null;
      },
      onFailure: (failure) {
        if (!ref.mounted) return;
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
    );
  }

  /// Clear search and reset to category view
  /// Requirements: 3.4 - When search field is cleared, return to category view
  void clearSearch() {
    state = state.copyWith(
      filteredSongs: state.songs,
      searchQuery: '',
      isSearching: false,
    );
  }

  /// Check if currently in search mode
  /// Requirements: 3.4 - Used for conditional rendering (search vs category view)
  bool get isInSearchMode => state.isSearching && state.searchQuery.isNotEmpty;

  /// Refresh songs data for retry functionality (Requirement 4.4)
  Future<void> refreshSongs() async {
    // Check if provider is still mounted before accessing state
    if (!ref.mounted) return;

    // Clear error state and set loading
    state = state.copyWith(errorMessage: null, isLoading: true);

    // Re-call fetchSongs or searchSongs based on current search query
    if (state.searchQuery.isNotEmpty) {
      await searchSongs(state.searchQuery);
    } else {
      await fetchSongs();
    }
  }

  /// Filter songs by category/type (e.g., "KJ", "NNBT", "NKB", "DSL")
  void filterByCategory(String category) {
    final filteredSongs = state.songs.where((song) {
      return song.title.toUpperCase().contains(category.toUpperCase()) ||
          song.subTitle.toUpperCase().contains(category.toUpperCase());
    }).toList();

    state = state.copyWith(
      filteredSongs: filteredSongs,
      searchQuery: category,
      isSearching: true,
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Toggle the expansion state of a category
  /// Requirements: 1.3, 7.1, 7.3
  ///
  /// When a category is toggled:
  /// - Its expansion state is inverted
  /// - Other categories remain unchanged (7.3 - multiple can be expanded)
  /// - State persists during the session (7.1)
  void toggleCategoryExpansion(String categoryId) {
    final currentState = state.categoryExpansionState[categoryId] ?? false;
    final newExpansionState = Map<String, bool>.from(
      state.categoryExpansionState,
    )..[categoryId] = !currentState;

    state = state.copyWith(categoryExpansionState: newExpansionState);
  }

  /// Get songs filtered by category (hymnal type)
  /// Requirements: 1.2, 1.3
  ///
  /// Filters songs based on the category abbreviation in the song title.
  /// Song titles follow the format "{ABBREVIATION} NO.{index}" (e.g., "KJ NO.1")
  List<Song> getSongsForCategory(String categoryId) {
    final category = SongCategories.getById(categoryId);
    if (category == null) return [];

    final abbreviation = category.abbreviation.toUpperCase();

    return state.songs.where((song) {
      // Song title format: "{ABBREVIATION} NO.{index}"
      return song.title.toUpperCase().startsWith(abbreviation);
    }).toList();
  }

  /// Check if a category is currently expanded
  /// Requirements: 7.1, 7.2
  bool isCategoryExpanded(String categoryId) {
    return state.categoryExpansionState[categoryId] ?? false;
  }

  /// Get the count of songs in a category
  /// Useful for displaying song count badges on category headers
  int getSongCountForCategory(String categoryId) {
    return getSongsForCategory(categoryId).length;
  }

  /// Collapse all categories
  /// Requirements: 7.4 - Reset to collapsed state
  void collapseAllCategories() {
    state = state.copyWith(
      categoryExpansionState: _initializeCategoryExpansionState(),
    );
  }
}

// Provider for easy access to the filtered songs list
@riverpod
List<Song> songProvider(Ref ref) {
  final songBookState = ref.watch(songBookControllerProvider);
  return songBookState.filteredSongs;
}
