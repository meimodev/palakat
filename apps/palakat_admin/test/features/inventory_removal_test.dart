import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_admin/features/dashboard/presentation/state/dashboard_screen_state.dart';

/// Tests to verify inventory feature has been completely removed from the admin panel.
/// These tests validate Requirements 2.1, 2.3, 2.4, 2.5.
void main() {
  group('Inventory Removal Verification', () {
    group('Dashboard State', () {
      test('DashboardStats does not include inventory fields', () {
        // Verify DashboardStats can be created without inventory fields
        const stats = DashboardStats(
          totalMembers: 100,
          membersChange: 5,
          totalRevenue: 1000.0,
          revenueChange: 10.0,
          totalExpense: 500.0,
          expenseChange: 5.0,
        );

        // Verify the stats object is created successfully
        expect(stats.totalMembers, 100);
        expect(stats.totalRevenue, 1000.0);
        expect(stats.totalExpense, 500.0);
      });

      test('ActivityType enum does not include inventory', () {
        // Verify ActivityType enum values
        final activityTypes = ActivityType.values;

        // Should have 4 types: member, transaction, approval, event
        expect(activityTypes.length, 4);
        expect(activityTypes.contains(ActivityType.member), true);
        expect(activityTypes.contains(ActivityType.transaction), true);
        expect(activityTypes.contains(ActivityType.approval), true);
        expect(activityTypes.contains(ActivityType.event), true);

        // Verify inventory is not in the enum by checking all values
        for (final type in activityTypes) {
          expect(type.name, isNot('inventory'));
        }
      });
    });
  });
}
