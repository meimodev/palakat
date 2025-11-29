import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/activity.dart';
import 'package:palakat_shared/core/models/finance_type.dart';

part 'finance_create_state.freezed.dart';

/// State for the Finance Create Screen.
/// Handles both revenue and expense creation in standalone and embedded modes.
/// Requirements: 2.1, 3.1, 4.1, 6.1, 6.2
@freezed
abstract class FinanceCreateState with _$FinanceCreateState {
  const factory FinanceCreateState({
    /// The type of financial record (revenue or expense)
    required FinanceType financeType,

    /// Whether this is standalone mode (with activity picker) or embedded mode
    required bool isStandalone,

    // Form fields
    /// The amount as a string for input handling
    String? amount,

    /// The account number
    String? accountNumber,

    /// The selected payment method (CASH or CASHLESS)
    PaymentMethod? paymentMethod,

    /// The selected activity (only used in standalone mode)
    Activity? selectedActivity,

    // Error messages for form fields
    /// Error message for amount field
    String? errorAmount,

    /// Error message for account number field
    String? errorAccountNumber,

    /// Error message for payment method field
    String? errorPaymentMethod,

    /// Error message for activity picker field
    String? errorActivity,

    // UI state
    /// Whether the form is currently being submitted
    @Default(false) bool loading,

    /// Whether all form fields are valid
    @Default(false) bool isFormValid,

    /// General error message for submission failures
    String? errorMessage,

    /// Success message after successful submission
    String? successMessage,
  }) = _FinanceCreateState;
}
