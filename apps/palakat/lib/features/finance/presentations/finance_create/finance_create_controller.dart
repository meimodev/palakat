import 'package:palakat/features/finance/presentations/finance_create/finance_create_state.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/activity.dart';
import 'package:palakat_shared/core/models/finance_data.dart';
import 'package:palakat_shared/core/models/finance_type.dart';
import 'package:palakat_shared/core/models/request/create_expense_request.dart';
import 'package:palakat_shared/core/models/request/create_revenue_request.dart';
import 'package:palakat_shared/repositories.dart';
import 'package:palakat_shared/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'finance_create_controller.g.dart';

/// Controller for the Finance Create Screen.
/// Handles both revenue and expense creation in standalone and embedded modes.
/// Requirements: 2.2, 2.3, 2.5, 3.2, 3.3, 3.5, 4.4, 6.2
@riverpod
class FinanceCreateController extends _$FinanceCreateController {
  @override
  FinanceCreateState build(FinanceType financeType, bool isStandalone) {
    return FinanceCreateState(
      financeType: financeType,
      isStandalone: isStandalone,
    );
  }

  // ===== Validation Methods =====

  /// Validates that the amount is a positive integer.
  /// Requirements: 2.2, 3.2
  String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }

    final parsed = int.tryParse(value.replaceAll('.', '').replaceAll(',', ''));
    if (parsed == null) {
      return 'Amount must be a valid number';
    }

    if (parsed <= 0) {
      return 'Amount must be greater than 0';
    }

    return null;
  }

  /// Validates that the account number is not empty.
  /// Requirements: 2.3, 3.3
  String? validateAccountNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Account number is required';
    }
    return null;
  }

  /// Validates that a payment method is selected.
  /// Requirements: 2.4, 3.4
  String? validatePaymentMethod(PaymentMethod? value) {
    if (value == null) {
      return 'Payment method is required';
    }
    return null;
  }

  /// Validates that an activity is selected (only for standalone mode).
  /// Requirements: 4.1
  String? validateActivity(Activity? value) {
    if (state.isStandalone && value == null) {
      return 'Activity is required';
    }
    return null;
  }

  // ===== onChange Handlers =====

  /// Handles amount input changes.
  void onChangedAmount(String value) {
    state = state.copyWith(amount: value, errorAmount: validateAmount(value));
  }

  /// Handles account number input changes.
  void onChangedAccountNumber(String value) {
    state = state.copyWith(
      accountNumber: value,
      errorAccountNumber: validateAccountNumber(value),
    );
  }

  /// Handles payment method selection.
  void onSelectedPaymentMethod(PaymentMethod? method) {
    state = state.copyWith(
      paymentMethod: method,
      errorPaymentMethod: validatePaymentMethod(method),
    );
  }

  /// Handles activity selection (standalone mode only).
  void onSelectedActivity(Activity? activity) {
    state = state.copyWith(
      selectedActivity: activity,
      errorActivity: validateActivity(activity),
    );
  }

  // ===== Form Validation =====

  /// Validates all form fields and updates state.
  Future<void> validateForm() async {
    state = state.copyWith(loading: true);

    final amountError = validateAmount(state.amount);
    final accountNumberError = validateAccountNumber(state.accountNumber);
    final paymentMethodError = validatePaymentMethod(state.paymentMethod);
    final activityError = validateActivity(state.selectedActivity);

    final isValid =
        amountError == null &&
        accountNumberError == null &&
        paymentMethodError == null &&
        activityError == null;

    state = state.copyWith(
      errorAmount: amountError,
      errorAccountNumber: accountNumberError,
      errorPaymentMethod: paymentMethodError,
      errorActivity: activityError,
      isFormValid: isValid,
    );

    await Future.delayed(const Duration(milliseconds: 200));
    state = state.copyWith(loading: false);
  }

  // ===== Submission Methods =====

  /// Submits the finance record for standalone mode (API call).
  /// Returns true on success, false on validation failure or API error.
  /// Requirements: 4.4, 6.2
  Future<bool> submit() async {
    // Step 1: Validate form first
    await validateForm();

    // Step 2: If invalid, return false
    if (!state.isFormValid) {
      return false;
    }

    // Step 3: Set loading state
    state = state.copyWith(loading: true, errorMessage: null);

    try {
      // Get churchId from localStorage
      final localStorage = ref.read(localStorageServiceProvider);
      final membership = localStorage.currentMembership;

      if (membership == null || membership.church?.id == null) {
        state = state.copyWith(
          loading: false,
          errorMessage: 'Session expired. Please sign in again.',
        );
        return false;
      }

      final churchId = membership.church!.id!;
      final activityId = state.selectedActivity?.id;

      // Parse amount (remove formatting)
      final amount = int.parse(
        state.amount!.replaceAll('.', '').replaceAll(',', ''),
      );

      bool success = false;

      // Create revenue or expense based on financeType
      if (state.financeType == FinanceType.revenue) {
        final request = CreateRevenueRequest(
          accountNumber: state.accountNumber!.trim(),
          amount: amount,
          churchId: churchId,
          activityId: activityId,
          paymentMethod: state.paymentMethod!,
        );

        final revenueRepository = ref.read(revenueRepositoryProvider);
        final result = await revenueRepository.createRevenue(request: request);

        result.when(
          onSuccess: (_) {
            state = state.copyWith(
              loading: false,
              successMessage: 'Revenue created successfully',
            );
            success = true;
          },
          onFailure: (failure) {
            state = state.copyWith(
              loading: false,
              errorMessage: failure.message,
            );
            success = false;
          },
        );
      } else {
        final request = CreateExpenseRequest(
          accountNumber: state.accountNumber!.trim(),
          amount: amount,
          churchId: churchId,
          activityId: activityId,
          paymentMethod: state.paymentMethod!,
        );

        final expenseRepository = ref.read(expenseRepositoryProvider);
        final result = await expenseRepository.createExpense(request: request);

        result.when(
          onSuccess: (_) {
            state = state.copyWith(
              loading: false,
              successMessage: 'Expense created successfully',
            );
            success = true;
          },
          onFailure: (failure) {
            state = state.copyWith(
              loading: false,
              errorMessage: failure.message,
            );
            success = false;
          },
        );
      }

      return success;
    } catch (e) {
      state = state.copyWith(
        loading: false,
        errorMessage: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }

  /// Returns the finance data for embedded mode (without API call).
  /// Returns null if form is invalid.
  /// Requirements: 2.5, 3.5
  FinanceData? getFinanceData() {
    // Validate required fields
    if (state.amount == null ||
        state.accountNumber == null ||
        state.paymentMethod == null) {
      return null;
    }

    final amountError = validateAmount(state.amount);
    final accountNumberError = validateAccountNumber(state.accountNumber);
    final paymentMethodError = validatePaymentMethod(state.paymentMethod);

    if (amountError != null ||
        accountNumberError != null ||
        paymentMethodError != null) {
      return null;
    }

    // Parse amount (remove formatting)
    final amount = int.parse(
      state.amount!.replaceAll('.', '').replaceAll(',', ''),
    );

    return FinanceData(
      type: state.financeType,
      amount: amount,
      accountNumber: state.accountNumber!.trim(),
      paymentMethod: state.paymentMethod!,
    );
  }
}
