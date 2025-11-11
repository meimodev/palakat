import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_credentials.freezed.dart';
part 'auth_credentials.g.dart';

/// Credentials for login using username/email/phone and password
@freezed
abstract class AuthCredentials with _$AuthCredentials {
  const factory AuthCredentials({
    /// Can be username, email, or phone
    required String identifier,
    required String password,
  }) = _AuthCredentials;

  factory AuthCredentials.fromJson(Map<String, dynamic> json) =>
      _$AuthCredentialsFromJson(json);
}
