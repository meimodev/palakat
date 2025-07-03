import 'package:palakat/features/presentation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_controller.g.dart';

@riverpod
class AccountController extends _$AccountController {
  @override
  AccountState build() {
    return const AccountState(gender: "MALE", married: "SINGLE");
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

  String? validateDOB(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date Of Birth is required';
    }
    return null;
  }

  String? validateGender(String? value) {
    if (value == null || value.isEmpty) {
      return 'Gender is required';
    }
    return null;
  }

  String? validateMaritalStatus(String? value) {
    if (value == null || value.isEmpty) {
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

  void onChangedDOB(String value) {
    state = state.copyWith(dob: value, errorDob: null);
  }

  void onChangedGender(String value) {
    state = state.copyWith(gender: value, errorGender: null);
  }

  void onChangedMaritalStatus(String value) {
    state = state.copyWith(married: value, errorMarried: null);
  }

  bool validateAccount() {
    return validateTextPhone(state.phone) == null &&
        validateTextName(state.name) == null &&
        validateDOB(state.dob) == null &&
        validateGender(state.gender) == null &&
        validateMaritalStatus(state.married) == null;
  }

  Future<void> validateForm() async {
    state = state.copyWith(loading: true);
    final errorPhone = validateTextPhone(state.phone);
    final errorName = validateTextName(state.name);
    final errorDob = validateDOB(state.dob);
    final errorGender = validateGender(state.gender);
    final errorMarried = validateMaritalStatus(state.married);

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
    if (state.isFormValid) {
      print("Input Valid");
      return true;
    }
    return false;
  }

  void publish() {}
}
