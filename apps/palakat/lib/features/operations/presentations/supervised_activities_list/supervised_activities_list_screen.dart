import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
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
          Gap.h32,
          ScreenTitleWidget.titleSecondary(
            title: l10n.supervisedActivities_title,
            subTitle: l10n.supervisedActivities_subtitle,
          ),
          Gap.h16,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: BaseSize.w12),
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
          Gap.h16,
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: BaseSize.w12),
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
      child: Column(
        children: [
          PalakatShimmerPlaceholders.listItemCard(),
          Gap.h12,
          PalakatShimmerPlaceholders.listItemCard(),
          Gap.h12,
          PalakatShimmerPlaceholders.listItemCard(),
          Gap.h12,
          PalakatShimmerPlaceholders.listItemCard(),
        ],
      ),
    );
  }

  Widget _buildContent(
    SupervisedActivitiesListState state,
    SupervisedActivitiesListController controller,
  ) {
    if (state.activities.isEmpty) {
      return _EmptyState(
        hasActiveFilters: state.hasActiveFilters,
        onClearFilters: controller.clearFilters,
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: EdgeInsets.only(bottom: BaseSize.h16),
      itemCount: state.activities.length + (state.isLoadingMore ? 1 : 0),
      separatorBuilder: (_, _) => Gap.h12,
      itemBuilder: (context, index) {
        if (index == state.activities.length) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(BaseSize.w16),
              child: SizedBox(
                width: BaseSize.w24,
                height: BaseSize.w24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: BaseColor.primary[700],
                ),
              ),
            ),
          );
        }

        final activity = state.activities[index];
        return SupervisedActivityListItemWidget(
          activity: activity,
          onTap: () {
            context.pushNamed(
              AppRoute.activityDetail,
              pathParameters: {'activityId': activity.id.toString()},
            );
          },
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
            width: BaseSize.w28,
            height: BaseSize.w28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: BaseColor.neutral[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              AppIcons.apps,
              size: BaseSize.w16,
              color: BaseColor.neutral[600],
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
                  style: BaseTypography.titleMedium.copyWith(
                    color: BaseColor.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  l10n.filter_activityType_allSubtitle,
                  style: BaseTypography.labelSmall.copyWith(
                    color: BaseColor.textSecondary,
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
          width: BaseSize.w28,
          height: BaseSize.w28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _getActivityColor(type).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            _getActivityIcon(type),
            size: BaseSize.w16,
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
                style: BaseTypography.titleMedium.copyWith(
                  color: BaseColor.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _getActivityDescription(context, type),
                style: BaseTypography.labelSmall.copyWith(
                  color: BaseColor.textSecondary,
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
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(BaseSize.radiusXl),
        ),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.all(BaseSize.w16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                leading: Container(
                  width: BaseSize.w32,
                  height: BaseSize.w32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: BaseColor.neutral[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    AppIcons.apps,
                    size: BaseSize.w18,
                    color: BaseColor.neutral[600],
                  ),
                ),
                title: Text(l10n.filter_activityType_allTitle),
                subtitle: Text(
                  l10n.filter_activityType_allSheetSubtitle,
                  style: BaseTypography.bodySmall.toSecondary,
                ),
                trailing: currentValue == null
                    ? const Icon(AppIcons.check)
                    : null,
                onTap: () => Navigator.of(ctx).pop(null),
              ),
              ...ActivityType.values.map((type) {
                return ListTile(
                  leading: Container(
                    width: BaseSize.w32,
                    height: BaseSize.w32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _getActivityColor(type).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getActivityIcon(type),
                      size: BaseSize.w18,
                      color: _getActivityColor(type),
                    ),
                  ),
                  title: Text(type.displayName),
                  subtitle: Text(
                    _getActivityDescription(context, type),
                    style: BaseTypography.bodySmall.toSecondary,
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
        return BaseColor.primary[700]!;
      case ActivityType.event:
        return BaseColor.blue[700]!;
      case ActivityType.announcement:
        return BaseColor.yellow[700]!;
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
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w12,
        vertical: BaseSize.h8,
      ),
      decoration: BoxDecoration(
        color: BaseColor.primary[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: BaseColor.primary[200]!, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.filterList,
            size: BaseSize.w16,
            color: BaseColor.primary[700],
          ),
          Gap.w8,
          Expanded(
            child: Text(
              l10n.filters_applied,
              style: BaseTypography.bodySmall.copyWith(
                color: BaseColor.primary[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: onClearFilters,
            style: TextButton.styleFrom(
              foregroundColor: BaseColor.primary[700],
              padding: EdgeInsets.symmetric(
                horizontal: BaseSize.w8,
                vertical: BaseSize.h4,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              l10n.btn_clearAll,
              style: BaseTypography.bodySmall.copyWith(
                color: BaseColor.primary[700],
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
        padding: EdgeInsets.all(BaseSize.w24),
        margin: EdgeInsets.symmetric(horizontal: BaseSize.w16),
        decoration: BoxDecoration(
          color: BaseColor.cardBackground1,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: BaseColor.neutral20, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasActiveFilters
                  ? AppIcons.filterListOff
                  : AppIcons.supervisorAccount,
              size: BaseSize.w48,
              color: BaseColor.secondaryText,
            ),
            Gap.h12,
            Text(
              hasActiveFilters
                  ? l10n.supervisedActivities_emptyFilteredTitle
                  : l10n.supervisedActivities_emptyTitle,
              textAlign: TextAlign.center,
              style: BaseTypography.titleMedium.copyWith(
                color: BaseColor.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            Gap.h4,
            Text(
              hasActiveFilters
                  ? l10n.supervisedActivities_emptyFilteredSubtitle
                  : l10n.supervisedActivities_emptySubtitle,
              textAlign: TextAlign.center,
              style: BaseTypography.bodyMedium.copyWith(
                color: BaseColor.secondaryText,
              ),
            ),
            if (hasActiveFilters) ...[
              Gap.h16,
              OutlinedButton.icon(
                onPressed: onClearFilters,
                icon: Icon(AppIcons.clear, size: BaseSize.w14),
                label: Text(l10n.btn_clearFilters),
                style: OutlinedButton.styleFrom(
                  foregroundColor: BaseColor.primary[700],
                  side: BorderSide(color: BaseColor.primary[300]!, width: 1),
                  padding: EdgeInsets.symmetric(
                    horizontal: BaseSize.w12,
                    vertical: BaseSize.h8,
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
