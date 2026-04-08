import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/operations/presentations/operations_motion_widget.dart';
import 'package:palakat/features/operations/presentations/supervised_activities_list/supervised_activities_list_controller.dart';
import 'package:palakat/features/operations/presentations/supervised_activities_list/supervised_activities_list_state.dart';
import 'package:palakat/features/operations/presentations/supervised_activities_list/widgets/supervised_activity_list_item_widget.dart';
import 'package:palakat_shared/core/extension/extension.dart';

/// Screen displaying all supervised activities with filtering capabilities.
/// Shows paginated list of activities with filters for activity type and date range.
///
/// Requirements: 2.3, 3.1, 3.2, 3.5
class SupervisedActivitiesListScreen extends ConsumerStatefulWidget {
  const SupervisedActivitiesListScreen({super.key});

  @override
  ConsumerState<SupervisedActivitiesListScreen> createState() =>
      _SupervisedActivitiesListScreenState();
}

class _SupervisedActivitiesListScreenState
    extends ConsumerState<SupervisedActivitiesListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isNearBottom) {
      ref
          .read(supervisedActivitiesListControllerProvider.notifier)
          .loadMoreActivities();
    }
  }

  bool get _isNearBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(supervisedActivitiesListControllerProvider);
    final controller = ref.read(
      supervisedActivitiesListControllerProvider.notifier,
    );

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OperationsReveal(
            child: ScreenTitleWidget.titleSecondary(
              title: l10n.supervisedActivities_title,
              subTitle: l10n.supervisedActivities_subtitle,
            ),
          ),
          Gap.h16,
          OperationsReveal(
            delay: const Duration(milliseconds: 40),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: _FilterSection(
                filterActivityType: state.filterActivityType,
                filterStartDate: state.filterStartDate,
                filterEndDate: state.filterEndDate,
                hasActiveFilters: state.hasActiveFilters,
                onActivityTypeChanged: controller.setActivityTypeFilter,
                onDateRangeChanged: controller.setDateRangeFilter,
                onClearFilters: controller.clearFilters,
              ),
            ),
          ),
          Gap.h16,
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: LoadingWrapper(
                loading: state.isLoading,
                hasError: state.errorMessage != null && !state.isLoading,
                errorMessage: state.errorMessage,
                onRetry: () => controller.fetchActivities(refresh: true),
                shimmerPlaceholder: _buildShimmerPlaceholder(),
                child: _buildContent(state, controller),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return SingleChildScrollView(
      child: ShimmerPlaceholders.listSection(count: 4, gap: 12),
    );
  }

  Widget _buildContent(
    SupervisedActivitiesListState state,
    SupervisedActivitiesListController controller,
  ) {
    if (state.activities.isEmpty) {
      return OperationsAnimatedPresence(
        visible: true,
        child: _EmptyState(
          hasActiveFilters: state.hasActiveFilters,
          onClearFilters: controller.clearFilters,
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: EdgeInsets.only(bottom: 16.0),
      itemCount: state.activities.length + (state.isLoadingMore ? 1 : 0),
      separatorBuilder: (_, _) => Gap.h12,
      itemBuilder: (context, index) {
        if (index == state.activities.length) {
          return OperationsAnimatedPresence(
            visible: true,
            child: LoadingShimmer(
              isLoading: true,
              child: ShimmerPlaceholders.listItemCard(),
            ),
          );
        }

        final activity = state.activities[index];
        return OperationsReveal(
          delay: Duration(milliseconds: 40 + (index * 30)),
          child: SupervisedActivityListItemWidget(
            activity: activity,
            onTap: () {
              context.pushNamed(
                AppRoute.activityDetail,
                pathParameters: {'activityId': activity.id.toString()},
              );
            },
          ),
        );
      },
    );
  }
}

/// Filter section with activity type dropdown and date range picker
/// Requirements: 3.1, 3.2, 3.5
class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.filterActivityType,
    required this.filterStartDate,
    required this.filterEndDate,
    required this.hasActiveFilters,
    required this.onActivityTypeChanged,
    required this.onDateRangeChanged,
    required this.onClearFilters,
  });

  final ActivityType? filterActivityType;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  final bool hasActiveFilters;
  final void Function(ActivityType?) onActivityTypeChanged;
  final void Function(DateTime?, DateTime?) onDateRangeChanged;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ActivityTypeFilter(
          currentValue: filterActivityType,
          onChanged: onActivityTypeChanged,
        ),
        Gap.h12,
        DateRangePresetInput(
          label: l10n.approval_filterByDate,
          start: filterStartDate,
          end: filterEndDate,
          onChanged: onDateRangeChanged,
        ),
        if (hasActiveFilters) ...[
          Gap.h12,
          _ActiveFilterIndicator(onClearFilters: onClearFilters),
        ],
      ],
    );
  }
}

