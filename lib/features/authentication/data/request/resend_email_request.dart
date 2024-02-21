import 'package:freezed_annotation/freezed_annotation.dart';

part 'resend_email_request.g.dart';

@JsonSerializable(includeIfNull: false)
class ResendEmailRequest {
  final String email;

  const ResendEmailRequest({
    required this.email,
  });

  factory ResendEmailRequest.fromJson(Map<String, dynamic> json) =>
      _$ResendEmailRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ResendEmailRequestToJson(this);
}
