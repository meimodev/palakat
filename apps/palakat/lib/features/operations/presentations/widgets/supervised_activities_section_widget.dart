import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/operations/presentations/widgets/supervised_activity_item_widget.dart';
import 'package:palakat_shared/core/models/activity.dart';
import 'package:palakat_shared/core/extension/extension.dart';

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

    return Material(
      color: AppColors.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: AppColors.neutral, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SectionHeader(
            activityCount: activities.length,
            onSeeAllTap: onSeeAllTap,
            showSeeAll: !isLoading && error == null && activities.isNotEmpty,
          ),
          Padding(
            padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 10.0),
            child: _buildContent(),
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
    return PalakatShimmerPlaceholders.listSection();
  }
}

/// Expandable header with icon, title, count badge, and expand/collapse indicator
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.activityCount,
    required this.onSeeAllTap,
    required this.showSeeAll,
  });

  final int activityCount;
  final VoidCallback onSeeAllTap;
  final bool showSeeAll;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainer,
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 36.0,
              height: 36.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 8),
              ),
              child: Icon(AppIcons.event, color: AppColors.primary, size: 20.0),
            ),
            Gap.w10,
            Expanded(
              child: Text(
                context.l10n.supervisedActivities_title,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ),

            if (showSeeAll) ...[
              Gap.w8,
              TextButton(
                onPressed: onSeeAllTap,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  context.l10n.btn_viewAll,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
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
          if (i < activities.length - 1) Gap.h6,
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
    return ErrorDisplayWidget(
      message: message,
      onRetry: onRetry,
      padding: EdgeInsets.zero,
    );
  }
}
