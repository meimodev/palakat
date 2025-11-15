import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/models/models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat/features/song_book/presentations/song_book_state.dart';

part 'song_book_controller.g.dart';

@riverpod
class SongBookController extends _$SongBookController {
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

  Future<void> fetchSongs() async {

    try {
      final songs = _getMockSongs();

      state = state.copyWith(
        songs: songs,
        filteredSongs: songs,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load songs: ${e.toString()}',
      );
    }
  }

  /// Search songs by title or subtitle
  void searchSongs(String query) {
    if (query.isEmpty) {
      // Reset to show all songs
      state = state.copyWith(
        filteredSongs: state.songs,
        searchQuery: '',
        isSearching: false,
      );
      return;
    }

    final filteredSongs = state.songs.where((song) {
      final titleMatch = song.title.toLowerCase().contains(query.toLowerCase());
      final subtitleMatch = song.subTitle.toLowerCase().contains(
        query.toLowerCase(),
      );
      return titleMatch || subtitleMatch;
    }).toList();

    state = state.copyWith(
      filteredSongs: filteredSongs,
      searchQuery: query,
      isSearching: true,
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

  /// Refresh songs data
  Future<void> refreshSongs() async {
    await fetchSongs();
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

  /// Get mock songs data (replace with actual repository call)
  List<Song> _getMockSongs() {
    return List.generate(
      20,
      (index) => Song(
        id: 'song_$index',
        title: _getSongTitle(index),
        subTitle: _getSongSubtitle(index),
        composition: [
          SongPartType.verse,
          SongPartType.chorus,
          SongPartType.verse,
          SongPartType.chorus,
        ],
        definition: [
          SongPart(
            type: SongPartType.verse,
            content:
                'Verse content for song ${index + 1}. Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
          ),
          SongPart(
            type: SongPartType.chorus,
            content:
                'Chorus content for song ${index + 1}. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
          ),
        ],
        urlImage: '',
        urlVideo: '',
      ),
    );
  }

  String _getSongTitle(int index) {
    final categories = ['KJ', 'NNBT', 'NKB', 'DSL'];
    final category = categories[index % categories.length];
    final number = (index ~/ categories.length) + 1;
    return '$category NO.$number';
  }

  String _getSongSubtitle(int index) {
    final subtitles = [
      'Tuhan Allah Sumber Segala Berkat',
      'Kasih Allah Yang Besar',
      'Puji Syukur Kepada Tuhan',
      'Kemuliaan Bagi Allah',
      'Damai Sejahtera',
    ];
    return subtitles[index % subtitles.length];
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
