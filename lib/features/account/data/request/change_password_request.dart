import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';

part 'change_password_request.g.dart';

@JsonSerializable(includeIfNull: false)
class ChangePasswordRequest {
  @StringConverter()
  final String? oldPassword;
  @StringConverter()
  final String? newPassword;

  const ChangePasswordRequest({
    this.oldPassword,
    this.newPassword,
  });

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ChangePasswordRequestToJson(this);
}
