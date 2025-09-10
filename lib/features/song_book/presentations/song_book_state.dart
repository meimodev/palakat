import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat/core/models/models.dart';

part 'song_book_state.freezed.dart';

@freezed
abstract class SongBookState with _$SongBookState {
  const factory SongBookState({
    @Default([]) List<Song> songs,
    @Default([]) List<Song> filteredSongs,
    @Default(false) bool isLoading,
    @Default(false) bool isSearching,
    @Default('') String searchQuery,
    @Default(null) String? errorMessage,
  }) = _SongBookState;
}
