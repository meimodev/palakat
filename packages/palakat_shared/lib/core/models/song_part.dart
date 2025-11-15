import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_shared/core/constants/enums.dart';


part 'song_part.freezed.dart';

part 'song_part.g.dart';

@freezed
abstract class SongPart with _$SongPart {
  const factory SongPart({
    required SongPartType type,
    required String content,
  }) = _SongPart;

  factory SongPart.fromJson(Map<String, dynamic> data) => _$SongPartFromJson(data);

}

