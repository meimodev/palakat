import 'package:freezed_annotation/freezed_annotation.dart';

enum LoginSocialType {
  @JsonValue('GOOGLE')
  google,
  @JsonValue('FACEBOOK')
  facebook,
  @JsonValue('APPLE')
  apple,
}
