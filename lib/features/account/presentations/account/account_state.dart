import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat/core/models/models.dart';

part 'account_state.freezed.dart';

@freezed
abstract class AccountState with _$AccountState {
  const factory AccountState({
    Account? account,
    String? phone,
    String? name,
    String? dob,
    String? gender,
    String? married,
    String? errorPhone,
    String? errorName,
    String? errorDob,
    String? errorGender,
    String? errormarried,
    bool? loading,
    @Default(false) bool submitLoading,
    @Default(false) bool isFormValid,
  }) = _AccountState;
}
