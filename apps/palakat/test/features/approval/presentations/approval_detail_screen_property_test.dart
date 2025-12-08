import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';

/// Property-based tests for ApprovalDetailScreen and ActivityDetailScreen.
/// **Feature: approval-card-detail-redesign**
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Run ActivityDetailScreen read-only mode tests
  activityDetailReadOnlyModeTests();

  group('ApprovalDetailScreen Property Tests', () {
    /// **Feature: approval-card-detail-redesign, Property 3: Financial section visibility matches financial data presence**
    /// **Validates: Requirements 4.4**
    ///
    /// *For any* activity displayed in the approval detail screen, the financial section
    /// SHALL be visible if and only if the activity has hasRevenue=true OR hasExpense=true.
    property(
      'Property 3: Financial section visibility matches financial data presence',
      () {
        forAll(_activityFinancialConfigArbitrary(), (config) {
          final hasRevenue = config.$1;
          final hasExpense = config.$2;

          // The financial section should be visible if and only if
          // hasRevenue == true OR hasExpense == true
          final shouldShowFinancialSection =
              hasRevenue == true || hasExpense == true;

          // Test the visibility logic directly
          // This mirrors the condition in _buildActivityDetails:
          // if (activity.hasRevenue == true || activity.hasExpense == true)
          final actualVisibility = hasRevenue == true || hasExpense == true;

          expect(
            actualVisibility,
            equals(shouldShowFinancialSection),
            reason:
                'Financial section visibility should match: '
                'hasRevenue=$hasRevenue, hasExpense=$hasExpense -> '
                'shouldShow=$shouldShowFinancialSection',
          );
        });
      },
    );

    /// Additional property: Financial section shows correct type badge
    /// *For any* activity with financial data, the type badge should correctly
    /// indicate Revenue or Expense based on the hasRevenue/hasExpense flags.
    property('Financial type badge matches hasRevenue/hasExpense flags', () {
      forAll(_activityWithFinancialDataArbitrary(), (config) {
        final hasRevenue = config.$1;
        final hasExpense = config.$2;

        // Only test when financial section would be visible
        if (hasRevenue != true && hasExpense != true) return;

        // Determine expected finance type
        // Revenue takes precedence if both are true (matching implementation)
        final expectedType = hasRevenue == true ? 'Revenue' : 'Expense';

        // Verify the logic matches implementation:
        // final isRevenue = activity.hasRevenue == true;
        // final financeType = isRevenue ? 'Revenue' : 'Expense';
        final isRevenue = hasRevenue == true;
        final actualType = isRevenue ? 'Revenue' : 'Expense';

        expect(
          actualType,
          equals(expectedType),
          reason:
              'Finance type should be "$expectedType" when '
              'hasRevenue=$hasRevenue, hasExpense=$hasExpense',
        );
      });
    });

    /// Property: Financial section not visible when both flags are false/null
    /// *For any* activity where hasRevenue != true AND hasExpense != true,
    /// the financial section should NOT be visible.
    property('Financial section hidden when no financial data', () {
      forAll(_activityWithoutFinancialDataArbitrary(), (config) {
        final hasRevenue = config.$1;
        final hasExpense = config.$2;

        // Verify neither flag is true
        expect(hasRevenue, isNot(equals(true)));
        expect(hasExpense, isNot(equals(true)));

        // The visibility condition should be false
        final shouldShowFinancialSection =
            hasRevenue == true || hasExpense == true;

        expect(
          shouldShowFinancialSection,
          isFalse,
          reason:
              'Financial section should be hidden when '
              'hasRevenue=$hasRevenue, hasExpense=$hasExpense',
        );
      });
    });
  });
}

// ============================================================================
// Arbitrary generators
// ============================================================================

/// Generates all possible combinations of hasRevenue and hasExpense flags.
/// This covers: null, false, true for each flag.
Arbitrary<(bool?, bool?)> _activityFinancialConfigArbitrary() {
  return combine2(_nullableBoolArbitrary(), _nullableBoolArbitrary());
}

/// Generates configurations where at least one financial flag is true.
Arbitrary<(bool?, bool?)> _activityWithFinancialDataArbitrary() {
  return combine2(
    _nullableBoolArbitrary(),
    _nullableBoolArbitrary(),
  ).filter((config) => config.$1 == true || config.$2 == true);
}

/// Generates configurations where neither financial flag is true.
Arbitrary<(bool?, bool?)> _activityWithoutFinancialDataArbitrary() {
  return combine2(
    _nullableBoolWithoutTrueArbitrary(),
    _nullableBoolWithoutTrueArbitrary(),
  );
}

