import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_fetch_songs_request.freezed.dart';
part 'get_fetch_songs_request.g.dart';

@freezed
abstract class GetFetchSongsRequest with _$GetFetchSongsRequest {
  const factory GetFetchSongsRequest({String? search}) = _GetFetchSongsRequest;

  factory GetFetchSongsRequest.fromJson(Map<String, dynamic> json) =>
      _$GetFetchSongsRequestFromJson(json);
}
