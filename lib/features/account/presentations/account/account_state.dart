import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat/core/models/models.dart';

part 'account_state.freezed.dart';

@freezed
abstract class AccountState with _$AccountState {
  const factory AccountState({
    Account? account,
    required String errorTextPhone,
    required String errorTextName,
    required String errorTextDob,
    required String errorTextGender,
    required String errorTextMaritalStatus,
    @Default(true) bool loading,
    @Default(false) bool submitLoading,
  }) = _AccountState;
}
