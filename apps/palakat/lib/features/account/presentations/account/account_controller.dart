import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/features/presentation.dart';
import 'package:palakat_shared/models.dart';
import 'package:palakat_shared/repositories.dart';
import 'package:palakat_shared/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_controller.g.dart';

@riverpod
class AccountController extends _$AccountController {
  @override
  AccountState build() {
    return const AccountState();
  }

  /// Format phone number with dashes (XXXX-XXXX-XXXX)
  String _formatPhoneNumber(String phone) {
    // Remove all non-digit characters
    final digits = phone.replaceAll(RegExp(r'\D'), '');

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

  /// Fetch account data from backend by ID
  Future<void> fetchAccountData(int accountId) async {
    print('🔄 AccountController: Fetching account data for ID: $accountId');
    state = state.copyWith(isFetchingAccount: true, errorMessage: null);

    try {
      final membershipRepo = ref.read(membershipRepositoryProvider);

      final result = await membershipRepo.fetchAccount(accountId: accountId);

      final account = result.when(
        onSuccess: (acc) => acc,
        onFailure: (failure) {
          print(
            '❌ AccountController: Failed to fetch account: ${failure.message}',
          );
          state = state.copyWith(
            isFetchingAccount: false,
            errorMessage: 'Failed to load account: ${failure.message}',
          );
          return null;
        },
      );

      if (account == null) {
        return;
      }

      print('✅ AccountController: Account fetched successfully');

      // Initialize with fetched account data
      initializeWithAccountData(account.toJson());

      state = state.copyWith(isFetchingAccount: false);
    } catch (e, stackTrace) {
      print('❌ AccountController: Error fetching account: $e');
      print('Stack trace: $stackTrace');
      state = state.copyWith(
        isFetchingAccount: false,
        errorMessage: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Initialize with existing account data (for signed-in users editing profile)
  void initializeWithAccountData(Map<String, dynamic> accountData) {
    try {
      // Debug: Print received data
      print('🔍 AccountController: Received accountData: $accountData');

      final account = Account.fromJson(accountData);

      // Debug: Print parsed account
      print(
        '✅ AccountController: Parsed account - name: ${account.name}, phone: ${account.phone}',
      );

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

      // Debug: Print updated state
      print(
        '✅ AccountController: State updated - name: ${state.name}, phone: ${state.phone}, email: ${state.email}',
      );
    } catch (e, stackTrace) {
      // If parsing fails, log detailed error
      print('❌ AccountController: Failed to parse account data: $e');
      print('Stack trace: $stackTrace');
      state = state.copyWith(
        errorMessage: 'Failed to load account data: ${e.toString()}',
      );
    }
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

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Email is optional
    }
    // Basic email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
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
      state = state.copyWith(errorMessage: 'No account to update');
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
          state = state.copyWith(
            isRegistering: false,
            errorMessage: 'Failed to update account: ${failure.message}',
          );
          return null;
        },
      );

      if (updatedAccount == null) {
        return null;
      }

      // Update locally saved account
      print('✅ AccountController: Updating locally saved account');
      final authRepo = ref.read(authRepositoryProvider);
      final localStorage = ref.read(localStorageServiceProvider);

      // Get current auth data
      final currentAuth = localStorage.currentAuth;
      if (currentAuth != null) {
        // Update the account in the auth response
        final updatedAuth = currentAuth.copyWith(account: updatedAccount);
        await authRepo.updateLocallySavedAuth(updatedAuth);
        print('✅ AccountController: Local account updated successfully');
      }

      state = state.copyWith(
        isRegistering: false,
        account: updatedAccount,
        errorMessage: null,
      );

      return updatedAccount;
    } catch (e) {
      state = state.copyWith(
        isRegistering: false,
        errorMessage: 'An unexpected error occurred: ${e.toString()}',
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

      // Strip formatting from phone (remove dashes)
      final cleanPhone = phoneToUse.replaceAll(RegExp(r'\D'), '');

      // Prepare account data for registration
      final accountData = {
        'phone': cleanPhone,
        'name': state.name,
        if (state.email != null && state.email!.isNotEmpty)
          'email': state.email,
        'dob': state.dob?.toIso8601String(),
        'gender': state.gender?.name.toUpperCase(),
        'maritalStatus': state.maritalStatus?.name.toUpperCase(),
        'claimed': state.claimed,
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
      final validateResult = await authRepo.validateAccountByPhone(cleanPhone);

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
