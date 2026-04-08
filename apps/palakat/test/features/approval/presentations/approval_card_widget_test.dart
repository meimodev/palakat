import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat/features/approval/presentations/widgets/approval_card_widget.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/widgets/loading_widget.dart';
import 'package:palakat_shared/l10n/generated/app_localizations.dart';
import 'package:palakat_shared/models.dart' hide Column;

/// Unit tests for ApprovalCardWidget
/// **Feature: approval-card-detail-redesign**
/// **Validates: Requirements 1.1, 1.2, 1.3, 2.1**
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApprovalCardWidget Tests', () {
    /// Test that card renders with correct elevation (1) for visual separation
    /// **Validates: Requirements 1.2**
    testWidgets('Card renders with elevation 1 for visual separation', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          ApprovalCardWidget(
            approval: _createTestActivity(),
            currentMembershipId: 1,
            onTap: () {},
            onApprove: () {},
            onReject: () {},
          ),
        ),
      );

      // Find the Material widget that is a descendant of ApprovalCardWidget
      final cardFinder = find.byType(ApprovalCardWidget);
      final materialFinder = find.descendant(
        of: cardFinder,
        matching: find.byType(Material),
      );
      expect(materialFinder, findsOneWidget);

      final materialWidget = tester.widget<Material>(materialFinder);
      expect(
        materialWidget.elevation,
        equals(1.0),
        reason: 'Card should have elevation 1 for subtle shadow',
      );
    });

    /// Test that card has rounded corners (12dp radius)
    /// **Validates: Requirements 1.3**
    testWidgets('Card has rounded corners with 12dp radius', (tester) async {
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          ApprovalCardWidget(
            approval: _createTestActivity(),
            currentMembershipId: 1,
            onTap: () {},
            onApprove: () {},
            onReject: () {},
          ),
        ),
      );

      // Find the Material widget that is a descendant of ApprovalCardWidget
      final cardFinder = find.byType(ApprovalCardWidget);
      final materialFinder = find.descendant(
        of: cardFinder,
        matching: find.byType(Material),
      );
      final materialWidget = tester.widget<Material>(materialFinder);

      expect(materialWidget.shape, isA<RoundedRectangleBorder>());
      final shape = materialWidget.shape as RoundedRectangleBorder;
      expect(
        shape.borderRadius,
        equals(BorderRadius.circular(12)),
        reason: 'Card should have 12dp border radius',
      );
    });

    /// Test that approver summary displays progress text
    testWidgets('Approver summary displays progress text', (tester) async {
      final activity = _createTestActivity(
        approvers: [
          _createTestApprover(
            id: 1,
            name: 'Approver One',
            status: ApprovalStatus.approved,
          ),
          _createTestApprover(
            id: 2,
            name: 'Approver Two',
            status: ApprovalStatus.unconfirmed,
          ),
        ],
      );

      await tester.pumpWidget(
        _wrapWithMaterialApp(
          ApprovalCardWidget(
            approval: activity,
            currentMembershipId: 3,
            onTap: () {},
            onApprove: () {},
            onReject: () {},
          ),
        ),
      );

      expect(
        find.text('1/2 Approved'),
        findsOneWidget,
        reason: 'Should display approved progress summary for approvers',
      );
    });

    /// Test that pending current approver shows both action buttons
    testWidgets('Pending current approver shows both action buttons', (
      tester,
    ) async {
      final activity = _createTestActivity(
        approvers: [
          _createTestApprover(
            id: 1,
            name: 'Current Approver',
            status: ApprovalStatus.unconfirmed,
          ),
          _createTestApprover(
            id: 2,
            name: 'Other Approver',
            status: ApprovalStatus.approved,
          ),
        ],
      );

      await tester.pumpWidget(
        _wrapWithMaterialApp(
          ApprovalCardWidget(
            approval: activity,
            currentMembershipId: 1,
            onTap: () {},
            onApprove: () {},
            onReject: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsNothing);
      expect(find.byType(InkWell), findsNWidgets(3));
    });

    /// Test that card is tappable
    testWidgets('Card responds to tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        _wrapWithMaterialApp(
          ApprovalCardWidget(
            approval: _createTestActivity(),
            currentMembershipId: 1,
            onTap: () => tapped = true,
            onApprove: () {},
            onReject: () {},
          ),
        ),
      );

      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      expect(tapped, isTrue, reason: 'Card should respond to tap');
    });

    /// Test that approve and reject taps are ignored while loading
    testWidgets('Approve and reject taps are ignored while loading', (
      tester,
    ) async {
      var approveTapCount = 0;
      var rejectTapCount = 0;

      final activity = _createTestActivity(
        approvers: [
          _createTestApprover(
            id: 1,
            name: 'Current Approver',
            status: ApprovalStatus.unconfirmed,
          ),
          _createTestApprover(
            id: 2,
            name: 'Other Approver',
            status: ApprovalStatus.approved,
          ),
        ],
      );

      await tester.pumpWidget(
        _wrapWithMaterialApp(
          ApprovalCardWidget(
            approval: activity,
            currentMembershipId: 1,
            onTap: () {},
            onApprove: () => approveTapCount++,
            onReject: () => rejectTapCount++,
            isLoading: true,
          ),
        ),
      );

      expect(find.byType(InkWell), findsNWidgets(3));
      expect(find.byType(CompactLoadingWidget), findsNWidgets(2));

      await tester.tap(find.byType(InkWell).at(1));
      await tester.pump();
      await tester.tap(find.byType(InkWell).at(2));
      await tester.pump();

      expect(rejectTapCount, 0);
      expect(approveTapCount, 0);
    });
  });
}

// ============================================================================
// Helper functions
// ============================================================================

/// Wraps a widget with MaterialApp and ScreenUtilInit for testing.
Widget _wrapWithMaterialApp(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    builder: (context, _) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

/// Creates a test Activity with default values.
Activity _createTestActivity({
  String title = 'Test Activity',
  List<Approver>? approvers,
}) {
  return Activity(
    id: 1,
    title: title,
    date: DateTime.now(),
    createdAt: DateTime.now(),
    supervisor: Membership(
      id: 1,
      account: Account(
        id: 1,
        name: 'Supervisor Name',
        phone: '1234567890',
        dob: DateTime(1990, 1, 1),
      ),
    ),
    approvers: approvers ?? [],
    activityType: ActivityType.service,
  );
}

/// Creates a test Approver with the given parameters.
Approver _createTestApprover({
  required int id,
  required String name,
  required ApprovalStatus status,
}) {
  return Approver(
    id: id,
    membershipId: id,
    membership: Membership(
      id: id,
      account: Account(
        id: id,
        name: name,
        phone: '1234567890',
        dob: DateTime(1990, 1, 1),
      ),
    ),
    status: status,
    updatedAt: DateTime.now(),
  );
}
