import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';

part 'reset_password_request.g.dart';

@JsonSerializable(includeIfNull: false)
class ResetPasswordRequest {
  final String userSerial;
  @StringConverter()
  final String? password;
  final String token;

  const ResetPasswordRequest({
    required this.userSerial,
    this.password,
    required this.token,
  });

  Map<String, dynamic> toJson() => _$ResetPasswordRequestToJson(this);
}
