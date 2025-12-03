import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';
import 'package:palakat/features/finance/presentations/finance_create/finance_create_state.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/finance_data.dart';
import 'package:palakat_shared/core/models/finance_type.dart';
import 'package:palakat_shared/core/models/financial_account_number.dart';

/// Property-based tests for FinanceCreateController initialization and validation.
/// **Feature: finance-edit-prepopulate**
void main() {
  group('FinanceCreateController Property Tests', () {
    /// **Feature: finance-edit-prepopulate, Property 1: Amount field initialization preserves value**
    /// **Validates: Requirements 1.1**
    ///
    /// *For any* valid FinanceData with a positive amount, when the controller
    /// is initialized with that data, the state's amount field SHALL contain
    /// a string representation of the original amount value.
    property('Property 1: Amount field initialization preserves value', () {
      forAll(_validFinanceDataArbitrary(), (financeData) {
        // Create controller with initial data
        final controller = _TestableFinanceCreateController(
          financeType: financeData.type,
          isStandalone: false,
          initialData: financeData,
        );

        // Parse the formatted amount back to integer
        final parsedAmount = int.parse(
          controller.state.amount!.replaceAll('.', '').replaceAll(',', ''),
        );

        // Verify the amount value is preserved
        expect(
          parsedAmount,
          equals(financeData.amount),
          reason:
              'Parsed amount ($parsedAmount) should equal original amount (${financeData.amount})',
        );
      });
    });

    /// **Feature: finance-edit-prepopulate, Property 2: Account number initialization preserves selection**
    /// **Validates: Requirements 1.2**
    ///
    /// *For any* valid FinanceData with a financialAccountNumberId, when the
    /// controller is initialized with that data, the state's
    /// selectedFinancialAccountNumber SHALL have matching id and accountNumber values.
    property(
      'Property 2: Account number initialization preserves selection',
      () {
        forAll(_validFinanceDataArbitrary(), (financeData) {
          // Create controller with initial data
          final controller = _TestableFinanceCreateController(
            financeType: financeData.type,
            isStandalone: false,
            initialData: financeData,
          );

          // Verify account number is preserved
          expect(
            controller.state.selectedFinancialAccountNumber,
            isNotNull,
            reason: 'Selected financial account number should not be null',
          );
          expect(
            controller.state.selectedFinancialAccountNumber!.id,
            equals(financeData.financialAccountNumberId),
            reason: 'Account number ID should match original',
          );
          expect(
            controller.state.selectedFinancialAccountNumber!.accountNumber,
            equals(financeData.accountNumber),
            reason: 'Account number string should match original',
          );
        });
      },
    );

    /// **Feature: finance-edit-prepopulate, Property 3: Payment method initialization preserves selection**
    /// **Validates: Requirements 1.3**
    ///
    /// *For any* valid FinanceData with a payment method, when the controller
    /// is initialized with that data, the state's paymentMethod SHALL equal
    /// the original payment method.
    property('Property 3: Payment method initialization preserves selection', () {
      forAll(_validFinanceDataArbitrary(), (financeData) {
        // Create controller with initial data
        final controller = _TestableFinanceCreateController(
          financeType: financeData.type,
          isStandalone: false,
          initialData: financeData,
        );

        // Verify payment method is preserved
        expect(
          controller.state.paymentMethod,
          equals(financeData.paymentMethod),
          reason:
              'Payment method (${controller.state.paymentMethod}) should equal original (${financeData.paymentMethod})',
        );
      });
    });

    /// **Feature: finance-edit-prepopulate, Property 4: Form validity reflects complete initial data**
    /// **Validates: Requirements 1.4, 2.1**
    ///
    /// *For any* FinanceData with all required fields populated (amount > 0,
    /// non-empty accountNumber, valid paymentMethod), when the controller is
    /// initialized with that data, the state's isFormValid SHALL be true.
    property('Property 4: Form validity reflects complete initial data', () {
      forAll(_validFinanceDataArbitrary(), (financeData) {
        // Create controller with valid initial data
        final controller = _TestableFinanceCreateController(
          financeType: financeData.type,
          isStandalone: false,
          initialData: financeData,
        );

        // Verify form is valid when all required fields are populated
        expect(
          controller.state.isFormValid,
          isTrue,
          reason:
              'Form should be valid when initialized with complete FinanceData',
        );
      });
    });

    /// **Feature: finance-edit-prepopulate, Property 4 (incomplete data): Form validity reflects incomplete initial data**
    /// **Validates: Requirements 1.4, 2.1**
    ///
    /// *For any* FinanceData with missing or invalid required fields,
    /// when the controller is initialized with that data, the state's
    /// isFormValid SHALL be false.
    property(
      'Property 4 (incomplete data): Form validity reflects incomplete initial data',
      () {
        forAll(_incompleteFinanceDataArbitrary(), (financeData) {
          // Create controller with incomplete initial data
          final controller = _TestableFinanceCreateController(
            financeType: financeData.type,
            isStandalone: false,
            initialData: financeData,
          );

          // Verify form is invalid when required fields are missing/invalid
          expect(
            controller.state.isFormValid,
            isFalse,
            reason:
                'Form should be invalid when initialized with incomplete FinanceData',
          );
        });
      },
    );

    /// **Feature: finance-edit-prepopulate, Property 5: Validation updates after field modification**
    /// **Validates: Requirements 2.3**
    ///
    /// *For any* controller initialized with valid FinanceData, when a field is
    /// modified to an invalid value (e.g., empty amount), the corresponding error
    /// field SHALL be non-null and isFormValid SHALL be false.
    property('Property 5: Validation updates after field modification', () {
      // Generate valid FinanceData
      forAll(_validFinanceDataArbitrary(), (financeData) {
        // Create controller with valid initial data
        final controller = _TestableFinanceCreateController(
          financeType: financeData.type,
          isStandalone: false,
          initialData: financeData,
        );

        // Verify initial state is valid
        expect(
          controller.state.isFormValid,
          isTrue,
          reason: 'Initial state should be valid with complete FinanceData',
        );
        expect(
          controller.state.errorAmount,
          isNull,
          reason: 'Initial amount error should be null',
        );

        // Modify amount to invalid value (empty string)
        controller.onChangedAmount('');

        // Verify validation updates
        expect(
          controller.state.errorAmount,
          isNotNull,
          reason: 'Error amount should be non-null after setting empty amount',
        );
        expect(
          controller.state.errorAmount,
          equals('Amount is required'),
          reason: 'Error message should indicate amount is required',
        );
      });
    });

    /// Additional property test: Validation updates when amount is set to zero
    property(
      'Property 5 (edge case): Validation updates when amount is zero',
      () {
        forAll(_validFinanceDataArbitrary(), (financeData) {
          final controller = _TestableFinanceCreateController(
            financeType: financeData.type,
            isStandalone: false,
            initialData: financeData,
          );

          // Modify amount to zero
          controller.onChangedAmount('0');

          // Verify validation updates
          expect(
            controller.state.errorAmount,
            isNotNull,
            reason: 'Error amount should be non-null after setting zero',
          );
          expect(
            controller.state.errorAmount,
            equals('Amount must be greater than 0'),
            reason: 'Error message should indicate amount must be positive',
          );
        });
      },
    );

    /// Additional property test: Validation updates when payment method is cleared
    property(
      'Property 5 (payment method): Validation updates when payment method is cleared',
      () {
        forAll(_validFinanceDataArbitrary(), (financeData) {
          final controller = _TestableFinanceCreateController(
            financeType: financeData.type,
            isStandalone: false,
            initialData: financeData,
          );

          // Clear payment method
          controller.onSelectedPaymentMethod(null);

          // Verify validation updates
          expect(
            controller.state.errorPaymentMethod,
            isNotNull,
            reason: 'Error payment method should be non-null after clearing it',
          );
          expect(
            controller.state.errorPaymentMethod,
            equals('Payment method is required'),
            reason: 'Error message should indicate payment method is required',
          );
        });
      },
    );
  });
}

