import 'package:halo_hermina/core/utils/utils.dart';

enum ForgotPasswordType { user, admin }

extension ForgotPasswordTypeExtension on ForgotPasswordType {
  String get value => name.toSnakeCase.toUpperCase();
}
