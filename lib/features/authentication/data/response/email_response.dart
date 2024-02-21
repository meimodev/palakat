import 'package:freezed_annotation/freezed_annotation.dart';

part 'email_response.freezed.dart';
part 'email_response.g.dart';

@freezed
class EmailResponse with _$EmailResponse {
  const factory EmailResponse({
    @Default("") String email,
  }) = _EmailResponse;

  factory EmailResponse.fromJson(Map<String, dynamic> json) =>
      _$EmailResponseFromJson(json);
}
