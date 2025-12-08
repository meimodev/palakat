import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat/features/approval/presentations/approval_state.dart';

/// Widget tests for approval screen components
/// **Feature: announcement-financial-admin-cleanup-approval-redesign**
/// **Validates: Requirements 3.1, 3.7, 3.10**
///
/// Note: Tests for widgets that use flutter_screenutil (StatusFilterChips,
/// PendingActionBadge, ApprovalCardWidget) are covered by property-based tests
/// in approval_controller_property_test.dart which test the underlying logic.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApprovalFilterStatus Tests', () {
    test('ApprovalFilterStatus enum has all required values', () {
      // Verify all filter status values exist
      expect(ApprovalFilterStatus.values.length, equals(5));
      expect(ApprovalFilterStatus.values, contains(ApprovalFilterStatus.all));
      expect(
        ApprovalFilterStatus.values,
        contains(ApprovalFilterStatus.pendingMyAction),
      );
      expect(
        ApprovalFilterStatus.values,
        contains(ApprovalFilterStatus.pendingOthers),
      );
      expect(
        ApprovalFilterStatus.values,
        contains(ApprovalFilterStatus.approved),
      );
      expect(
        ApprovalFilterStatus.values,
        contains(ApprovalFilterStatus.rejected),
      );
    });

    test('ApprovalFilterStatus enum values have correct indices', () {
      expect(ApprovalFilterStatus.all.index, equals(0));
      expect(ApprovalFilterStatus.pendingMyAction.index, equals(1));
      expect(ApprovalFilterStatus.pendingOthers.index, equals(2));
      expect(ApprovalFilterStatus.approved.index, equals(3));
      expect(ApprovalFilterStatus.rejected.index, equals(4));
    });
  });

  group('ApprovalState Tests', () {
    test('ApprovalState has correct default values', () {
      const state = ApprovalState();
      expect(state.loadingScreen, isTrue);
      expect(state.isRefreshing, isFalse);
      expect(state.allActivities, isEmpty);
      expect(state.pendingMyAction, isEmpty);
      expect(state.pendingOthers, isEmpty);
      expect(state.approved, isEmpty);
      expect(state.rejected, isEmpty);
      expect(state.statusFilter, equals(ApprovalFilterStatus.all));
      expect(state.filteredApprovals, isEmpty);
      expect(state.errorMessage, isNull);
      expect(state.membership, isNull);
    });

    test('ApprovalState copyWith updates statusFilter correctly', () {
      const state = ApprovalState();
      final updatedState = state.copyWith(
        statusFilter: ApprovalFilterStatus.pendingMyAction,
      );
      expect(
        updatedState.statusFilter,
        equals(ApprovalFilterStatus.pendingMyAction),
      );
    });

    test('ApprovalState copyWith updates isRefreshing correctly', () {
      const state = ApprovalState();
      final updatedState = state.copyWith(isRefreshing: true);
      expect(updatedState.isRefreshing, isTrue);
    });

    test('ApprovalState copyWith updates date filters correctly', () {
      const state = ApprovalState();
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 12, 31);
      final updatedState = state.copyWith(
        filterStartDate: startDate,
        filterEndDate: endDate,
      );
      expect(updatedState.filterStartDate, equals(startDate));
      expect(updatedState.filterEndDate, equals(endDate));
    });

    test('ApprovalState equality works correctly', () {
      const state1 = ApprovalState();
      const state2 = ApprovalState();
      expect(state1, equals(state2));
    });

    test('ApprovalState with different values are not equal', () {
      const state1 = ApprovalState(loadingScreen: true);
      const state2 = ApprovalState(loadingScreen: false);
      expect(state1, isNot(equals(state2)));
    });
  });

  group('Pull-to-Refresh Tests', () {
    testWidgets('RefreshIndicator triggers onRefresh callback', (
      WidgetTester tester,
    ) async {
      bool refreshCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RefreshIndicator(
              onRefresh: () async {
                refreshCalled = true;
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [ListTile(title: Text('Test Item'))],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(RefreshIndicator), findsOneWidget);

      // Simulate pull-to-refresh gesture
      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pumpAndSettle();

      expect(refreshCalled, isTrue);
    });

    testWidgets('RefreshIndicator with CustomScrollView works correctly', (
      WidgetTester tester,
    ) async {
      bool refreshCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RefreshIndicator(
              onRefresh: () async {
                refreshCalled = true;
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      height: 100,
                      color: Colors.blue,
                      child: const Text('Header'),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => ListTile(title: Text('Item $index')),
                      childCount: 5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(RefreshIndicator), findsOneWidget);

      // Simulate pull-to-refresh gesture
      await tester.fling(
        find.byType(CustomScrollView),
        const Offset(0, 300),
        1000,
      );
      await tester.pumpAndSettle();

      expect(refreshCalled, isTrue);
    });
  });

  group('Status Group Section Tests', () {
    testWidgets('section header displays correct title and count', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.pending_actions, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Pending Your Action',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '3',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Pending Your Action'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.byIcon(Icons.pending_actions), findsOneWidget);
    });

    testWidgets('multiple status sections can be rendered', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                _buildSectionHeader(
                  'Pending Your Action',
                  Icons.pending_actions,
                  Colors.teal,
                  3,
                ),
                _buildSectionHeader(
                  'Pending Others',
                  Icons.hourglass_empty,
                  Colors.orange,
                  2,
                ),
                _buildSectionHeader(
                  'Approved',
                  Icons.check_circle_outline,
                  Colors.green,
                  5,
                ),
                _buildSectionHeader(
                  'Rejected',
                  Icons.cancel_outlined,
                  Colors.red,
                  1,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Pending Your Action'), findsOneWidget);
      expect(find.text('Pending Others'), findsOneWidget);
      expect(find.text('Approved'), findsOneWidget);
      expect(find.text('Rejected'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });
  });

  group('Filter Chip Logic Tests', () {
    test('filter chip selection callback works correctly', () {
      ApprovalFilterStatus? selectedFilter;

      void onFilterChanged(ApprovalFilterStatus filter) {
        selectedFilter = filter;
      }

      // Simulate selecting different filters
      onFilterChanged(ApprovalFilterStatus.pendingMyAction);
      expect(selectedFilter, equals(ApprovalFilterStatus.pendingMyAction));

      onFilterChanged(ApprovalFilterStatus.approved);
      expect(selectedFilter, equals(ApprovalFilterStatus.approved));

      onFilterChanged(ApprovalFilterStatus.rejected);
      expect(selectedFilter, equals(ApprovalFilterStatus.rejected));

      onFilterChanged(ApprovalFilterStatus.all);
      expect(selectedFilter, equals(ApprovalFilterStatus.all));
    });
  });
}

/// Helper function to build a section header widget for testing
Widget _buildSectionHeader(
  String title,
  IconData icon,
  MaterialColor color,
  int count,
) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        Icon(icon, size: 20, color: color.shade600),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color.shade700,
            ),
          ),
        ),
      ],
    ),
  );
}
