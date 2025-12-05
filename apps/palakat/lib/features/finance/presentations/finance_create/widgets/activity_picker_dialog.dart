import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jiffy/jiffy.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/finance/presentations/finance_create/widgets/activity_picker_controller.dart';
import 'package:palakat_shared/core/models/activity.dart';

/// Shows a dialog for selecting an activity from the user's supervised activities.
/// Activities are paginated with infinite scrolling and sorted by date descending.
/// Requirements: 4.2
Future<Activity?> showActivityPickerDialog({required BuildContext context}) {
  return showDialogCustomWidget<Activity?>(
    context: context,
    title: 'Select Activity',
    scrollControlled: false,
    content: const Expanded(child: _ActivityPickerDialogContent()),
  );
}

class _ActivityPickerDialogContent extends ConsumerStatefulWidget {
  const _ActivityPickerDialogContent();

  @override
  ConsumerState<_ActivityPickerDialogContent> createState() =>
      _ActivityPickerDialogContentState();
}

class _ActivityPickerDialogContentState
    extends ConsumerState<_ActivityPickerDialogContent> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// Handles scroll events for infinite scrolling.
  /// Triggers loading more activities when near the bottom.
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(activityPickerControllerProvider.notifier).loadMoreActivities();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      // Hide keyboard after debounce
      FocusScope.of(context).unfocus();
      ref.read(activityPickerControllerProvider.notifier).setSearchQuery(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activityPickerControllerProvider);
    final controller = ref.read(activityPickerControllerProvider.notifier);

    return Column(
      children: [
        // Search field
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: BaseSize.w16,
            vertical: BaseSize.h8,
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search activities...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(BaseSize.radiusMd),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: BaseSize.w16,
                vertical: BaseSize.h12,
              ),
            ),
          ),
        ),
        Gap.h8,
        // Activity list
        Expanded(child: _buildContent(state, controller)),
      ],
    );
  }

  Widget _buildContent(state, controller) {
    if (state.isLoading && state.activities.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: BaseSize.w48,
              color: BaseColor.error,
            ),
            Gap.h12,
            Text(
              state.errorMessage!,
              style: BaseTypography.bodyMedium.copyWith(color: BaseColor.error),
              textAlign: TextAlign.center,
            ),
            Gap.h16,
            TextButton(
              onPressed: () => controller.fetchActivities(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy_outlined,
              size: BaseSize.w48,
              color: BaseColor.neutral[400],
            ),
            Gap.h12,
            Text(
              state.searchQuery.isNotEmpty
                  ? 'No activities found for "${state.searchQuery}"'
                  : 'No activities found',
              style: BaseTypography.bodyMedium.toSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      itemCount: state.activities.length + (state.hasMorePages ? 1 : 0),
      separatorBuilder: (context, index) => Gap.h8,
      itemBuilder: (context, index) {
        // Show loading indicator at the bottom when loading more
        if (index == state.activities.length) {
          return _buildLoadingMoreIndicator(state.isLoadingMore);
        }

        final activity = state.activities[index];
        return _ActivityCard(
          activity: activity,
          onPressed: () => context.pop<Activity>(activity),
        );
      },
    );
  }

  Widget _buildLoadingMoreIndicator(bool isLoadingMore) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: BaseSize.h16),
      child: Center(
        child: isLoadingMore
            ? SizedBox(
                width: BaseSize.w24,
                height: BaseSize.w24,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

/// Card widget for displaying an activity in the picker list.
class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity, required this.onPressed});

  final Activity activity;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final dateStr = Jiffy.parseFromDateTime(
      activity.date,
    ).format(pattern: 'dd MMM yyyy, HH:mm');

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      child: Container(
        padding: EdgeInsets.all(BaseSize.w12),
        decoration: BoxDecoration(
          color: BaseColor.white,
          borderRadius: BorderRadius.circular(BaseSize.radiusMd),
          border: Border.all(color: BaseColor.neutral[200]!),
        ),
        child: Row(
          children: [
            // Activity type icon
            Container(
              padding: EdgeInsets.all(BaseSize.w10),
              decoration: BoxDecoration(
                color: _getActivityTypeColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(BaseSize.radiusSm),
              ),
              child: Icon(
                _getActivityTypeIcon(),
                size: BaseSize.w20,
                color: _getActivityTypeColor(),
              ),
            ),
            Gap.w12,
            // Activity info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: BaseTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: BaseColor.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Gap.h4,
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: BaseSize.w12,
                        color: BaseColor.neutral[500],
                      ),
                      Gap.w4,
                      Expanded(
                        child: Text(
                          dateStr,
                          style: BaseTypography.bodySmall.copyWith(
                            color: BaseColor.neutral[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap.h4,
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: BaseSize.w6,
                      vertical: BaseSize.customHeight(2),
                    ),
                    decoration: BoxDecoration(
                      color: _getActivityTypeColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                    ),
                    child: Text(
                      activity.activityType.displayName,
                      style: BaseTypography.bodySmall.copyWith(
                        color: _getActivityTypeColor(),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Chevron
            Icon(
              Icons.chevron_right,
              size: BaseSize.w20,
              color: BaseColor.neutral[400],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getActivityTypeIcon() {
    switch (activity.activityType.name) {
      case 'service':
        return Icons.church_outlined;
      case 'event':
        return Icons.event_outlined;
      case 'announcement':
        return Icons.campaign_outlined;
      default:
        return Icons.event_outlined;
    }
  }

  Color _getActivityTypeColor() {
    switch (activity.activityType.name) {
      case 'service':
        return BaseColor.primary[600]!;
      case 'event':
        return BaseColor.teal[600]!;
      case 'announcement':
        return BaseColor.yellow[600]!;
      default:
        return BaseColor.primary[600]!;
    }
  }
}
