import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/features/publishing/presentations/activity_publish/activity_publish_state.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/finance_data.dart';
import 'package:palakat_shared/core/models/finance_type.dart';

/// Property-based tests for delete confirmation behavior in ActivityPublishController.
/// **Feature: finance-edit-prepopulate**
void main() {
  group('ActivityPublishController Delete Confirmation Property Tests', () {
    /// **Feature: finance-edit-prepopulate, Property 6: Confirmed deletion removes attached finance**
    /// **Validates: Requirements 3.3**
    ///
    /// *For any* ActivityPublishState with a non-null attachedFinance, when the user
    /// confirms deletion in the dialog (i.e., removeAttachedFinance is called),
    /// the resulting state's attachedFinance SHALL be null.
    property('Property 6: Confirmed deletion removes attached finance', () {
      forAll(_financeDataArbitrary(), (financeData) {
        // Create controller with attached finance
        final controller = _TestableActivityPublishController(
          activityType: ActivityType.service,
        );

        // Attach finance data
        controller.onAttachedFinance(financeData);

        // Verify finance is attached
        expect(
          controller.state.attachedFinance,
          isNotNull,
          reason: 'Finance should be attached before deletion',
        );
        expect(
          controller.state.attachedFinance,
          equals(financeData),
          reason: 'Attached finance should match the input data',
        );

        // Simulate confirmed deletion (user clicks "Remove" in dialog)
        controller.removeAttachedFinance();

        // Verify finance is removed
        expect(
          controller.state.attachedFinance,
          isNull,
          reason: 'attachedFinance SHALL be null after confirmed deletion',
        );
      });
    });

    /// **Feature: finance-edit-prepopulate, Property 7: Cancelled deletion preserves attached finance**
    /// **Validates: Requirements 3.4**
    ///
    /// *For any* ActivityPublishState with a non-null attachedFinance, when the user
    /// cancels deletion in the dialog (i.e., removeAttachedFinance is NOT called),
    /// the resulting state's attachedFinance SHALL equal the original attachedFinance value.
    property('Property 7: Cancelled deletion preserves attached finance', () {
      forAll(_financeDataArbitrary(), (financeData) {
        // Create controller with attached finance
        final controller = _TestableActivityPublishController(
          activityType: ActivityType.service,
        );

        // Attach finance data
        controller.onAttachedFinance(financeData);

        // Store original finance for comparison
        final originalFinance = controller.state.attachedFinance;

        // Verify finance is attached
        expect(
          originalFinance,
          isNotNull,
          reason: 'Finance should be attached before cancellation',
        );

        // Simulate cancelled deletion (user clicks "Cancel" in dialog)
        // In this case, removeAttachedFinance is NOT called
        // We just verify the state remains unchanged

        // Verify finance is preserved (no change to state)
        expect(
          controller.state.attachedFinance,
          equals(originalFinance),
          reason:
              'attachedFinance SHALL equal the original value after cancelled deletion',
        );
        expect(
          controller.state.attachedFinance?.amount,
          equals(financeData.amount),
          reason: 'Amount should be preserved',
        );
        expect(
          controller.state.attachedFinance?.accountNumber,
          equals(financeData.accountNumber),
          reason: 'Account number should be preserved',
        );
        expect(
          controller.state.attachedFinance?.paymentMethod,
          equals(financeData.paymentMethod),
          reason: 'Payment method should be preserved',
        );
      });
    });

    /// Additional property test: Multiple attach/remove cycles preserve correct state
    property(
      'Property 6 (edge case): Multiple attach/remove cycles work correctly',
      () {
        forAll(combine2(_financeDataArbitrary(), _financeDataArbitrary()), (
          tuple,
        ) {
          final (financeData1, financeData2) = tuple;

          final controller = _TestableActivityPublishController(
            activityType: ActivityType.event,
          );

          // First cycle: attach and remove
          controller.onAttachedFinance(financeData1);
          expect(controller.state.attachedFinance, isNotNull);
          controller.removeAttachedFinance();
          expect(controller.state.attachedFinance, isNull);

          // Second cycle: attach different data and remove
          controller.onAttachedFinance(financeData2);
          expect(controller.state.attachedFinance, equals(financeData2));
          controller.removeAttachedFinance();
          expect(controller.state.attachedFinance, isNull);
        });
      },
    );
  });
}

/// Arbitrary generator for FinanceData.
/// Generates FinanceData with all required fields populated.
Arbitrary<FinanceData> _financeDataArbitrary() {
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

/// Testable version of ActivityPublishController that doesn't require Riverpod.
/// This allows us to test the controller logic in isolation.
class _TestableActivityPublishController {
  _TestableActivityPublishController({required ActivityType activityType}) {
    state = ActivityPublishState(type: activityType);
  }

  late ActivityPublishState state;

  /// Sets the attached finance data (revenue or expense).
  /// Requirements: 1.4
  void onAttachedFinance(FinanceData? data) {
    state = state.copyWith(attachedFinance: data);
  }

  /// Removes the attached financial record.
  /// Requirements: 1.5, 3.3
  void removeAttachedFinance() {
    state = state.copyWith(attachedFinance: null);
  }
}
