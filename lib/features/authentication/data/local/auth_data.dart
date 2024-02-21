import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_data.g.dart';

@JsonSerializable(includeIfNull: false)
class AuthData {
  final String accessToken;
  final String refreshToken;

  const AuthData({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) =>
      _$AuthDataFromJson(json);

  Map<String, dynamic> toJson() => _$AuthDataToJson(this);
}
