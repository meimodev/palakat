import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/models/models.dart';

part 'song.freezed.dart';

part 'song.g.dart';

@freezed
class Song with _$Song {
  const factory Song({
    required String id,
    required String title,
    required String subTitle,
    required List<SongPartType> composition,
    @ListSongPartConverter() required List<SongPart> definition,
    @Default("") String urlImage,
    @Default("") String urlVideo,
  }) = _Song;

  factory Song.fromJson(Map<String, dynamic> data) => _$SongFromJson(data);
}

class ListSongPartConverter
    implements JsonConverter<List<SongPart>, List<Map<String, dynamic>>> {
  const ListSongPartConverter();

  @override
  List<SongPart> fromJson(List<Map<String, dynamic>> json) {
    return json.map((e) => SongPart.fromJson(e)).toList();
  }

  @override
  List<Map<String, dynamic>> toJson(List<SongPart> object) =>
      object.map((e) => e.toJson()).toList();
}