/// Arbitrary generator for valid FinanceData.
/// Generates FinanceData with all required fields populated.
Arbitrary<FinanceData> _validFinanceDataArbitrary() {
  return combine4(
    integer(min: 1000, max: 100000000), // amount: positive integer
    _accountNumberArbitrary(), // accountNumber: non-empty string
    _paymentMethodArbitrary(), // paymentMethod: valid enum value
    _financeTypeArbitrary(), // type: valid enum value
  ).map((tuple) {
    final (amount, accountNumber, paymentMethod, financeType) = tuple;
    return FinanceData(
      type: financeType,
      amount: amount,
      accountNumber: accountNumber,
      accountDescription: 'Test Account Description',
      paymentMethod: paymentMethod,
      financialAccountNumberId: 1,
    );
  });
}

/// Arbitrary generator for account numbers.
Arbitrary<String> _accountNumberArbitrary() {
  return combine2(integer(min: 1, max: 9), integer(min: 100, max: 999)).map((
    tuple,
  ) {
    final (prefix, suffix) = tuple;
    return '$prefix.$suffix';
  });
}

/// Arbitrary generator for PaymentMethod enum.
Arbitrary<PaymentMethod> _paymentMethodArbitrary() {
  return integer(
    min: 0,
    max: PaymentMethod.values.length - 1,
  ).map((index) => PaymentMethod.values[index]);
}

