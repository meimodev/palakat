import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_refresh_request.g.dart';

@JsonSerializable(includeIfNull: false)
class LoginRefreshRequest {
  final String refreshToken;

  const LoginRefreshRequest({
    required this.refreshToken,
  });

  factory LoginRefreshRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRefreshRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRefreshRequestToJson(this);
}
