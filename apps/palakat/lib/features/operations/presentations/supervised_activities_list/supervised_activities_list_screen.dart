import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/operations/presentations/supervised_activities_list/supervised_activities_list_controller.dart';
import 'package:palakat/features/operations/presentations/supervised_activities_list/supervised_activities_list_state.dart';
import 'package:palakat/features/operations/presentations/supervised_activities_list/widgets/supervised_activity_list_item_widget.dart';

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
          const ScreenTitleWidget.titleSecondary(
            title: "Supervised Activities",
            subTitle: "Activities you are responsible for",
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
              extra: RouteParam(
                params: {RouteParamKey.activity: activity.toJson()},
              ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ActivityTypeFilter(
          currentValue: filterActivityType,
          onChanged: onActivityTypeChanged,
        ),
        Gap.h12,
        DateRangePresetInput(
          label: 'Filter by date',
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
    return InputWidget<ActivityType?>.dropdown(
      label: 'Activity Type',
      hint: 'Select activity type',
      currentInputValue: currentValue,
      options: [null, ...ActivityType.values],
      optionLabel: (type) => type?.displayName ?? 'All types',
      customDisplayBuilder: (type) => _buildCustomDisplay(type),
      onChanged: onChanged,
      onPressedWithResult: () async {
        return await _showActivityTypeBottomSheet(context);
      },
    );
  }

  Widget _buildCustomDisplay(ActivityType? type) {
    if (type == null) {
      return Row(
        children: [
          Container(
            width: BaseSize.w28,
            height: BaseSize.w28,
            decoration: BoxDecoration(
              color: BaseColor.neutral[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.apps,
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
                  'All types',
                  style: BaseTypography.titleMedium.copyWith(
                    color: BaseColor.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Showing all activity types',
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
                _getActivityDescription(type),
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
                  decoration: BoxDecoration(
                    color: BaseColor.neutral[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.apps,
                    size: BaseSize.w18,
                    color: BaseColor.neutral[600],
                  ),
                ),
                title: const Text('All types'),
                subtitle: Text(
                  'Show all activity types',
                  style: BaseTypography.bodySmall.toSecondary,
                ),
                trailing: currentValue == null ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(ctx).pop(null),
              ),
              ...ActivityType.values.map((type) {
                return ListTile(
                  leading: Container(
                    width: BaseSize.w32,
                    height: BaseSize.w32,
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
                    _getActivityDescription(type),
                    style: BaseTypography.bodySmall.toSecondary,
                  ),
                  trailing: currentValue == type
                      ? const Icon(Icons.check)
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
        return Icons.church_outlined;
      case ActivityType.event:
        return Icons.event_outlined;
      case ActivityType.announcement:
        return Icons.campaign_outlined;
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

  String _getActivityDescription(ActivityType type) {
    switch (type) {
      case ActivityType.service:
        return 'Church services and worship';
      case ActivityType.event:
        return 'Events and gatherings';
      case ActivityType.announcement:
        return 'Announcements and notices';
    }
  }
}

/// Active filter indicator with clear button - Requirement: 3.5
class _ActiveFilterIndicator extends StatelessWidget {
  const _ActiveFilterIndicator({required this.onClearFilters});

  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
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
            Icons.filter_list,
            size: BaseSize.w16,
            color: BaseColor.primary[700],
          ),
          Gap.w8,
          Expanded(
            child: Text(
              'Filters applied',
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
              'Clear all',
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
                  ? Icons.filter_list_off_outlined
                  : Icons.supervisor_account_outlined,
              size: BaseSize.w48,
              color: BaseColor.secondaryText,
            ),
            Gap.h12,
            Text(
              hasActiveFilters
                  ? 'No activities match your filters'
                  : 'No supervised activities',
              textAlign: TextAlign.center,
              style: BaseTypography.titleMedium.copyWith(
                color: BaseColor.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            Gap.h4,
            Text(
              hasActiveFilters
                  ? 'Try adjusting your filters to see more results'
                  : 'Activities you supervise will appear here',
              textAlign: TextAlign.center,
              style: BaseTypography.bodyMedium.copyWith(
                color: BaseColor.secondaryText,
              ),
            ),
            if (hasActiveFilters) ...[
              Gap.h16,
              OutlinedButton.icon(
                onPressed: onClearFilters,
                icon: Icon(Icons.clear, size: BaseSize.w14),
                label: const Text('Clear filters'),
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
