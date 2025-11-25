import 'package:palakat_shared/core/models/models.dart';
import 'package:palakat_shared/repositories.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'song_detail_controller.g.dart';

@riverpod
class SongDetailController extends _$SongDetailController {
  @override
  Future<List<SongPart>> build(Song song) async {
    state = const AsyncValue.loading();
    try {
      // Check if song data is incomplete (empty definition or composition)
      final isIncomplete = song.definition.isEmpty || song.composition.isEmpty;

      Song completeSong = song;

      // Fetch complete song data if incomplete
      if (isIncomplete) {
        final songRepo = ref.read(songRepositoryProvider);
        final result = await songRepo.getSongById(songId: song.id);

        result.when(
          onSuccess: (fetchedSong) {
            completeSong = fetchedSong;
            return null;
          },
          onFailure: (failure) {
            // If fetch fails, continue with original song data
            // This allows graceful degradation
            completeSong = song;
          },
        );
      }

      final songParts = completeSong.composition
          .map((e) => completeSong.definition.firstWhere((f) => f.type == e))
          .toList();
      state = AsyncValue.data(songParts);
      return songParts;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return [];
    }
  }
}
