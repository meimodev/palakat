import 'package:palakat/core/models/models.dart'; // Import your song model
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'song_detail_controller.g.dart';

@riverpod
class SongDetailController extends _$SongDetailController {
  @override
  List<SongPart> build() => [];

  void loadSongParts(Song song) {
    state = song.composition
        .map((e) => song.definition.firstWhere((f) => f.type == e))
        .toList();
  }
}
