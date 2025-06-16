import 'package:palakat/features/presentation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_controller.g.dart';

@riverpod
class AccountController extends _$AccountController {
  @override
  AccountState build() {
    return const AccountState(textGender: "MALE", textMaritalStatus: "SINGLE");
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
    state = state.copyWith(textPhone: value);
  }

  void onChangedTextName(String value) {
    state = state.copyWith(textName: value);
  }

  void onChangedDOB(String value) {
    state = state.copyWith(textDob: value);
  }

  void onChangedGender(String value) {
    state = state.copyWith(textGender: value);
  }

  void onChangedMaritalStatus(String value) {
    state = state.copyWith(textMaritalStatus: value);
    print(value);
  }

  bool validateAccount() {
    return validateTextPhone(state.textPhone) == null &&
        validateTextName(state.textName) == null &&
        validateDOB(state.textDob) == null &&
        validateGender(state.textGender) == null &&
        validateMaritalStatus(state.textMaritalStatus) == null;
  }

  Future<void> validateForm() async {
    state = state.copyWith(loading: true);
    final errorTextPhone = validateTextPhone(state.textPhone);
    final errorTextname = validateTextName(state.textName);
    final errorDOB = validateDOB(state.textDob);
    final errorGender = validateGender(state.textGender);
    final errorMaritalStatus = validateMaritalStatus(state.textMaritalStatus);

    final isValid = errorTextPhone == null &&
        errorTextname == null &&
        errorDOB == null &&
        errorGender == null &&
        errorMaritalStatus == null;

    state = state.copyWith(
      errorTextPhone: errorTextPhone,
      errorTextName: errorTextname,
      errorTextDob: errorDOB,
      errorTextGender: errorGender,
      errorTextMaritalStatus: errorMaritalStatus,
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