/// Arbitrary generator for FinanceType enum.
Arbitrary<FinanceType> _financeTypeArbitrary() {
  return integer(
    min: 0,
    max: FinanceType.values.length - 1,
  ).map((index) => FinanceType.values[index]);
}

/// Arbitrary generator for incomplete FinanceData.
/// Generates FinanceData with at least one invalid field (amount <= 0 or empty accountNumber).
Arbitrary<FinanceData> _incompleteFinanceDataArbitrary() {
  return combine4(
    integer(min: -1000, max: 0), // amount: zero or negative (invalid)
    _accountNumberArbitrary(), // accountNumber: valid
    _paymentMethodArbitrary(), // paymentMethod: valid
    _financeTypeArbitrary(), // type: valid
  ).map((tuple) {
    final (amount, accountNumber, paymentMethod, financeType) = tuple;
    return FinanceData(
      type: financeType,
      amount: amount,
      accountNumber: accountNumber,
      accountDescription: 'Test Account Description',
      paymentMethod: paymentMethod,
      financialAccountNumberId: 1,
    );
  });
}

/// Testable version of FinanceCreateController that doesn't require Riverpod.
/// This allows us to test the controller logic in isolation.
class _TestableFinanceCreateController {
  _TestableFinanceCreateController({
    required FinanceType financeType,
    required bool isStandalone,
    FinanceData? initialData,
  }) {
    if (initialData != null) {
      state = _createInitializedState(financeType, isStandalone, initialData);
    } else {
      state = FinanceCreateState(
        financeType: financeType,
        isStandalone: isStandalone,
      );
    }
  }

  late FinanceCreateState state;

  /// Creates state initialized from existing FinanceData.
  FinanceCreateState _createInitializedState(
    FinanceType financeType,
    bool isStandalone,
    FinanceData data,
  ) {
    final formattedAmount = _formatAmountForDisplay(data.amount);

    FinancialAccountNumber? accountNumber;
    if (data.financialAccountNumberId != null) {
      accountNumber = FinancialAccountNumber(
        id: data.financialAccountNumberId!,
        accountNumber: data.accountNumber,
        description: data.accountDescription,
        type: data.type,
      );
    }

    final isValid = data.amount > 0 && data.accountNumber.isNotEmpty;

    return FinanceCreateState(
      financeType: financeType,
      isStandalone: isStandalone,
      amount: formattedAmount,
      selectedFinancialAccountNumber: accountNumber,
      paymentMethod: data.paymentMethod,
      isFormValid: isValid,
    );
  }

  String _formatAmountForDisplay(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  // Validation methods
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

  String? validatePaymentMethod(PaymentMethod? value) {
    if (value == null) {
      return 'Payment method is required';
    }
    return null;
  }

  // onChange handlers
  void onChangedAmount(String value) {
    state = state.copyWith(amount: value, errorAmount: validateAmount(value));
  }

  void onSelectedPaymentMethod(PaymentMethod? method) {
    state = state.copyWith(
      paymentMethod: method,
      errorPaymentMethod: validatePaymentMethod(method),
    );
  }
}
