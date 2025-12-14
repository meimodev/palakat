import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column, ActivityType;

import '../state/dashboard_controller.dart';
import '../state/dashboard_screen_state.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(dashboardControllerProvider);
    final controller = ref.read(dashboardControllerProvider.notifier);

    final l10n = context.l10n;

    return Material(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and subtitle
            Text(l10n.dashboard_title, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(
              l10n.dashboard_subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Grid of 4 stat cards
            state.stats.when(
              loading: () => Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (int i = 0; i < 4; i++)
                    LoadingShimmer(
                      child: Container(
                        width: 280,
                        height: 120,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShimmerPlaceholders.text(width: 100, height: 14),
                              const SizedBox(height: 10),
                              ShimmerPlaceholders.text(width: 150, height: 24),
                              const SizedBox(height: 8),
                              ShimmerPlaceholders.text(width: 120, height: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              error: (e, st) => Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.err_loadFailed,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: controller.fetchStats,
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.btn_retry),
                    ),
                  ],
                ),
              ),
              data: (stats) => Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _StatCard(
                    title: l10n.dashboard_totalMembers,
                    value: NumberFormat('#,###').format(stats.totalMembers),
                    icon: Icons.groups_outlined,
                    change: l10n.stat_changeFromLastMonth(stats.membersChange.toString()),
                  ),
                  _StatCard(
                    title: l10n.dashboard_totalRevenue,
                    value:
                        '\$${NumberFormat('#,##0.00').format(stats.totalRevenue)}',
                    icon: Icons.attach_money,
                    change: l10n.stat_changePercentFromLastMonth(stats.revenueChange.toString()),
                  ),
                  _StatCard(
                    title: l10n.dashboard_totalExpense,
                    value:
                        '\$${NumberFormat('#,##0.00').format(stats.totalExpense)}',
                    icon: Icons.credit_card,
                    change: l10n.stat_changePercentFromLastMonth(stats.expenseChange.toString()),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Recent Activity card
            SurfaceCard(
              title: l10n.dashboard_recentActivity,
              subtitle:
                  state.recentActivities.hasValue &&
                      state.recentActivities.value!.isNotEmpty
                  ? l10n.dashboard_recentActivitiesCount(state.recentActivities.value!.length)
                  : l10n.dashboard_recentActivitiesEmpty,
              trailing: IconButton(
                onPressed: controller.fetchRecentActivities,
                icon: const Icon(Icons.refresh),
                tooltip: l10n.tooltip_refresh,
              ),
              child: state.recentActivities.when(
                loading: () => LoadingShimmer(
                  child: Column(
                    children: [
                      for (int i = 0; i < 3; i++) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ShimmerPlaceholders.text(
                                      width: 200,
                                      height: 16,
                                    ),
                                    const SizedBox(height: 4),
                                    ShimmerPlaceholders.text(
                                      width: 300,
                                      height: 14,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (i < 2)
                          Divider(
                            height: 1,
                            color: theme.colorScheme.outlineVariant,
                          ),
                      ],
                    ],
                  ),
                ),
                error: (e, st) => Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text(
                        l10n.err_loadFailed,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: controller.fetchRecentActivities,
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.btn_retry),
                      ),
                    ],
                  ),
                ),
                data: (activities) => activities.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        alignment: Alignment.center,
                        child: Text(
                          l10n.err_noData,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          for (int i = 0; i < activities.length; i++) ...[
                            _ActivityItem(activity: activities[i]),
                            if (i < activities.length - 1)
                              Divider(
                                height: 1,
                                color: theme.colorScheme.outlineVariant,
                              ),
                          ],
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.change,
  });

  final String title;
  final String value;
  final IconData icon;
  final String change;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            change,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({required this.activity});

  final RecentActivity activity;

  IconData _getActivityIcon() {
    switch (activity.type) {
      case ActivityType.member:
        return Icons.person_add;
      case ActivityType.transaction:
        return Icons.attach_money;
      case ActivityType.approval:
        return Icons.check_circle_outline;
      case ActivityType.event:
        return Icons.event;
    }
  }

  Color _getActivityColor(ThemeData theme) {
    switch (activity.type) {
      case ActivityType.member:
        return theme.colorScheme.primary;
      case ActivityType.transaction:
        return theme.colorScheme.tertiary;
      case ActivityType.approval:
        return Colors.green;
      case ActivityType.event:
        return theme.colorScheme.tertiary;
    }
  }

  String _formatTimestamp(BuildContext context, DateTime timestamp) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inDays > 0) {
      return l10n.time_daysAgo(diff.inDays);
    } else if (diff.inHours > 0) {
      return l10n.time_hoursAgo(diff.inHours);
    } else if (diff.inMinutes > 0) {
      return l10n.time_minutesAgo(diff.inMinutes);
    } else {
      return l10n.time_justNow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getActivityColor(theme);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_getActivityIcon(), size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        activity.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (activity.amount != null)
                      Text(
                        activity.amount!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  activity.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimestamp(context, activity.timestamp),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.6,
                    ),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
