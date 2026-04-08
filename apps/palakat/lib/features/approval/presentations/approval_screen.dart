import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart'
    hide
        InfoBoxWithActionWidget,
        LoadingShimmer,
        ScaffoldWidget,
        ShimmerPlaceholders;
import 'package:palakat_shared/core/widgets/loading_shimmer.dart';
import 'package:palakat_shared/core/widgets/mobile/scaffold_widget.dart';
import 'package:palakat/features/approval/presentations/approval_controller.dart';
import 'package:palakat/features/approval/presentations/approval_motion_widget.dart';
import 'package:palakat/features/approval/presentations/approval_state.dart';
import 'package:palakat/features/approval/presentations/widgets/approval_card_widget.dart';
import 'package:palakat/features/approval/presentations/widgets/approval_confirmation_bottom_sheet.dart';
import 'package:palakat/features/approval/presentations/widgets/approval_filter_bottom_sheet.dart';
import 'package:palakat_shared/core/widgets/info_box/info_box_with_action_widget.dart';
import 'package:palakat_shared/extensions.dart';
import 'package:palakat_shared/models.dart' hide Column;

class ApprovalScreen extends ConsumerStatefulWidget {
  const ApprovalScreen({super.key});

  @override
  ConsumerState<ApprovalScreen> createState() => _ApprovalScreenState();
}

class _ApprovalScreenState extends ConsumerState<ApprovalScreen> {
  // Track which activity is currently being processed
  int? _processingActivityId;

