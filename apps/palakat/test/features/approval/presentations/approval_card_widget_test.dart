import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat/features/approval/presentations/widgets/approval_card_widget.dart';
import 'package:palakat/features/approval/presentations/widgets/approver_chip.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/models.dart' hide Column;

/// Unit tests for ApprovalCardWidget
/// **Feature: approval-card-detail-redesign**
/// **Validates: Requirements 1.1, 1.2, 1.3, 2.1**
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApprovalCardWidget Tests', () {
    /// Test that card renders with correct elevation (2) for visual separation
    /// **Validates: Requirements 1.2**
    testWidgets('Card renders with elevation 2 for visual separation', (
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
        equals(2.0),
        reason: 'Card should have elevation 2 for subtle shadow',
      );
    });

    /// Test that card has rounded corners (16dp radius)
    /// **Validates: Requirements 1.3**
    testWidgets('Card has rounded corners with 16dp radius', (tester) async {
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
        equals(BorderRadius.circular(16)),
        reason: 'Card should have 16dp border radius',
      );
    });

    /// Test that approver list uses ApproverChip (redesigned without backgrounds)
    /// **Validates: Requirements 2.1**
    testWidgets('Approver list displays using ApproverChip widgets', (
      tester,
    ) async {
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

      // Verify ApproverChip widgets are used for displaying approvers
      final approverChipFinder = find.byType(ApproverChip);
      expect(
        approverChipFinder,
        findsNWidgets(2),
        reason: 'Should display 2 ApproverChip widgets for 2 approvers',
      );
    });

    /// Test that approver names are displayed without colored backgrounds
    /// **Validates: Requirements 2.1**
    testWidgets(
      'Approver names display without colored background containers',
      (tester) async {
        final activity = _createTestActivity(
          approvers: [
            _createTestApprover(
              id: 1,
              name: 'Test Approver',
              status: ApprovalStatus.approved,
            ),
          ],
        );

        await tester.pumpWidget(
          _wrapWithMaterialApp(
            ApprovalCardWidget(
              approval: activity,
              currentMembershipId: 2,
              onTap: () {},
              onApprove: () {},
              onReject: () {},
            ),
          ),
        );

        // Find ApproverChip widget
        final approverChipFinder = find.byType(ApproverChip);
        expect(approverChipFinder, findsOneWidget);

        // Verify no Container with colored BoxDecoration inside ApproverChip
        final containerFinder = find.descendant(
          of: approverChipFinder,
          matching: find.byType(Container),
        );

        for (final element in tester.widgetList<Container>(containerFinder)) {
          final decoration = element.decoration;
          if (decoration is BoxDecoration && decoration.color != null) {
            expect(
              decoration.color!.a,
              equals(0.0),
              reason: 'ApproverChip should not have colored background',
            );
          }
        }
      },
    );

    /// Test that card displays activity title
    testWidgets('Card displays activity title', (tester) async {
      const testTitle = 'Test Activity Title';
      final activity = _createTestActivity(title: testTitle);

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

      expect(find.text(testTitle), findsOneWidget);
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
