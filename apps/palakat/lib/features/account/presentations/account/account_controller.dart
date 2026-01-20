import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/features/presentation.dart';
import 'package:palakat_shared/l10n/generated/app_localizations.dart';
import 'package:palakat_shared/models.dart';
import 'package:palakat_shared/repositories.dart';
import 'package:palakat_shared/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_controller.g.dart';

AppLocalizations _l10n() {
  final localeName = intl.Intl.getCurrentLocale();
  final languageCode = localeName.split(RegExp('[_-]')).first;
  return lookupAppLocalizations(
    Locale(languageCode.isEmpty ? 'en' : languageCode),
  );
}

@riverpod
class AccountController extends _$AccountController {
  String? _firebaseIdToken;

  @override
  AccountState build() {
    return const AccountState();
  }

  /// Format phone number with dashes (XXXX-XXXX-XXXX)
  String _formatPhoneNumber(String? phone) {
    // Remove all non-digit characters
    final digits = (phone ?? '').replaceAll(RegExp(r'\D'), '');

    // Limit to 13 digits
    final limitedDigits = digits.length > 13 ? digits.substring(0, 13) : digits;

    // Build formatted string with dashes every 4 digits
    final buffer = StringBuffer();
    for (int i = 0; i < limitedDigits.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write('-');
      }
      buffer.write(limitedDigits[i]);
    }

