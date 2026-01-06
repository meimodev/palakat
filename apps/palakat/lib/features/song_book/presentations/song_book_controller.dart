import 'dart:async';

import 'package:palakat/features/song_book/data/song_category_model.dart';
import 'package:palakat/features/song_book/data/song_search_repository.dart';
import 'package:palakat/features/song_book/presentations/song_book_state.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/models/models.dart';
import 'package:palakat_shared/core/repositories/song_repository.dart';
import 'package:palakat_shared/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'song_book_controller.g.dart';

@riverpod
class SongBookController extends _$SongBookController {
  /// Repository for song API calls (Requirements 5.1, 5.2)
  SongRepository get _songRepo => ref.read(songRepositoryProvider);

  SongSearchRepository get _songSearchRepo =>
      ref.read(songSearchRepositoryProvider);

  String _searchFingerprintFromSongs(List<Song> songs) {
    return 'v1|len:${songs.length}|first:${songs.isNotEmpty ? songs.first.id : ''}|last:${songs.isNotEmpty ? songs.last.id : ''}';
  }

  @override
  SongBookState build() {
    Future.microtask(() => _init());

    ref.listen(realtimeEventProvider, (_, next) {
      final e = next.asData?.value;
      if (e == null) return;
      if (e.name != 'songDb.updated') return;
      unawaited(checkForDbUpdate(forceRefresh: true));
    });

    final initialCategories = _initializeCategories();

    return SongBookState(
      songs: [],
      filteredSongs: [],
      isLoading: true,
      needsDownload: false,
      isDownloadingDb: false,
      isSearching: false,
      searchQuery: '',
      errorMessage: null,
      categories: initialCategories,
      categoryExpansionState: _initializeCategoryExpansionState(
        initialCategories,
      ),
    );
  }

  Future<void> _init() async {
    if (!ref.mounted) return;

    final hasCache = await _songRepo.hasCachedSongDb();
    if (!ref.mounted) return;

    if (!hasCache) {
      state = state.copyWith(
        isLoading: false,
        needsDownload: true,
        isDownloadingDb: false,
        isCheckingDbUpdate: false,
        hasDbUpdate: false,
        remoteUpdatedAt: null,
        errorMessage: null,
        songs: [],
        filteredSongs: [],
        isSearching: false,
        searchQuery: '',
      );
      return;
    }

    await fetchSongs(forceRefresh: false);

    // Fire-and-forget update check. Never block the UI.
    unawaited(checkForDbUpdate());
  }

  Future<void> checkForDbUpdate({bool forceRefresh = false}) async {
    if (!ref.mounted) return;
    if (state.needsDownload) return;
    if (state.isCheckingDbUpdate) return;

    state = state.copyWith(isCheckingDbUpdate: true);

    try {
      final local = await _songRepo.getSongDbMetadata(
        forceRefresh: forceRefresh,
      );
      final localCachedAt = await _songRepo.getSongDbCachedAt();
      final remote = await _songRepo.getRemoteSongDbMetadata(
        forceRefresh: forceRefresh,
      );

      if (!ref.mounted) return;

      final localUpdatedAt = localCachedAt ?? local.updatedAt;
      final remoteUpdatedAt = remote.updatedAt;

      final hasUpdate =
          remoteUpdatedAt != null &&
          (localUpdatedAt == null || remoteUpdatedAt.isAfter(localUpdatedAt));

      state = state.copyWith(
        isCheckingDbUpdate: false,
        hasDbUpdate: hasUpdate,
        remoteUpdatedAt: remoteUpdatedAt,
      );
    } catch (_) {
      if (!ref.mounted) return;
      state = state.copyWith(isCheckingDbUpdate: false);
    }
  }

  /// Initialize song categories from predefined list
  /// Requirements: 1.1, 1.2
  List<SongCategory> _initializeCategories() {
    return SongCategories.all;
  }

  /// Initialize all categories to collapsed state
  /// Requirements: 7.4 - All categories start collapsed on new session
  Map<String, bool> _initializeCategoryExpansionState(
    List<SongCategory> categories,
  ) {
    return {for (final category in categories) category.id: false};
  }

  List<SongCategory> _categoriesFromBooks(List<SongBook> books) {
    return books
        .where((b) => b.id.trim().isNotEmpty)
        .map(
          (b) => SongCategory(
            id: b.id.trim(),
            title: b.name,
            abbreviation: b.id.trim().toUpperCase(),
            icon: AppIcons.libraryMusic,
          ),
        )
        .toList();
  }

