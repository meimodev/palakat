import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/models/models.dart';

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
    final String? errorMessage,
    // Registration flow fields
    String? verifiedPhone, // Phone number verified via Firebase
    @Default(false) bool isPhoneVerified, // Whether phone is pre-verified
    @Default(false) bool isRegistering, // Loading state for registration
  }) = _AccountState;
}
