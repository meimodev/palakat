import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_screen_state.freezed.dart';

@freezed
abstract class DashboardScreenState with _$DashboardScreenState {
  const factory DashboardScreenState({
    @Default(AsyncValue.loading()) AsyncValue<DashboardStats> stats,
    @Default(AsyncValue.loading()) AsyncValue<List<RecentActivity>> recentActivities,
  }) = _DashboardScreenState;
}

@freezed
abstract class DashboardStats with _$DashboardStats {
  const factory DashboardStats({
    @Default(0) int totalMembers,
    @Default(0) int membersChange,
    @Default(0.0) double totalRevenue,
    @Default(0.0) double revenueChange,
    @Default(0.0) double totalExpense,
    @Default(0.0) double expenseChange,
    @Default(0) int lowStockItems,
    String? inventoryStatus,
  }) = _DashboardStats;
}

@freezed
abstract class RecentActivity with _$RecentActivity {
  const factory RecentActivity({
    required String id,
    required String title,
    required String description,
    required ActivityType type,
    required DateTime timestamp,
    String? amount,
  }) = _RecentActivity;
}

enum ActivityType {
  member,
  transaction,
  inventory,
  approval,
  event
}