  /// Fetch songs from the backend API (Requirements 1.2, 4.1, 4.2)
  Future<void> fetchSongs({bool forceRefresh = false}) async {
    // Check if provider is still mounted before accessing state
    if (!ref.mounted) return;
    if (state.needsDownload) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _songRepo.getSongs(
      paginationRequest: PaginationRequestWrapper(
        page: 1,
        pageSize: 10000,
        data: GetFetchSongsRequest(),
      ),
      forceRefresh: forceRefresh,
    );

    // Check again after async operation
    if (!ref.mounted) return;

    Failure? failure;
    final response = result.when(
      onSuccess: (response) => response,
      onFailure: (f) {
        failure = f;
      },
    );

    if (!ref.mounted) return;

    if (response == null) {
      final msg = failure?.message;
      if (msg == 'Song DB not downloaded') {
        state = state.copyWith(
          isLoading: false,
          needsDownload: true,
          errorMessage: null,
          songs: [],
          filteredSongs: [],
        );
        return;
      }
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return;
    }

    List<SongCategory> categories = state.categories;
    try {
      final books = await _songRepo.getSongBooks(forceRefresh: forceRefresh);
      if (books.isNotEmpty) {
        categories = _categoriesFromBooks(books);
      } else {
        categories = _initializeCategories();
      }
    } catch (_) {
      categories = _initializeCategories();
    }

    final expansionState = {
      for (final category in categories)
        category.id: state.categoryExpansionState[category.id] ?? false,
    };

    state = state.copyWith(
      songs: response.data,
      filteredSongs: response.data,
      categories: categories,
      categoryExpansionState: expansionState,
      isLoading: false,
    );

    final songs = response.data;
    if (songs.isNotEmpty) {
      final fingerprint = _searchFingerprintFromSongs(songs);
      // Fire-and-forget. Search will still work (fallback) if indexing fails.
      unawaited(
        _songSearchRepo.ensureIndexed(songs: songs, fingerprint: fingerprint),
      );
    }
  }

  Future<void> downloadDbAndLoadSongs() async {
    if (!ref.mounted) return;

    state = state.copyWith(isDownloadingDb: true, errorMessage: null);

    final result = await _songRepo.downloadSongDb();
    if (!ref.mounted) return;

    Failure? failure;
    final ok = result.when(
      onSuccess: (v) => v,
      onFailure: (f) {
        failure = f;
      },
    );

    if (ok != true) {
      state = state.copyWith(
        isDownloadingDb: false,
        errorMessage: failure?.message,
      );
      return;
    }

    state = state.copyWith(
      needsDownload: false,
      isDownloadingDb: false,
      isLoading: true,
      errorMessage: null,
      hasDbUpdate: false,
      remoteUpdatedAt: null,
    );

    await fetchSongs(forceRefresh: true);

    final songs = state.songs;
    if (songs.isNotEmpty) {
      final fingerprint = _searchFingerprintFromSongs(songs);
      unawaited(
        _songSearchRepo.ensureIndexed(
          songs: songs,
          fingerprint: fingerprint,
          forceRebuild: true,
        ),
      );
    }

    // After successful download, re-check remote metadata (in case of race).
    unawaited(checkForDbUpdate(forceRefresh: true));
  }

  /// Search songs by title or content via API
  /// Requirements: 3.1, 3.2, 3.4
  ///
  /// This method handles the search state transition:
  /// - When query is empty: returns to category view (isSearching = false)
  /// - When query is non-empty: displays search results (isSearching = true)
  ///
  /// The 500ms debounce is handled by the UI layer to avoid excessive API calls.
  Future<void> searchSongs(String query, {bool forceRefresh = false}) async {
    // Check if provider is still mounted before accessing state
    if (!ref.mounted) return;
    if (state.needsDownload) return;

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

    final songs = state.songs;
    final fingerprint = _searchFingerprintFromSongs(songs);
    // Never block the UI for indexing. Indexing runs in the background.
    unawaited(
      _songSearchRepo.ensureIndexed(
        songs: songs,
        fingerprint: fingerprint,
        forceRebuild: forceRefresh,
      ),
    );

    final ids = await _songSearchRepo.searchSongIds(
      query: trimmedQuery,
      songs: songs,
      limit: 200,
    );

    if (!ref.mounted) return;
    if (state.searchQuery != trimmedQuery) return;

    final byId = {for (final s in songs) s.id: s};
    final ordered = <Song>[];
    for (final id in ids) {
      final song = byId[id];
      if (song != null) ordered.add(song);
    }

    state = state.copyWith(
      filteredSongs: ordered,
      isLoading: false,
      errorMessage: null,
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
  bool isInSearchMode() => state.isSearching && state.searchQuery.isNotEmpty;

  /// Refresh songs data for retry functionality (Requirement 4.4)
  Future<void> refreshSongs() async {
    // Check if provider is still mounted before accessing state
    if (!ref.mounted) return;
    if (state.needsDownload) return;

    // Clear error state and set loading
    state = state.copyWith(errorMessage: null, isLoading: true);

    // Re-call fetchSongs or searchSongs based on current search query
    if (state.searchQuery.isNotEmpty) {
      await searchSongs(state.searchQuery, forceRefresh: true);
    } else {
      await fetchSongs(forceRefresh: true);
    }
  }

  /// Filter songs by category/type (e.g., "KJ", "NNBT", "NKB", "DSL")
  void filterByCategory(String category) {
    if (state.needsDownload) return;
    final filteredSongs = state.songs.where((song) {
      final q = category.toUpperCase();
      return song.title.toUpperCase().contains(q) ||
          song.subTitle.toUpperCase().contains(q) ||
          song.bookId.toUpperCase().contains(q) ||
          song.bookName.toUpperCase().contains(q);
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
    final targetId = categoryId.trim();
    final abbreviation =
        category?.abbreviation.toUpperCase() ?? targetId.toUpperCase();

    return state.songs.where((song) {
      final bookId = song.bookId.trim();
      if (bookId.isNotEmpty) {
        return bookId == targetId;
      }
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
      categoryExpansionState: _initializeCategoryExpansionState(
        state.categories,
      ),
    );
  }
}

// Provider for easy access to the filtered songs list
@riverpod
List<Song> songProvider(Ref ref) {
  final songBookState = ref.watch(songBookControllerProvider);
  return songBookState.filteredSongs;
}