/// Activity type dropdown filter - Requirement: 3.1
class _ActivityTypeFilter extends StatelessWidget {
  const _ActivityTypeFilter({
    required this.currentValue,
    required this.onChanged,
  });

  final ActivityType? currentValue;
  final void Function(ActivityType?) onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return InputWidget<ActivityType?>.dropdown(
      label: l10n.filter_activityType_label,
      hint: l10n.filter_activityType_hint,
      currentInputValue: currentValue,
      options: [null, ...ActivityType.values],
      optionLabel: (type) =>
          type?.displayName ?? l10n.filter_activityType_allTitle,
      customDisplayBuilder: (type) => _buildCustomDisplay(context, type),
      onChanged: onChanged,
      onPressedWithResult: () async {
        return await _showActivityTypeBottomSheet(context);
      },
    );
  }

  Widget _buildCustomDisplay(BuildContext context, ActivityType? type) {
    final l10n = context.l10n;
    if (type == null) {
      return Row(
        children: [
          Container(
            width: 28.0,
            height: 28.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              border: Border.all(color: AppColors.outlineVariant),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              AppIcons.apps,
              size: 16.0,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          Gap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.filter_activityType_allTitle,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  l10n.filter_activityType_allSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Container(
          width: 28.0,
          height: 28.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _getActivityColor(type).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            _getActivityIcon(type),
            size: 16.0,
            color: _getActivityColor(type),
          ),
        ),
        Gap.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                type.displayName,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _getActivityDescription(context, type),
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<ActivityType?> _showActivityTypeBottomSheet(
    BuildContext context,
  ) async {
    final l10n = context.l10n;
    return showModalBottomSheet<ActivityType?>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                leading: Container(
                  width: 32.0,
                  height: 32.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    border: Border.all(color: AppColors.outlineVariant),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    AppIcons.apps,
                    size: 18.0,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                title: Text(l10n.filter_activityType_allTitle),
                subtitle: Text(
                  l10n.filter_activityType_allSheetSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium!.toSecondary,
                ),
                trailing: currentValue == null
                    ? const Icon(AppIcons.check)
                    : null,
                onTap: () => Navigator.of(ctx).pop(null),
              ),
              ...ActivityType.values.map((type) {
                return ListTile(
                  leading: Container(
                    width: 32.0,
                    height: 32.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _getActivityColor(type).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getActivityIcon(type),
                      size: 18.0,
                      color: _getActivityColor(type),
                    ),
                  ),
                  title: Text(type.displayName),
                  subtitle: Text(
                    _getActivityDescription(context, type),
                    style: Theme.of(context).textTheme.bodyMedium!.toSecondary,
                  ),
                  trailing: currentValue == type
                      ? const Icon(AppIcons.check)
                      : null,
                  onTap: () => Navigator.of(ctx).pop(type),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.service:
        return AppIcons.church;
      case ActivityType.event:
        return AppIcons.event;
      case ActivityType.announcement:
        return AppIcons.announcement;
    }
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.service:
        return AppColors.primary;
      case ActivityType.event:
        return AppColors.primary;
      case ActivityType.announcement:
        return AppColors.warning;
    }
  }

  String _getActivityDescription(BuildContext context, ActivityType type) {
    final l10n = context.l10n;
    switch (type) {
      case ActivityType.service:
        return l10n.activityType_service_desc;
      case ActivityType.event:
        return l10n.activityType_event_desc;
      case ActivityType.announcement:
        return l10n.activityType_announcement_desc;
    }
  }
}

/// Active filter indicator with clear button - Requirement: 3.5
class _ActiveFilterIndicator extends StatelessWidget {
  const _ActiveFilterIndicator({required this.onClearFilters});

  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.24),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(AppIcons.filterList, size: 16.0, color: AppColors.primary),
          Gap.w8,
          Expanded(
            child: Text(
              l10n.filters_applied,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: onClearFilters,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              l10n.btn_clearAll,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty state widget - Requirement: 4.3
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.hasActiveFilters,
    required this.onClearFilters,
  });

  final bool hasActiveFilters;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Container(
        padding: EdgeInsets.all(24.0),
        margin: EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.tertiary, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasActiveFilters
                  ? AppIcons.filterListOff
                  : AppIcons.supervisorAccount,
              size: 48.0,
              color: AppColors.onSurfaceVariant,
            ),
            Gap.h12,
            Text(
              hasActiveFilters
                  ? l10n.supervisedActivities_emptyFilteredTitle
                  : l10n.supervisedActivities_emptyTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            Gap.h4,
            Text(
              hasActiveFilters
                  ? l10n.supervisedActivities_emptyFilteredSubtitle
                  : l10n.supervisedActivities_emptySubtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            if (hasActiveFilters) ...[
              Gap.h16,
              OutlinedButton.icon(
                onPressed: onClearFilters,
                icon: Icon(AppIcons.clear, size: 14.0),
                label: Text(l10n.btn_clearFilters),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary, width: 1),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
