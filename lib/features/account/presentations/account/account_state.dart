import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat/core/models/models.dart';

part 'account_state.freezed.dart';

@freezed
class AccountState with _$AccountState {
  const factory AccountState({
    Account? account,
    String? textPhone,
    String? textDob,
    String? textName,
    String? textGender,
    String? textMaritalStatus,
    String? errorTextPhone,
    String? errorTextName,
    String? errorTextDob,
    String? errorTextGender,
    String? errorTextMaritalStatus,
    @Default(true) bool loading,
    @Default(false) bool submitLoading,
    @Default(false) bool isFormValid,
  }) = _AccountState;
}
