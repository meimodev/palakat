import 'package:freezed_annotation/freezed_annotation.dart';

part 'verify_email_request.g.dart';

@JsonSerializable(includeIfNull: false)
class VerifyEmailRequest {
  final String email;
  final String token;

  const VerifyEmailRequest({
    required this.email,
    required this.token,
  });

  factory VerifyEmailRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyEmailRequestFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyEmailRequestToJson(this);
}
