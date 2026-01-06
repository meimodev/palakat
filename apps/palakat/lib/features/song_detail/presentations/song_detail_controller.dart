import 'package:palakat_shared/core/models/models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'song_detail_controller.g.dart';

@riverpod
class SongDetailController extends _$SongDetailController {
  @override
  Future<List<SongPart>> build(Song song) async {
    state = const AsyncValue.loading();
    try {
      final songParts = <SongPart>[];

      if (song.composition.isNotEmpty) {
        for (final type in song.composition) {
          final idx = song.definition.indexWhere((f) => f.type == type);
          if (idx != -1) {
            songParts.add(song.definition[idx]);
          }
        }
      }

      if (songParts.isEmpty) {
        songParts.addAll(song.definition);
      } else {
        for (final def in song.definition) {
          final exists = songParts.any(
            (p) => p.type == def.type && p.content == def.content,
          );
          if (!exists) {
            songParts.add(def);
          }
        }
      }

      state = AsyncValue.data(songParts);
      return songParts;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return [];
    }
  }
}