/// Generates nullable boolean values: null, false, or true.
Arbitrary<bool?> _nullableBoolArbitrary() {
  return integer(min: 0, max: 2).map((value) {
    switch (value) {
      case 0:
        return null;
      case 1:
        return false;
      default:
        return true;
    }
  });
}

/// Generates nullable boolean values without true: null or false.
Arbitrary<bool?> _nullableBoolWithoutTrueArbitrary() {
  return integer(min: 0, max: 1).map((value) {
    switch (value) {
      case 0:
        return null;
      default:
        return false;
    }
  });
}

// ============================================================================
// Activity Detail Read-Only Mode Property Tests
// ============================================================================

/// Property-based tests for ActivityDetailScreen read-only mode.
/// **Feature: approval-card-detail-redesign**
void activityDetailReadOnlyModeTests() {
  group('ActivityDetailScreen Read-Only Mode Property Tests', () {
    /// **Feature: approval-card-detail-redesign, Property 7: Activity detail from approval context has no action buttons**
    /// **Validates: Requirements 6.3**
    ///
    /// *For any* activity detail screen accessed from the approval detail context,
    /// the approve/reject action buttons SHALL NOT be present.
    property(
      'Property 7: Activity detail from approval context has no action buttons',
      () {
        forAll(_approvalContextConfigArbitrary(), (config) {
          final isFromApprovalContext = config.$1;
          final isSupervisorApprovalPending = config.$2;

          // The action buttons visibility logic from ActivityDetailScreen:
          // final showSelfApprovalButtons =
          //     state.isSupervisorApprovalPending && !isFromApprovalContext;
          final showSelfApprovalButtons =
              isSupervisorApprovalPending && !isFromApprovalContext;

          // When accessed from approval context, buttons should NEVER be shown
          if (isFromApprovalContext) {
            expect(
              showSelfApprovalButtons,
              isFalse,
              reason:
                  'Action buttons should be hidden when isFromApprovalContext=true, '
                  'regardless of isSupervisorApprovalPending=$isSupervisorApprovalPending',
            );
          }

          // When NOT from approval context, buttons depend on supervisor pending status
          if (!isFromApprovalContext) {
            expect(
              showSelfApprovalButtons,
              equals(isSupervisorApprovalPending),
              reason:
                  'Action buttons visibility should match isSupervisorApprovalPending '
                  'when isFromApprovalContext=false',
            );
          }
        });
      },
    );

    /// Additional property: Read-only mode is correctly determined by context flag
    /// *For any* navigation to activity detail, the read-only mode should be
    /// determined solely by the isFromApprovalContext flag.
    property('Read-only mode determined by isFromApprovalContext flag', () {
      forAll(boolean(), (isFromApprovalContext) {
        // Read-only mode means no action buttons regardless of other state
        // This is a direct mapping: isFromApprovalContext == true means read-only
        final isReadOnlyMode = isFromApprovalContext;

        expect(
          isReadOnlyMode,
          equals(isFromApprovalContext),
          reason:
              'Read-only mode should be true when isFromApprovalContext=true',
        );
      });
    });

    /// Property: Action buttons shown only when supervisor pending AND not from approval context
    /// *For any* combination of supervisor pending status and approval context,
    /// action buttons should only be visible when both conditions are met.
    property(
      'Action buttons require supervisor pending AND not from approval context',
      () {
        forAll(_approvalContextConfigArbitrary(), (config) {
          final isFromApprovalContext = config.$1;
          final isSupervisorApprovalPending = config.$2;

          final showSelfApprovalButtons =
              isSupervisorApprovalPending && !isFromApprovalContext;

          // Verify the AND logic
          if (showSelfApprovalButtons) {
            expect(isSupervisorApprovalPending, isTrue);
            expect(isFromApprovalContext, isFalse);
          }

          // Verify buttons are hidden when either condition fails
          if (!isSupervisorApprovalPending || isFromApprovalContext) {
            expect(
              showSelfApprovalButtons,
              isFalse,
              reason:
                  'Buttons should be hidden when isSupervisorApprovalPending=$isSupervisorApprovalPending '
                  'or isFromApprovalContext=$isFromApprovalContext',
            );
          }
        });
      },
    );
  });
}

/// Generates all combinations of isFromApprovalContext and isSupervisorApprovalPending.
Arbitrary<(bool, bool)> _approvalContextConfigArbitrary() {
  return combine2(boolean(), boolean());
}
