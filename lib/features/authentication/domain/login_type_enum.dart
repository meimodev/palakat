import 'package:halo_hermina/core/localization/localization.dart';

enum LoginType { email, phone }

extension LoginTypeExtension on LoginType {
  String get name {
    switch (this) {
      case LoginType.email:
        return "EMAIL_PASSWORD";
      case LoginType.phone:
        return "PHONE_OTP";
    }
  }

  String get labelKeyTranslation {
    switch (this) {
      case LoginType.email:
        return LocaleKeys.text_email;
      case LoginType.phone:
        return LocaleKeys.text_phone;
    }
  }
}
