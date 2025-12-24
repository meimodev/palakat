import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/loading/shimmer_widgets.dart';
import 'package:palakat/features/operations/presentations/widgets/supervised_activity_item_widget.dart';
import 'package:palakat_shared/core/models/activity.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/widgets.dart';

/// Expandable card widget displaying supervised activities on the Operations screen.
/// Shows up to 3 most recent activities when expanded.
///
/// Features:
/// - Collapsible card with header that can be clicked to expand/collapse
/// - Displays list of up to 3 activity items when expanded
/// - Handles loading state with shimmer placeholder
/// - Handles error state with retry button
/// - Hides section when activities list is empty
///
/// Requirements: 1.1, 1.2, 1.3, 2.1, 4.1, 4.2
class SupervisedActivitiesSection extends StatelessWidget {
  const SupervisedActivitiesSection({
    super.key,
    required this.activities,
    required this.isLoading,
    required this.error,
    required this.isExpanded,
    required this.onExpansionChanged,
    required this.onSeeAllTap,
    required this.onActivityTap,
    required this.onRetry,
  });

  /// List of supervised activities to display (max 3)
  final List<Activity> activities;

  /// Whether the section is currently loading
  final bool isLoading;

  /// Error message if fetch failed, null if no error
  final String? error;

  /// Whether the card is currently expanded
  final bool isExpanded;

  /// Callback when the card expansion state changes
  final VoidCallback onExpansionChanged;

  /// Callback when "See All" button is tapped
  final VoidCallback onSeeAllTap;

  /// Callback when an activity item is tapped
  final ValueChanged<Activity> onActivityTap;

  /// Callback when retry button is tapped after error
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    // Hide section when not loading, no error, and activities list is empty
    // Requirement 1.2
    if (!isLoading && error == null && activities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: BaseColor.surfaceMedium,
        borderRadius: BorderRadius.circular(BaseSize.w16),
        boxShadow: [
          BoxShadow(
            color: BaseColor.shadow.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Expandable header
          _ExpandableHeader(
            isExpanded: isExpanded,
            activityCount: activities.length,
            onTap: onExpansionChanged,
            onSeeAllTap: onSeeAllTap,
            showSeeAll: !isLoading && error == null && activities.isNotEmpty,
          ),
          // Expandable content
          AnimatedCrossFade(
            firstChild: Padding(
              padding: EdgeInsets.only(
                left: BaseSize.w8,
                right: BaseSize.w8,
                bottom: BaseSize.w12,
              ),
              child: _buildContent(),
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    // Priority 1: Show error state with retry button
    // Requirement 4.2
    if (error != null && !isLoading) {
      return _ErrorState(message: error!, onRetry: onRetry);
    }

    // Priority 2: Show loading shimmer
    // Requirement 4.1
    if (isLoading) {
      return LoadingShimmer(isLoading: true, child: _buildShimmerPlaceholder());
    }

    // Priority 3: Show activities list
    // Requirement 1.1, 1.3
    return _ActivitiesList(
      activities: activities,
      onActivityTap: onActivityTap,
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Column(
      children: [
        PalakatShimmerPlaceholders.listItemCard(),
        Gap.h8,
        PalakatShimmerPlaceholders.listItemCard(),
        Gap.h8,
        PalakatShimmerPlaceholders.listItemCard(),
      ],
    );
  }
}

/// Expandable header with icon, title, count badge, and expand/collapse indicator
class _ExpandableHeader extends StatelessWidget {
  const _ExpandableHeader({
    required this.isExpanded,
    required this.activityCount,
    required this.onTap,
    required this.onSeeAllTap,
    required this.showSeeAll,
  });

  final bool isExpanded;
  final int activityCount;
  final VoidCallback onTap;
  final VoidCallback onSeeAllTap;
  final bool showSeeAll;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BaseColor.primary[50],
      child: InkWell(
        onTap: onTap,
        splashColor: BaseColor.primary.withValues(alpha: 0.1),
        highlightColor: BaseColor.primary.withValues(alpha: 0.05),
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w16),
          child: Row(
            children: [
              // Category icon
              Container(
                width: BaseSize.w40,
                height: BaseSize.w40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: BaseColor.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(BaseSize.w12),
                ),
                child: Icon(
                  AppIcons.event,
                  color: BaseColor.primary,
                  size: BaseSize.w24,
                ),
              ),
              Gap.w12,
              // Title
              Expanded(
                child: Text(
                  context.l10n.supervisedActivities_title,
                  style: BaseTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: BaseColor.textPrimary,
                  ),
                ),
              ),
              // "See All" button - only visible when expanded
              if (showSeeAll && isExpanded)
                TextButton(
                  onPressed: onSeeAllTap,
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
                    context.l10n.btn_viewAll,
                    style: BaseTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: BaseColor.primary[700],
                    ),
                  ),
                ),
              // Activity count badge
              if (!isExpanded)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: BaseSize.w8,
                    vertical: BaseSize.w4,
                  ),
                  decoration: BoxDecoration(
                    color: BaseColor.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(BaseSize.w12),
                  ),
                  child: Text(
                    '$activityCount',
                    style: BaseTypography.labelSmall.copyWith(
                      color: BaseColor.primary[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              // Expand/collapse icon with animation
              Gap.w8,
              AnimatedRotation(
                turns: isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  AppIcons.keyboardArrowDown,
                  color: BaseColor.primary,
                  size: BaseSize.w24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// List of activity items
class _ActivitiesList extends StatelessWidget {
  const _ActivitiesList({
    required this.activities,
    required this.onActivityTap,
  });

  final List<Activity> activities;
  final ValueChanged<Activity> onActivityTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < activities.length; i++) ...[
          SupervisedActivityItemWidget(
            activity: activities[i],
            onTap: () => onActivityTap(activities[i]),
          ),
          if (i < activities.length - 1) Gap.h8,
        ],
      ],
    );
  }
}

/// Error state with retry button
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BaseColor.red[50],
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: BaseColor.red[200]!, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(BaseSize.w16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: BaseSize.w32,
                  height: BaseSize.w32,
                  decoration: BoxDecoration(
                    color: BaseColor.red[100],
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    AppIcons.error,
                    size: BaseSize.w16,
                    color: BaseColor.red[700],
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.l10n.error_loadingActivities,
                        style: BaseTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: BaseColor.red[900],
                        ),
                      ),
                      Gap.h4,
                      Text(
                        message,
                        style: BaseTypography.bodySmall.copyWith(
                          color: BaseColor.red[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Gap.h12,
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: Icon(AppIcons.refresh, size: BaseSize.w14),
              label: Text(context.l10n.btn_retry),
              style: OutlinedButton.styleFrom(
                foregroundColor: BaseColor.red[700],
                side: BorderSide(color: BaseColor.red[300]!, width: 1),
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
        ),
      ),
    );
  }
}
