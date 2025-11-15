import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_shared/core/models/auth_tokens.dart';

import 'account.dart';

part 'auth_response.freezed.dart';
part 'auth_response.g.dart';

/// Standardized authentication API response containing tokens and optional user info
@freezed
abstract class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required AuthTokens tokens,
    required Account account,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}
