import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/models.dart';

part 'song.freezed.dart';
part 'song.g.dart';

String _songIdFromJson(Object? value) {
  if (value == null) throw const FormatException('Missing song id');
  return value.toString();
}

@freezed
abstract class Song with _$Song {
  const factory Song({
    @JsonKey(fromJson: _songIdFromJson) required String id,
    @Default("") String bookId,
    @Default("") String bookName,
    @Default("") String title,
    @Default("") String subTitle,
    @Default("") String author,
    @Default("") String baseNote,
    DateTime? lastUpdate,
    @Default("") String publisher,
    @Default(<SongPartType>[])
    @JsonKey(unknownEnumValue: SongPartType.verse)
    List<SongPartType> composition,
    @Default(<SongPart>[]) List<SongPart> definition,
    @Default("") String urlImage,
    @Default("") String urlVideo,
  }) = _Song;

  factory Song.fromJson(Map<String, dynamic> data) => _$SongFromJson(data);
}
