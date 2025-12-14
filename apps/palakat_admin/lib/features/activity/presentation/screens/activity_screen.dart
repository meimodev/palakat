import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/features/activity/activity.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column;

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  /// Shows activity drawer for viewing
  void _showActivityDrawer(int activityId) {
    DrawerUtils.showDrawer(
      context: context,
      drawer: ActivityDetailDrawer(
        activityId: activityId,
        onClose: () => DrawerUtils.closeDrawer(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final ActivityScreenState state = ref.watch(activityControllerProvider);
    final ActivityController controller = ref.watch(
      activityControllerProvider.notifier,
    );

    return Material(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.admin_activity_title,
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.admin_activity_subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            SurfaceCard(
              title: l10n.card_activityList_title,
              subtitle: l10n.card_activityList_subtitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTable<Activity>(
                    loading: state.activities.isLoading,
                    data: state.activities.value?.data ?? [],
                    errorText: state.activities.hasError
                        ? state.activities.error.toString()
                        : null,
                    onRetry: () => controller.refresh(),
                    pagination: () {
                      final pageSize =
                          state.activities.value?.pagination.pageSize ?? 10;
                      final page = state.activities.value?.pagination.page ?? 1;
                      final total =
                          state.activities.value?.pagination.total ?? 0;

                      final hasPrev =
                          state.activities.value?.pagination.hasPrev ?? false;
                      final hasNext =
                          state.activities.value?.pagination.hasNext ?? false;

                      return AppTablePaginationConfig(
                        total: total,
                        pageSize: pageSize,
                        page: page,
                        onPageSizeChanged: controller.onChangedPageSize,
                        onPageChanged: controller.onChangedPage,
                        onPrev: hasPrev ? controller.onPressedPrevPage : null,
                        onNext: hasNext ? controller.onPressedNextPage : null,
                      );
                    }.call(),
                    filtersConfig: AppTableFiltersConfig(
                      searchHint: l10n.hint_searchByTitleDescription,
                      onSearchChanged: controller.onChangedSearch,
                      dateRangePreset: state.dateRangePreset,
                      customDateRange: state.customDateRange,
                      onDateRangePresetChanged:
                          controller.onChangedDateRangePreset,
                      onCustomDateRangeSelected:
                          controller.onCustomDateRangeSelected,
                      dropdownLabel: l10n.lbl_type,
                      dropdownOptions: {
                        ActivityType.service.name:
                            ActivityType.service.displayName,
                        ActivityType.event.name: ActivityType.event.displayName,
                        ActivityType.announcement.name:
                            ActivityType.announcement.displayName,
                      },
                      dropdownValue: state.activityTypeFilter?.name,
                      onDropdownChanged: (value) {
                        if (value == null) {
                          controller.onChangedActivityType(null);
                        } else {
                          controller.onChangedActivityType(
                            ActivityType.values.firstWhere(
                              (e) => e.name == value,
                            ),
                          );
                        }
                      },
                    ),
                    onRowTap: (activity) async {
                      if (activity.id != null) {
                        _showActivityDrawer(activity.id!);
                      }
                    },
                    columns: _buildTableColumns(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the table column configuration for the activities table
  List<AppTableColumn<Activity>> _buildTableColumns() {
    final l10n = context.l10n;
    return [
      AppTableColumn<Activity>(
        title: l10n.tbl_title,
        flex: 3,
        cellBuilder: (ctx, activity) {
          final theme = Theme.of(ctx);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                activity.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (activity.description != null) ...[
                const SizedBox(height: 2),
                Text(
                  activity.description ?? "",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          );
        },
      ),
      AppTableColumn<Activity>(
        title: l10n.tbl_type,
        flex: 2,
        cellBuilder: (ctx, activity) {
          return ActivityTypeChip(type: activity.activityType);
        },
      ),
      AppTableColumn<Activity>(
        title: l10n.tbl_requestDate,
        flex: 2,
        cellBuilder: (ctx, activity) {
          final theme = Theme.of(ctx);
          final date = activity.createdAt.toCustomFormat("EEEE, dd MMMM yyyy");
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              date,
              style: theme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
      AppTableColumn<Activity>(
        title: l10n.tbl_supervisor,
        flex: 2,
        cellBuilder: (ctx, activity) {
          final theme = Theme.of(ctx);
          return Text(
            activity.supervisor.account?.name ?? "",
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          );
        },
      ),
      AppTableColumn<Activity>(
        title: l10n.tbl_approval,
        flex: 2,
        cellBuilder: (ctx, activity) {
          return CompactStatusChip.forApproval(
            ctx,
            activity.approvers.approvalStatus,
          );
        },
      ),
      AppTableColumn<Activity>(
        title: l10n.tbl_approvers,
        flex: 3,
        cellBuilder: (ctx, activity) {
          return ApproversWrapDisplay(
            approvers: activity.approvers,
            fallbackDate: activity.updatedAt ?? activity.createdAt,
          );
        },
      ),
    ];
  }
}
