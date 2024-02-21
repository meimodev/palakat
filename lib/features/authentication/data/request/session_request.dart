import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_request.g.dart';

@JsonSerializable(includeIfNull: false)
class SessionRequest {
  final String token;

  const SessionRequest({
    required this.token,
  });

  factory SessionRequest.fromJson(Map<String, dynamic> json) =>
      _$SessionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SessionRequestToJson(this);
}
