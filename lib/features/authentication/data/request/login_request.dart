import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';

part 'login_request.g.dart';

@JsonSerializable(includeIfNull: false)
class LoginRequest {
  @StringConverter()
  final String? username;
  @StringConverter()
  final String? password;
  final String type;

  const LoginRequest({
    required this.username,
    required this.password,
    required this.type,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}
