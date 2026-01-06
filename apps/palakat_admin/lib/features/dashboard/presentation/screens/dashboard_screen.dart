import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column;

import '../state/dashboard_controller.dart';
import '../../../activity/activity.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(dashboardControllerProvider);
    final controller = ref.read(dashboardControllerProvider.notifier);

    final l10n = context.l10n;

    final isNarrow = MediaQuery.of(context).size.width < 1000;
    final churchName = state.home.value?.data.membership.church?.name;
    final subtitle = churchName == null || churchName.trim().isEmpty
        ? l10n.dashboard_subtitle
        : churchName;

    final pendingApprovals = state.pendingApprovals.value;
    final home = state.home.value;

    final pendingTotal = pendingApprovals?.pagination.total ?? 0;
    final scheduleCount = home?.data.thisWeekActivities.length ?? 0;
    final announcementCount = home?.data.thisWeekAnnouncements.length ?? 0;

    return Material(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.dashboard_title,
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => controller.refresh(),
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.tooltip_refresh),
                    ),
                    FilledButton.icon(
                      onPressed: () => context.go('/activity'),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.nav_activity),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                QuickStatCard(
                  label: l10n.approval_title,
                  value: pendingTotal.toString(),
                  icon: Icons.assignment_outlined,
                  iconColor: Colors.blue.shade700,
                  iconBackgroundColor: Colors.blue.shade50,
                  isLoading: state.pendingApprovals.isLoading,
                  width: 240,
                ),
                QuickStatCard(
                  label: l10n.section_schedule,
                  value: scheduleCount.toString(),
                  icon: Icons.event_outlined,
                  iconColor: Colors.orange.shade700,
                  iconBackgroundColor: Colors.orange.shade50,
                  isLoading: state.home.isLoading,
                  width: 240,
                ),
                QuickStatCard(
                  label: l10n.activityType_announcement,
                  value: announcementCount.toString(),
                  icon: Icons.campaign_outlined,
                  iconColor: Colors.purple.shade700,
                  iconBackgroundColor: Colors.purple.shade50,
                  isLoading: state.home.isLoading,
                  width: 240,
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (isNarrow)
              Column(
                children: [
                  _PendingApprovalsCard(
                    pendingApprovals: pendingApprovals,
                    loading: state.pendingApprovals.isLoading,
                    hasError: state.pendingApprovals.hasError,
                    error: state.pendingApprovals.error,
                    onRetry: controller.fetchPendingApprovals,
                  ),
                  const SizedBox(height: 16),
                  _UpcomingCard(
                    home: home,
                    loading: state.home.isLoading,
                    hasError: state.home.hasError,
                    error: state.home.error,
                    onRetry: controller.fetchHome,
                  ),
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _UpcomingCard(
                          home: home,
                          loading: state.home.isLoading,
                          hasError: state.home.hasError,
                          error: state.home.error,
                          onRetry: controller.fetchHome,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 520,
                    child: _PendingApprovalsCard(
                      pendingApprovals: pendingApprovals,
                      loading: state.pendingApprovals.isLoading,
                      hasError: state.pendingApprovals.hasError,
                      error: state.pendingApprovals.error,
                      onRetry: controller.fetchPendingApprovals,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _PendingApprovalsCard extends StatelessWidget {
  const _PendingApprovalsCard({
    required this.pendingApprovals,
    required this.loading,
    required this.hasError,
    required this.error,
    required this.onRetry,
  });

  final PaginationResponseWrapper<Approver>? pendingApprovals;
  final bool loading;
  final bool hasError;
  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rawApprovals = pendingApprovals?.data ?? const <Approver>[];
    final activityApprovals = rawApprovals
        .where((a) {
          final activityId = a.activityId;
          final activity = a.activity;
          if (activityId == null || activity == null) return false;

          return activity.approvers.approvalStatus ==
              ApprovalStatus.unconfirmed;
        })
        .toList(growable: false);

    final approvalsByActivityId = <int, Approver>{};
    for (final a in activityApprovals) {
      final activityId = a.activityId;
      if (activityId == null) continue;

      final existing = approvalsByActivityId[activityId];
      if (existing == null) {
        approvalsByActivityId[activityId] = a;
        continue;
      }

      if (existing.activity == null && a.activity != null) {
        approvalsByActivityId[activityId] = a;
      }
    }

    final approvals = approvalsByActivityId.values.toList(growable: false);

    final total = approvals.length;

    return SurfaceCard(
      title: l10n.approval_title,
      subtitle: l10n.approval_pendingReviewCount(total),
      trailing: TextButton(
        onPressed: () => context.go('/activity'),
        child: Text(l10n.btn_viewAll),
      ),
      child: LoadingWrapper(
        loading: loading,
        hasError: hasError,
        errorMessage: hasError ? error.toString() : null,
        onRetry: onRetry,
        child: approvals.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(context.l10n.approval_allCaughtUpTitle),
              )
            : Column(
                children: [
                  for (final a in approvals) ...[
                    Builder(
                      builder: (context) {
                        final activity = a.activity;
                        final title =
                            activity?.title ??
                            context.l10n.lbl_hashId(
                              a.activityId?.toString() ?? context.l10n.lbl_na,
                            );
                        final memberName = a.membership?.account?.name;
                        final subtitleText =
                            (activity?.note?.trim().isNotEmpty == true)
                            ? activity!.note!.trim()
                            : (activity?.description?.trim().isNotEmpty == true)
                            ? activity!.description!.trim()
                            : (memberName != null &&
                                  memberName.trim().isNotEmpty)
                            ? memberName.trim()
                            : null;

                        final dateText = activity?.date.toDateTimeString();
                        final subtitle = dateText == null
                            ? subtitleText
                            : (subtitleText == null
                                  ? dateText
                                  : '$dateText • $subtitleText');

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          minVerticalPadding: 0,
                          visualDensity: const VisualDensity(
                            horizontal: -2,
                            vertical: -3,
                          ),
                          onTap: a.activityId == null
                              ? null
                              : () {
                                  DrawerUtils.showDrawer(
                                    context: context,
                                    drawer: ActivityDetailDrawer(
                                      activityId: a.activityId!,
                                      onClose: () =>
                                          DrawerUtils.closeDrawer(context),
                                    ),
                                  );
                                },
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            radius: 16,
                            child: Icon(
                              Icons.assignment_outlined,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                              size: 18,
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (activity != null)
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 120,
                                  ),
                                  child: ActivityTypeChip(
                                    type: activity.activityType,
                                    iconSize: 12,
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                          subtitle: subtitle == null
                              ? null
                              : Text(
                                  subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          trailing: null,
                        );
                      },
                    ),
                    const Divider(height: 1),
                  ],
                ],
              ),
      ),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({
    required this.home,
    required this.loading,
    required this.hasError,
    required this.error,
    required this.onRetry,
  });

  final HomeDashboardResponse? home;
  final bool loading;
  final bool hasError;
  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final data = home?.data;
    final nextUp = data?.nextUpActivity;
    final schedule = data?.thisWeekActivities ?? const <Activity>[];
    final announcements = data?.thisWeekAnnouncements ?? const <Activity>[];

    return SurfaceCard(
      title: context.l10n.section_schedule,
      subtitle: context.l10n.dateRangeFilter_thisMonth,
      trailing: TextButton(
        onPressed: () => context.go('/activity'),
        child: Text(context.l10n.btn_viewAll),
      ),
      child: LoadingWrapper(
        loading: loading,
        hasError: hasError,
        errorMessage: hasError ? error.toString() : null,
        onRetry: onRetry,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (nextUp != null) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.tertiaryContainer,
                  child: Icon(
                    Icons.event,
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                  ),
                ),
                title: Text(
                  nextUp.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(nextUp.date.toDateTimeString()),
                trailing: TextButton(
                  onPressed: nextUp.id == null
                      ? null
                      : () {
                          DrawerUtils.showDrawer(
                            context: context,
                            drawer: ActivityDetailDrawer(
                              activityId: nextUp.id!,
                              onClose: () => DrawerUtils.closeDrawer(context),
                            ),
                          );
                        },
                  child: Text(context.l10n.btn_viewAll),
                ),
              ),
              const Divider(height: 1),
            ],
            if (schedule.isNotEmpty) ...[
              Text(
                context.l10n.section_schedule,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              for (final a in schedule.take(3))
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          a.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        a.date.toCustomFormat('dd MMM'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              const Divider(height: 1),
            ],
            if (announcements.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                context.l10n.activityType_announcement,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              for (final a in announcements.take(2))
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    a.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
