import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/loading/shimmer_widgets.dart';
import 'package:palakat/features/operations/presentations/widgets/supervised_activity_item_widget.dart';
import 'package:palakat_shared/core/models/activity.dart';
import 'package:palakat_shared/widgets.dart';

/// Section widget displaying supervised activities on the Operations screen.
/// Shows up to 3 most recent activities with a "See All" button.
///
/// Features:
/// - Displays section header with title and "See All" button
/// - Shows list of up to 3 activity items
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Section header with title and "See All" button
        _SectionHeader(
          onSeeAllTap: onSeeAllTap,
          showSeeAll: !isLoading && error == null && activities.isNotEmpty,
        ),
        Gap.h4,
        // Content: loading, error, or activities list
        _buildContent(),
      ],
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

/// Section header with title and "See All" button
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.onSeeAllTap, required this.showSeeAll});

  final VoidCallback onSeeAllTap;
  final bool showSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Section title
        Text(
          'Supervised Activities',
          style: BaseTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: BaseColor.textPrimary,
          ),
        ),
        // "See All" button - Requirement 2.1
        if (showSeeAll)
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'See All',
                  style: BaseTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: BaseColor.primary[700],
                  ),
                ),
                Gap.w4,
                Icon(
                  AppIcons.arrowForwardIos,
                  size: BaseSize.w12,
                  color: BaseColor.primary[700],
                ),
              ],
            ),
          ),
      ],
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
    return Material(
      color: BaseColor.surfaceMedium,
      elevation: 1,
      shadowColor: BaseColor.shadow.withValues(alpha: 0.05),
      surfaceTintColor: BaseColor.primary[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: EdgeInsets.all(BaseSize.w8),
        child: Column(
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
        ),
      ),
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
                        'Failed to load activities',
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
              label: const Text('Retry'),
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
