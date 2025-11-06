import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/features/presentation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_controller.g.dart';

@riverpod
class AccountController extends _$AccountController {
  @override
  AccountState build() {
    return const AccountState();
  }

  String? validateTextPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone Number is required';
    }
    return null;
  }

  String? validateTextName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full Name is required';
    }
    return null;
  }

  String? validateDOB(DateTime? value) {
    if (value == null ) {
      return 'Date Of Birth is required';
    }
    return null;
  }

  String? validateGender(Gender? value) {
    if (value == null ) {
      return 'Gender is required';
    }
    return null;
  }

  String? validateMaritalStatus(MaritalStatus? value) {
    if (value == null ) {
      return 'Marital Status is required';
    }
    return null;
  }

  void onChangedTextPhone(String value) {
    state = state.copyWith(phone: value, errorPhone: null);
  }

  void onChangedTextName(String value) {
    state = state.copyWith(name: value, errorName: null);
  }

  void onChangedDOB(DateTime value) {
    state = state.copyWith(dob: value, errorDob: null);
  }

  void onChangedGender(Gender value) {
    state = state.copyWith(gender: value, errorGender: null);
  }

  void onChangedMaritalStatus(MaritalStatus value) {
    state = state.copyWith(maritalStatus: value, errorMarried: null);
  }

  bool validateAccount() {
    return validateTextPhone(state.phone) == null &&
        validateTextName(state.name) == null &&
        validateDOB(state.dob) == null &&
        validateGender(state.gender) == null &&
        validateMaritalStatus(state.maritalStatus) == null;
  }

  Future<void> validateForm() async {
    state = state.copyWith(loading: true);
    final errorPhone = validateTextPhone(state.phone);
    final errorName = validateTextName(state.name);
    final errorDob = validateDOB(state.dob);
    final errorGender = validateGender(state.gender);
    final errorMarried = validateMaritalStatus(state.maritalStatus);

    final isValid =
        errorPhone == null &&
        errorName == null &&
        errorDob == null &&
        errorGender == null &&
        errorMarried == null;

    state = state.copyWith(
      errorPhone: errorPhone,
      errorName: errorName,
      errorDob: errorDob,
      errorGender: errorGender,
      errorMarried: errorMarried,
      isFormValid: isValid,
    );

    await Future.delayed(const Duration(milliseconds: 400));
    state = state.copyWith(loading: false);
  }

  Future<bool> submit() async {
    await validateForm();
    return state.isFormValid;
  }

  void publish() {}
}
