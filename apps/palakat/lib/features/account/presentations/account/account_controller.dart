import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/features/presentation.dart';
import 'package:palakat_shared/models.dart';
import 'package:palakat_shared/repositories.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_controller.g.dart';

@riverpod
class AccountController extends _$AccountController {
  @override
  AccountState build() {
    return const AccountState();
  }

  /// Initialize with verified phone number from authentication flow
  void initializeWithVerifiedPhone(String verifiedPhone) {
    state = state.copyWith(
      verifiedPhone: verifiedPhone,
      phone: verifiedPhone,
      isPhoneVerified: true,
    );
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
    if (value == null) {
      return 'Date Of Birth is required';
    }
    return null;
  }

  String? validateGender(Gender? value) {
    if (value == null) {
      return 'Gender is required';
    }
    return null;
  }

  String? validateMaritalStatus(MaritalStatus? value) {
    if (value == null) {
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

  /// Registers a new account with the backend
  /// Returns AuthResponse on success, null on failure
  Future<AuthResponse?> registerAccount() async {
    // Validate form first
    await validateForm();
    if (!state.isFormValid) {
      return null;
    }

    state = state.copyWith(isRegistering: true, errorMessage: null);

    try {
      final membershipRepo = ref.read(membershipRepositoryProvider);
      final authRepo = ref.read(authRepositoryProvider);

      // Use verified phone if available, otherwise use entered phone
      final phoneToUse = state.verifiedPhone ?? state.phone;

      if (phoneToUse == null || phoneToUse.isEmpty) {
        state = state.copyWith(
          isRegistering: false,
          errorMessage: 'Phone number is required',
        );
        return null;
      }

      // Prepare account data for registration
      final accountData = {
        'phone': phoneToUse,
        'name': state.name,
        'dob': state.dob?.toIso8601String(),
        'gender': state.gender?.name,
        'maritalStatus': state.maritalStatus?.name,
      };

      // Create account via membership repository
      final createResult = await membershipRepo.createAccount(
        data: accountData,
      );

      // Handle account creation result
      final account = createResult.when(
        onSuccess: (acc) => acc,
        onFailure: (failure) {
          state = state.copyWith(
            isRegistering: false,
            errorMessage: 'Failed to register: ${failure.message}',
          );
          return null;
        },
      );

      if (account == null) {
        return null;
      }

      // Account created successfully, now validate to get tokens
      final validateResult = await authRepo.validateAccountByPhone(phoneToUse);

      final authResponse = validateResult.when(
        onSuccess: (auth) => auth,
        onFailure: (failure) {
          state = state.copyWith(
            isRegistering: false,
            errorMessage:
                'Registration successful but failed to sign in: ${failure.message}',
          );
          return null;
        },
      );

      if (authResponse == null) {
        return null;
      }

      // Store auth data locally
      await authRepo.updateLocallySavedAuth(authResponse);

      state = state.copyWith(
        isRegistering: false,
        account: authResponse.account,
        errorMessage: null,
      );

      return authResponse;
    } catch (e) {
      state = state.copyWith(
        isRegistering: false,
        errorMessage: 'An unexpected error occurred: ${e.toString()}',
      );
      return null;
    }
  }
}
