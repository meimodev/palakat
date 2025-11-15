import 'package:palakat_shared/core/models/models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'song_detail_controller.g.dart';

@riverpod
class SongDetailController extends _$SongDetailController {
  @override
  Future<List<SongPart>> build(Song song) async {
    state = const AsyncValue.loading();
    try {
      final songParts = song.composition
          .map((e) => song.definition.firstWhere((f) => f.type == e))
          .toList();
      state = AsyncValue.data(songParts);
      return songParts;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return [];
    }
  }
}