  // Scroll controller for infinite scrolling
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when user is 200 pixels from the bottom
      ref.read(approvalControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(approvalControllerProvider.notifier);
    final state = ref.watch(approvalControllerProvider);
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      child: RefreshIndicator(
        onRefresh: () => controller.refresh(),
        color: colors.primary,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ApprovalReveal(
                    child: ScreenTitleWidget.titleOnly(
                      title: l10n.approval_title,
                    ),
                  ),
                  Gap.h16,
                  ApprovalReveal(
                    delay: const Duration(milliseconds: 80),
                    child: _buildFilterToolbar(context, state, controller),
                  ),
                  Gap.h16,
                ],
              ),
            ),
            // Approvals list
            _buildApprovalsList(context, state, controller, colors),
            // Loading more indicator
            if (state.isLoadingMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: LoadingShimmer(
                    isLoading: true,
                    child: ShimmerPlaceholders.approvalCard(),
                  ),
                ),
              ),
            // End of list indicator
            if (!state.hasMoreData && state.allActivities.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: Text(
                      l10n.approval_noMoreApprovals,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterToolbar(
    BuildContext context,
    ApprovalState state,
    ApprovalController controller,
  ) {
    final colors = Theme.of(context).colorScheme;
    final summary = _buildFilterSummary(context, state);

    return Row(
      children: [
        _CombinedFilterButton(
          activeFilterCount: state.activeFilterCount,
          hasActiveFilters: state.hasActiveFilters,
          onTap: () async {
            final result = await showApprovalFilterBottomSheet(
              context: context,
              initialStatus: state.statusFilter,
              initialDatePreset: state.datePreset,
              initialStartDate: state.filterStartDate,
              initialEndDate: state.filterEndDate,
            );
            if (result == null || !mounted) return;
            await controller.applyFilters(
              statusFilter: result.statusFilter,
              datePreset: result.datePreset,
              startDate: result.startDate,
              endDate: result.endDate,
            );
          },
        ),
        Gap.w12,
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: AppColors.outlineVariant),
              boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 10),
            ),
            child: Text(
              summary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: state.hasActiveFilters
                    ? colors.onSurface
                    : colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApprovalsList(
    BuildContext context,
    ApprovalState state,
    ApprovalController controller,
    ColorScheme colors,
  ) {
    if (state.loadingScreen) {
      return SliverToBoxAdapter(child: ShimmerPlaceholders.approvalSection());
    }

    if (state.errorMessage != null) {
      return SliverToBoxAdapter(
        child: ApprovalAnimatedPresence(
          visible: true,
          child: _buildErrorState(context, state.errorMessage!, controller),
        ),
      );
    }

    // When showing all, display grouped sections
    if (state.statusFilter == ApprovalFilterStatus.all) {
      return _buildGroupedList(context, state, controller, colors);
    }

    // When filtering by specific status, show flat list
    return _buildFlatList(
      context,
      state.filteredApprovals,
      state,
      controller,
      colors,
    );
  }

  Widget _buildGroupedList(
    BuildContext context,
    ApprovalState state,
    ApprovalController controller,
    ColorScheme colors,
  ) {
    final sections = <Widget>[];
    var sectionIndex = 0;

    // Pending My Action section (shown first for prioritization)
    if (state.pendingMyAction.isNotEmpty) {
      sections.add(
        ApprovalReveal(
          delay: Duration(milliseconds: 40 + (sectionIndex * 40)),
          child: _buildSection(
            context,
            context.l10n.approval_sectionPendingYourAction,
            state.pendingMyAction,
            state,
            colors,
            controller,
            icon: AppIcons.pending,
            color: colors.primary,
          ),
        ),
      );
      sectionIndex++;
    }

    // Pending Others section
    if (state.pendingOthers.isNotEmpty) {
      sections.add(
        ApprovalReveal(
          delay: Duration(milliseconds: 40 + (sectionIndex * 40)),
          child: _buildSection(
            context,
            context.l10n.approval_sectionPendingOthers,
            state.pendingOthers,
            state,
            colors,
            controller,
            icon: AppIcons.inProgress,
            color: AppColors.warning,
          ),
        ),
      );
      sectionIndex++;
    }

    // Approved section
    if (state.approved.isNotEmpty) {
      sections.add(
        ApprovalReveal(
          delay: Duration(milliseconds: 40 + (sectionIndex * 40)),
          child: _buildSection(
            context,
            context.l10n.status_approved,
            state.approved,
            state,
            colors,
            controller,
            icon: AppIcons.success,
            color: AppColors.success,
          ),
        ),
      );
      sectionIndex++;
    }

    // Rejected section
    if (state.rejected.isNotEmpty) {
      sections.add(
        ApprovalReveal(
          delay: Duration(milliseconds: 40 + (sectionIndex * 40)),
          child: _buildSection(
            context,
            context.l10n.status_rejected,
            state.rejected,
            state,
            colors,
            controller,
            icon: AppIcons.reject,
            color: AppColors.error,
          ),
        ),
      );
      sectionIndex++;
    }

    if (sections.isEmpty) {
      return SliverToBoxAdapter(
        child: ApprovalAnimatedPresence(
          visible: true,
          child: _buildEmptyContent(context, state, controller, colors),
        ),
      );
    }

    return SliverList(delegate: SliverChildListDelegate(sections));
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Activity> activities,
    ApprovalState state,
    ColorScheme colors,
    ApprovalController controller, {
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              FaIcon(icon, size: 16.0, color: color),
              Gap.w8,
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ),
              Text(
                '(${activities.length})',
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Gap.h8,
          // Activity cards
          ...activities.map(
            (activity) => Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: _buildActivityCard(context, activity, state, controller),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlatList(
    BuildContext context,
    List<Activity> activities,
    ApprovalState state,
    ApprovalController controller,
    ColorScheme colors,
  ) {
    if (activities.isEmpty) {
      return SliverToBoxAdapter(
        child: ApprovalAnimatedPresence(
          visible: true,
          child: _buildEmptyContent(context, state, controller, colors),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final activity = activities[index];
        return ApprovalReveal(
          key: ValueKey('approval-flat-${activity.id ?? index}'),
          delay: Duration(milliseconds: 40 + (index * 40)),
          child: Padding(
            padding: EdgeInsets.only(bottom: 20.0),
            child: _buildActivityCard(context, activity, state, controller),
          ),
        );
      }, childCount: activities.length),
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    Activity activity,
    ApprovalState state,
    ApprovalController controller,
  ) {
    // Find the approver ID for the current user
    final currentUserApproverId = _findCurrentUserApproverId(
      activity,
      state.membership?.id,
    );

    return ApprovalCardWidget(
      approval: activity,
      currentMembershipId: state.membership?.id,
      isLoading: _processingActivityId == activity.id,
      onTap: () async {
        final result = await context.pushNamed<bool>(
          AppRoute.approvalDetail,
          extra: RouteParam(
            params: {
              'activityId': activity.id,
              'currentMembershipId': state.membership?.id,
            },
          ),
        );
        // Refresh the list if an action was taken in the detail screen
        if (result == true && mounted) {
          controller.refresh();
        }
      },
      onApprove: () async {
        if (currentUserApproverId != null && activity.id != null) {
          // Capture messenger before async gap
          final l10n = context.l10n;
          final messenger = ScaffoldMessenger.of(context);
          // Show confirmation bottom sheet
          final confirmed = await showApprovalConfirmationBottomSheet(
            context: context,
            isApprove: true,
            activityTitle: activity.title,
          );
          if (confirmed != true || !mounted) return;

          setState(() => _processingActivityId = activity.id);
          await controller.approveActivity(activity.id!, currentUserApproverId);
          if (mounted) {
            setState(() => _processingActivityId = null);
            messenger.showSnackBar(
              SnackBar(
                content: Text(l10n.approval_snackbarApproved(activity.title)),
                backgroundColor: AppColors.success.shade600,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
      onReject: () async {
        if (currentUserApproverId != null && activity.id != null) {
          // Capture messenger before async gap
          final l10n = context.l10n;
          final messenger = ScaffoldMessenger.of(context);
          // Show confirmation bottom sheet
          final confirmed = await showApprovalConfirmationBottomSheet(
            context: context,
            isApprove: false,
            activityTitle: activity.title,
          );
          if (confirmed != true || !mounted) return;

          setState(() => _processingActivityId = activity.id);
          await controller.rejectActivity(activity.id!, currentUserApproverId);
          if (mounted) {
            setState(() => _processingActivityId = null);
            messenger.showSnackBar(
              SnackBar(
                content: Text(l10n.approval_snackbarRejected(activity.title)),
                backgroundColor: AppColors.error.shade500,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
    );
  }

  int? _findCurrentUserApproverId(Activity activity, int? membershipId) {
    if (membershipId == null) return null;

    for (final approver in activity.approvers) {
      if (approver.membership?.id == membershipId &&
          approver.status == ApprovalStatus.unconfirmed) {
        return approver.id;
      }
    }
    return null;
  }

  Widget _buildEmptyContent(
    BuildContext context,
    ApprovalState state,
    ApprovalController controller,
    ColorScheme colors,
  ) {
    final shouldSuggestAll =
        state.statusFilter == ApprovalFilterStatus.pendingMyAction &&
        state.filteredApprovals.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (shouldSuggestAll) ...[
          InfoBoxWithActionWidget(
            message: context.l10n.approval_tryAllSuggestionMessage,
            actionText: context.l10n.approval_tryAllSuggestionAction,
            onActionPressed: () {
              controller.setStatusFilter(ApprovalFilterStatus.all);
            },
          ),
          Gap.h12,
        ],
        _buildEmptyState(context, colors),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colors) {
    return Material(
      color: AppColors.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: AppColors.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56.0,
              height: 56.0,
              decoration: BoxDecoration(
                color: colors.primary,
                border: Border.all(color: colors.surfaceContainerLowest),
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 12),
              ),
              alignment: Alignment.center,
              child: FaIcon(
                AppIcons.approval,
                size: 24.0,
                color: colors.onPrimary,
              ),
            ),
            Gap.h12,
            Text(
              context.l10n.approval_emptyTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            Gap.h4,
            Text(
              context.l10n.approval_emptySubtitle,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String message,
    ApprovalController controller,
  ) {
    return ErrorDisplayWidget(
      message: message,
      onRetry: () => controller.fetchData(),
      padding: EdgeInsets.zero,
    );
  }

  String _buildFilterSummary(BuildContext context, ApprovalState state) {
    return '${_statusLabel(context, state.statusFilter)} • ${state.datePreset.displayName}';
  }

  String _statusLabel(BuildContext context, ApprovalFilterStatus status) {
    switch (status) {
      case ApprovalFilterStatus.all:
        return context.l10n.approval_filterAll;
      case ApprovalFilterStatus.pendingMyAction:
        return context.l10n.approval_filterMyAction;
      case ApprovalFilterStatus.pendingOthers:
        return context.l10n.approval_filterPendingOthers;
      case ApprovalFilterStatus.approved:
        return context.l10n.status_approved;
      case ApprovalFilterStatus.rejected:
        return context.l10n.status_rejected;
    }
  }
}

class _CombinedFilterButton extends StatelessWidget {
  const _CombinedFilterButton({
    required this.activeFilterCount,
    required this.hasActiveFilters,
    required this.onTap,
  });

  final int activeFilterCount;
  final bool hasActiveFilters;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: hasActiveFilters ? colors.primary : AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: onTap,
        child: Container(
          width: 56.0,
          height: 56.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: hasActiveFilters
                  ? colors.primary.withValues(alpha: 0.32)
                  : AppColors.outlineVariant,
            ),
            boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 10),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Icon(
                  AppIcons.filterList,
                  size: 20.0,
                  color: hasActiveFilters ? colors.onPrimary : colors.primary,
                ),
              ),
              Positioned(
                right: -4.0,
                top: -4.0,
                child: Container(
                  constraints: BoxConstraints(minWidth: 22.0, minHeight: 22.0),
                  padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: hasActiveFilters
                        ? colors.onPrimary
                        : AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999.0),
                    border: Border.all(
                      color: hasActiveFilters
                          ? colors.primary.withValues(alpha: 0.18)
                          : AppColors.outlineVariant,
                    ),
                    boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$activeFilterCount',
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: hasActiveFilters
                          ? colors.primary
                          : colors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
