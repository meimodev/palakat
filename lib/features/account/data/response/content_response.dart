import 'package:freezed_annotation/freezed_annotation.dart';

part 'content_response.freezed.dart';
part 'content_response.g.dart';

@freezed
class ContentResponse with _$ContentResponse {
  const factory ContentResponse({
    @JsonKey(name: 'serial')
    @Default("")
        String serial,
    @JsonKey(name: 'code')
    @Default("")
        String code,
    @JsonKey(name: 'content')
    @Default(ContentDataResponse())
        ContentDataResponse content,
  }) = _ContentResponse;

  factory ContentResponse.fromJson(Map<String, dynamic> json) =>
      _$ContentResponseFromJson(json);
}

@freezed
class ContentDataResponse with _$ContentDataResponse {
  const factory ContentDataResponse({
    @JsonKey(name: 'description') @Default("") String description,
  }) = _ContentDataResponse;

  factory ContentDataResponse.fromJson(Map<String, dynamic> json) =>
      _$ContentDataResponseFromJson(json);
}
