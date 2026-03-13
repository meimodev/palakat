import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/approval/presentations/approval_controller.dart';
import 'package:palakat/features/approval/presentations/approval_state.dart';
import 'package:palakat/features/approval/presentations/widgets/approval_card_widget.dart';
import 'package:palakat/features/approval/presentations/widgets/approval_confirmation_bottom_sheet.dart';
import 'package:palakat/features/approval/presentations/widgets/pending_action_badge.dart';
import 'package:palakat/features/approval/presentations/widgets/status_filter_chips.dart';
import 'package:palakat/core/constants/constants.dart';
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

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      child: RefreshIndicator(
        onRefresh: () => controller.refresh(),
        color: BaseColor.teal.shade500,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ScreenTitleWidget.titleOnly(title: l10n.approval_title),
                  Gap.h16,
                  // Pending action summary badge
                  PendingActionBadge(count: state.pendingMyAction.length),
                  Gap.h16,
                  // Status filter chips
                  StatusFilterChips(
                    selectedFilter: state.statusFilter,
                    onFilterChanged: (filter) {
                      controller.setStatusFilter(filter);
                    },
                    pendingMyActionCount: state.pendingMyAction.length,
                    pendingOthersCount: state.pendingOthers.length,
                    approvedCount: state.approved.length,
                    rejectedCount: state.rejected.length,
                  ),
                  Gap.h16,
                  // Date range filter
                  DateRangePresetInput(
                    label: l10n.approval_filterByDate,
                    start: state.filterStartDate,
                    end: state.filterEndDate,
                    onChanged: (s, e) {
                      if (s == null && e == null) {
                        controller.clearDateFilter();
                      } else {
                        controller.setDateRange(start: s, end: e);
                      }
                    },
                  ),
                  Gap.h16,
                ],
              ),
            ),
            // Approvals list
            _buildApprovalsList(context, state, controller),
            // Loading more indicator
            if (state.isLoadingMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: BaseSize.h16),
                  child: Center(
                    child: SizedBox(
                      width: BaseSize.w24,
                      height: BaseSize.w24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: BaseColor.teal.shade500,
                      ),
                    ),
                  ),
                ),
              ),
            // End of list indicator
            if (!state.hasMoreData && state.allActivities.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: BaseSize.h16),
                  child: Center(
                    child: Text(
                      l10n.approval_noMoreApprovals,
                      style: BaseTypography.bodySmall.copyWith(
                        color: BaseColor.secondaryText,
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

  Widget _buildApprovalsList(
    BuildContext context,
    ApprovalState state,
    ApprovalController controller,
  ) {
    if (state.loadingScreen) {
      return SliverToBoxAdapter(
        child: Column(
          children: [
            PalakatShimmerPlaceholders.approvalCard(),
            Gap.h20,
            PalakatShimmerPlaceholders.approvalCard(),
            Gap.h20,
            PalakatShimmerPlaceholders.approvalCard(),
          ],
        ),
      );
    }

    if (state.errorMessage != null) {
      return SliverToBoxAdapter(
        child: _buildErrorState(context, state.errorMessage!, controller),
      );
    }

    // When showing all, display grouped sections
    if (state.statusFilter == ApprovalFilterStatus.all) {
      return _buildGroupedList(context, state, controller);
    }

    // When filtering by specific status, show flat list
    return _buildFlatList(context, state.filteredApprovals, state, controller);
  }

  Widget _buildGroupedList(
    BuildContext context,
    ApprovalState state,
    ApprovalController controller,
  ) {
    final sections = <Widget>[];

    // Pending My Action section (shown first for prioritization)
    if (state.pendingMyAction.isNotEmpty) {
      sections.add(
        _buildSection(
          context,
          context.l10n.approval_sectionPendingYourAction,
          state.pendingMyAction,
          state,
          controller,
          icon: AppIcons.pending,
          color: BaseColor.teal,
        ),
      );
    }

    // Pending Others section
    if (state.pendingOthers.isNotEmpty) {
      sections.add(
        _buildSection(
          context,
          context.l10n.approval_sectionPendingOthers,
          state.pendingOthers,
          state,
          controller,
          icon: AppIcons.inProgress,
          color: BaseColor.yellow,
        ),
      );
    }

    // Approved section
    if (state.approved.isNotEmpty) {
      sections.add(
        _buildSection(
          context,
          context.l10n.status_approved,
          state.approved,
          state,
          controller,
          icon: AppIcons.success,
          color: BaseColor.green,
        ),
      );
    }

    // Rejected section
    if (state.rejected.isNotEmpty) {
      sections.add(
        _buildSection(
          context,
          context.l10n.status_rejected,
          state.rejected,
          state,
          controller,
          icon: AppIcons.reject,
          color: BaseColor.red,
        ),
      );
    }

    if (sections.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState(context));
    }

    return SliverList(delegate: SliverChildListDelegate(sections));
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Activity> activities,
    ApprovalState state,
    ApprovalController controller, {
    required IconData icon,
    required MaterialColor color,
  }) {
    // Apply date filter to section activities
    final filteredActivities = _applyDateFilter(
      activities,
      state.filterStartDate,
      state.filterEndDate,
    );

    if (filteredActivities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(bottom: BaseSize.h16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              FaIcon(icon, size: BaseSize.w20, color: color.shade600),
              Gap.w8,
              Text(
                title,
                style: BaseTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: BaseColor.textPrimary,
                ),
              ),
              Gap.w8,
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: BaseSize.w8,
                  vertical: BaseSize.h4,
                ),
                decoration: BoxDecoration(
                  color: color.shade100,
                  borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                ),
                child: Text(
                  filteredActivities.length.toString(),
                  style: BaseTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color.shade700,
                  ),
                ),
              ),
            ],
          ),
          Gap.h12,
          // Activity cards
          ...filteredActivities.map(
            (activity) => Padding(
              padding: EdgeInsets.only(bottom: BaseSize.h20),
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
  ) {
    if (activities.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState(context));
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final activity = activities[index];
        return Padding(
          padding: EdgeInsets.only(bottom: BaseSize.h20),
          child: _buildActivityCard(context, activity, state, controller),
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
                backgroundColor: BaseColor.green.shade600,
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
                backgroundColor: BaseColor.red.shade500,
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

  List<Activity> _applyDateFilter(
    List<Activity> activities,
    DateTime? start,
    DateTime? end,
  ) {
    if (start == null && end == null) return activities;

    return activities.where((a) {
      final activityDate = a.createdAt;
      final sOk =
          start == null ||
          !activityDate.isBefore(DateTime(start.year, start.month, start.day));
      final eOk =
          end == null ||
          !activityDate.isAfter(
            DateTime(end.year, end.month, end.day, 23, 59, 59, 999),
          );
      return sOk && eOk;
    }).toList();
  }

  Widget _buildEmptyState(BuildContext context) {
    return Material(
      color: BaseColor.surfaceMedium,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BaseSize.radiusLg),
        side: BorderSide(color: BaseColor.neutral[200]!, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(BaseSize.w24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: BaseSize.w56,
              height: BaseSize.w56,
              decoration: BoxDecoration(
                color: BaseColor.primary[50],
                borderRadius: BorderRadius.circular(BaseSize.radiusLg),
              ),
              alignment: Alignment.center,
              child: FaIcon(
                AppIcons.approval,
                size: BaseSize.w24,
                color: BaseColor.primary,
              ),
            ),
            Gap.h12,
            Text(
              context.l10n.approval_emptyTitle,
              textAlign: TextAlign.center,
              style: BaseTypography.titleMedium.copyWith(
                color: BaseColor.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            Gap.h4,
            Text(
              context.l10n.approval_emptySubtitle,
              textAlign: TextAlign.center,
              style: BaseTypography.bodyMedium.copyWith(
                color: BaseColor.textSecondary,
              ),
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
}
