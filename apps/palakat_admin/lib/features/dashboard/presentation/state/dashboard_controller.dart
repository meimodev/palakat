import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dashboard_screen_state.dart';

part 'dashboard_controller.g.dart';

@riverpod
class DashboardController extends _$DashboardController {
  @override
  DashboardScreenState build() {
    // Fetch data on initialization
    Future.microtask(() {
      fetchStats();
      fetchRecentActivities();
    });

    return const DashboardScreenState();
  }

  Future<void> fetchStats() async {
    try {
      state = state.copyWith(stats: const AsyncValue.loading());

      // Simulate API delay for realistic loading experience
      await Future.delayed(const Duration(seconds: 1));

      // TODO: Replace with actual API call when backend is ready
      final stats = DashboardStats(
        totalMembers: 1234,
        membersChange: 20,
        totalRevenue: 45231.89,
        revenueChange: 12.5,
        totalExpense: 12789.45,
        expenseChange: 8.1,
      );

      state = state.copyWith(stats: AsyncValue.data(stats));
    } catch (e, st) {
      state = state.copyWith(stats: AsyncValue.error(e, st));
    }
  }

  Future<void> fetchRecentActivities() async {
    try {
      state = state.copyWith(recentActivities: const AsyncValue.loading());

      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 800));

      // TODO: Replace with actual API call when backend is ready
      final now = DateTime.now();
      final activities = [
        RecentActivity(
          id: '1',
          title: 'New Member Registered',
          description: 'John Doe joined the congregation',
          type: ActivityType.member,
          timestamp: now.subtract(const Duration(hours: 2)),
        ),
        RecentActivity(
          id: '2',
          title: 'Donation Received',
          description: 'Tithes and offerings collected',
          type: ActivityType.transaction,
          timestamp: now.subtract(const Duration(hours: 5)),
          amount: '\$1,250.00',
        ),
        RecentActivity(
          id: '3',
          title: 'Event Approved',
          description: 'Youth Fellowship meeting scheduled',
          type: ActivityType.approval,
          timestamp: now.subtract(const Duration(days: 1)),
        ),
        RecentActivity(
          id: '4',
          title: 'Expense Recorded',
          description: 'Utility bills payment',
          type: ActivityType.transaction,
          timestamp: now.subtract(const Duration(days: 3)),
          amount: '\$450.00',
        ),
      ];

      state = state.copyWith(recentActivities: AsyncValue.data(activities));
    } catch (e, st) {
      state = state.copyWith(recentActivities: AsyncValue.error(e, st));
    }
  }

  void refresh() {
    fetchStats();
    fetchRecentActivities();
  }
}
