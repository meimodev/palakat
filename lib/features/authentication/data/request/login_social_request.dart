import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/features/domain.dart';

part 'login_social_request.g.dart';

@JsonSerializable(includeIfNull: false)
class LoginSocialRequest {
  final LoginSocialType type;
  @EncrypterConverter()
  final String email;

  const LoginSocialRequest({
    required this.type,
    required this.email,
  });

  factory LoginSocialRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginSocialRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginSocialRequestToJson(this);
}
