import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';

part 'forgot_password_request.g.dart';

@JsonSerializable(includeIfNull: false)
class ForgotPasswordRequest {
  @StringConverter()
  final String? email;
  final String type;

  const ForgotPasswordRequest({
    required this.email,
    required this.type,
  });

  Map<String, dynamic> toJson() => _$ForgotPasswordRequestToJson(this);
}
