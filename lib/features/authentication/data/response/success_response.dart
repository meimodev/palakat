import 'package:freezed_annotation/freezed_annotation.dart';

part 'success_response.freezed.dart';
part 'success_response.g.dart';

@freezed
class SuccessResponse with _$SuccessResponse {
  const factory SuccessResponse({
    @JsonKey(name: 'success') @Default(false) bool success,
  }) = _SuccessResponse;

  factory SuccessResponse.fromJson(Map<String, dynamic> json) =>
      _$SuccessResponseFromJson(json);
}
