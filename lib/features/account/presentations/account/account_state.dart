import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat/core/constants/enums/enums.dart';
import 'package:palakat/core/models/models.dart';

part 'account_state.freezed.dart';

@freezed
abstract class AccountState with _$AccountState {
  const factory AccountState({
    Account? account,
    String? phone,
    String? name,
    DateTime? dob,
    Gender? gender,
    MaritalStatus? maritalStatus,
    String? errorPhone,
    String? errorName,
    String? errorDob,
    String? errorGender,
    String? errorMarried,
    @Default(false) bool loading,
    @Default(false) bool isFormValid,
  }) = _AccountState;
}