    return buffer.toString();
  }

  /// Initialize with verified phone number from authentication flow
  void initializeWithVerifiedPhone(String verifiedPhone) {
    final formattedPhone = _formatPhoneNumber(verifiedPhone);
    state = state.copyWith(
      verifiedPhone: formattedPhone,
      phone: formattedPhone,
      isPhoneVerified: true,
    );
  }

  void initializeWithFirebaseIdToken(String firebaseIdToken) {
    _firebaseIdToken = firebaseIdToken;
  }

  /// Fetch account data from backend by ID
  Future<void> fetchAccountData(int accountId) async {
    state = state.copyWith(isFetchingAccount: true, errorMessage: null);

    try {
      final l10n = _l10n();
      final membershipRepo = ref.read(membershipRepositoryProvider);

      final result = await membershipRepo.fetchAccount(accountId: accountId);

      final account = result.when(
        onSuccess: (acc) => acc,
        onFailure: (failure) {
          state = state.copyWith(
            isFetchingAccount: false,
            errorMessage: '${l10n.error_loadingAccount}: ${failure.message}',
          );
          return;
        },
      );

      if (account == null) {
        return;
      }

      // Initialize with fetched account data
      initializeWithAccountData(account.toJson());

      state = state.copyWith(isFetchingAccount: false);
    } catch (e) {
      final l10n = _l10n();
      state = state.copyWith(
        isFetchingAccount: false,
        errorMessage: '${l10n.error_unexpectedError}: ${e.toString()}',
      );
    }
  }

  /// Initialize with existing account data (for signed-in users editing profile)
  void initializeWithAccountData(Map<String, dynamic> accountData) {
    try {
      final account = Account.fromJson(accountData);

      // Format the phone number for display
      final formattedPhone = _formatPhoneNumber(account.phone);

      state = state.copyWith(
        account: account,
        phone: formattedPhone,
        name: account.name,
        email: account.email,
        dob: account.dob,
        gender: account.gender,
        maritalStatus: account.maritalStatus,
        claimed: account.claimed,
        verifiedPhone: formattedPhone,
        isPhoneVerified: true,
      );
    } catch (e) {
      final l10n = _l10n();
      // If parsing fails, log detailed error
      state = state.copyWith(
        errorMessage: '${l10n.error_loadingAccount}: ${e.toString()}',
      );
    }
  }

  String? validateTextPhone(String? value) {
    final l10n = _l10n();
    if (value == null || value.isEmpty) {
      return l10n.validation_phoneRequired;
    }
    return null;
  }

  String? validateTextName(String? value) {
    final l10n = _l10n();
    if (value == null || value.isEmpty) {
      return l10n.validation_nameRequired;
    }
    return null;
  }

  String? validateEmail(String? value) {
    final l10n = _l10n();
    if (value == null || value.isEmpty) {
      return null; // Email is optional
    }
    // Basic email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return l10n.validation_invalidEmail;
    }
    return null;
  }

  String? validateDOB(DateTime? value) {
    final l10n = _l10n();
    if (value == null) {
      return l10n.validation_dateRequired;
    }
    return null;
  }

  String? validateGender(Gender? value) {
    final l10n = _l10n();
    if (value == null) {
      return l10n.validation_selectionRequired;
    }
    return null;
  }

  String? validateMaritalStatus(MaritalStatus? value) {
    final l10n = _l10n();
    if (value == null) {
      return l10n.validation_selectionRequired;
    }
    return null;
  }

  void onChangedTextPhone(String value) {
    state = state.copyWith(phone: value, errorPhone: null);
  }

  void onChangedTextName(String value) {
    state = state.copyWith(name: value, errorName: null);
  }

  void onChangedEmail(String value) {
    state = state.copyWith(email: value, errorEmail: null);
  }

  void onChangedClaimed(bool value) {
    state = state.copyWith(claimed: value);
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
        validateEmail(state.email) == null &&
        validateDOB(state.dob) == null &&
        validateGender(state.gender) == null &&
        validateMaritalStatus(state.maritalStatus) == null;
  }

  Future<void> validateForm() async {
    state = state.copyWith(loading: true);
    final errorPhone = validateTextPhone(state.phone);
    final errorName = validateTextName(state.name);
    final errorEmail = validateEmail(state.email);
    final errorDob = validateDOB(state.dob);
    final errorGender = validateGender(state.gender);
    final errorMarried = validateMaritalStatus(state.maritalStatus);

    final isValid =
        errorPhone == null &&
        errorName == null &&
        errorEmail == null &&
        errorDob == null &&
        errorGender == null &&
        errorMarried == null;

    state = state.copyWith(
      errorPhone: errorPhone,
      errorName: errorName,
      errorEmail: errorEmail,
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

  /// Updates an existing account with the backend
  /// Returns updated Account on success, null on failure
  Future<Account?> updateAccount() async {
    // Validate form first
    await validateForm();
    if (!state.isFormValid) {
      return null;
    }

    // Must have an existing account to update
    if (state.account == null || state.account!.id == null) {
      final l10n = _l10n();
      state = state.copyWith(errorMessage: l10n.err_noData);
      return null;
    }

    state = state.copyWith(isRegistering: true, errorMessage: null);

    try {
      final membershipRepo = ref.read(membershipRepositoryProvider);

      // Prepare update data
      final updateData = <String, dynamic>{
        'name': state.name,
        if (state.email != null && state.email!.isNotEmpty)
          'email': state.email,
        'dob': state.dob?.toIso8601String(),
        'gender': state.gender?.name.toUpperCase(),
        'maritalStatus': state.maritalStatus?.name.toUpperCase(),
        'claimed': state.claimed,
      };

      // Update account via membership repository
      final updateResult = await membershipRepo.updateAccount(
        accountId: state.account!.id!,
        update: updateData,
      );

      // Handle update result
      final updatedAccount = updateResult.when(
        onSuccess: (acc) => acc,
        onFailure: (failure) {
          final l10n = _l10n();
          state = state.copyWith(
            isRegistering: false,
            errorMessage: '${l10n.msg_updateFailed}: ${failure.message}',
          );
          return;
        },
      );

      if (updatedAccount == null) {
        return null;
      }

      // Update locally saved account
      final authRepo = ref.read(authRepositoryProvider);
      final localStorage = ref.read(localStorageServiceProvider);

      // Get current auth data
      final currentAuth = localStorage.currentAuth;
      if (currentAuth != null) {
        // Update the account in the auth response
        final updatedAuth = currentAuth.copyWith(account: updatedAccount);
        await authRepo.updateLocallySavedAuth(updatedAuth);
      }

      state = state.copyWith(
        isRegistering: false,
        account: updatedAccount,
        errorMessage: null,
      );

      return updatedAccount;
    } catch (e) {
      final l10n = _l10n();
      state = state.copyWith(
        isRegistering: false,
        errorMessage: '${l10n.error_unexpectedError}: ${e.toString()}',
      );
      return null;
    }
  }

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
      final authRepo = ref.read(authRepositoryProvider);

      final firebaseIdToken = _firebaseIdToken;
      if (firebaseIdToken == null || firebaseIdToken.trim().isEmpty) {
        final l10n = _l10n();
        state = state.copyWith(
          isRegistering: false,
          errorMessage: l10n.err_somethingWentWrong,
        );
        return null;
      }

      // Prepare account data for registration
      final accountData = {
        'name': state.name,
        if (state.email != null && state.email!.isNotEmpty)
          'email': state.email,
        'dob': state.dob?.toIso8601String(),
        'gender': state.gender?.name.toUpperCase(),
        'maritalStatus': state.maritalStatus?.name.toUpperCase(),
        'claimed': state.claimed,
      };

      final registerResult = await authRepo.firebaseRegister(
        firebaseIdToken: firebaseIdToken,
        dto: accountData,
      );

      final authResponse = registerResult.when(
        onSuccess: (auth) => auth,
        onFailure: (failure) {
          final l10n = _l10n();
          state = state.copyWith(
            isRegistering: false,
            errorMessage: '${l10n.err_somethingWentWrong}: ${failure.message}',
          );
          return;
        },
      );

      if (authResponse == null) {
        return null;
      }

      state = state.copyWith(
        isRegistering: false,
        account: authResponse.account,
        errorMessage: null,
      );

      return authResponse;
    } catch (e) {
      final l10n = _l10n();
      state = state.copyWith(
        isRegistering: false,
        errorMessage: '${l10n.error_unexpectedError}: ${e.toString()}',
      );
      return null;
    }
  }
}
