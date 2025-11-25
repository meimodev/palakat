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
    // Initialize with empty state and fetch songs
    fetchSongs();

    return SongBookState(
      songs: [],
      filteredSongs: [],
      isLoading: true,
      isSearching: false,
      searchQuery: '',
      errorMessage: null,
    );
  }

  /// Fetch songs from the backend API (Requirements 1.2, 4.1, 4.2)
  Future<void> fetchSongs() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _songRepo.getSongs(
      paginationRequest: PaginationRequestWrapper(
        page: 1,
        pageSize: 50,
        data: GetFetchSongsRequest(),
      ),
    );

    result.when(
      onSuccess: (response) {
        state = state.copyWith(
          songs: response.data,
          filteredSongs: response.data,
          isLoading: false,
        );
        return null;
      },
      onFailure: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
    );
  }

  /// Search songs by title or content via API (Requirements 1.1, 1.3, 1.4)
  Future<void> searchSongs(String query) async {
    // Clear search state for empty queries (Requirement 1.3)
    if (query.trim().isEmpty) {
      state = state.copyWith(
        filteredSongs: state.songs,
        searchQuery: '',
        isSearching: false,
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      searchQuery: query,
      isSearching: true,
    );

    final result = await _songRepo.searchSongs(query: query);

    result.when(
      onSuccess: (response) {
        state = state.copyWith(filteredSongs: response.data, isLoading: false);
        return null;
      },
      onFailure: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
    );
  }

  /// Clear search and reset to show all songs
  void clearSearch() {
    state = state.copyWith(
      filteredSongs: state.songs,
      searchQuery: '',
      isSearching: false,
    );
  }

  /// Refresh songs data for retry functionality (Requirement 4.4)
  Future<void> refreshSongs() async {
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
}

// Provider for easy access to the filtered songs list
@riverpod
List<Song> songProvider(Ref ref) {
  final songBookState = ref.watch(songBookControllerProvider);
  return songBookState.filteredSongs;
}
