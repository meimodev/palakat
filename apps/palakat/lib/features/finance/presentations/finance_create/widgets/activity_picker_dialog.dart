import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jiffy/jiffy.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat_shared/core/models/activity.dart';
import 'package:palakat_shared/core/models/request/get_fetch_activity_request.dart';
import 'package:palakat_shared/core/models/request/pagination_request_wrapper.dart';
import 'package:palakat_shared/core/repositories/activity_repository.dart';
import 'package:palakat_shared/services.dart';

/// Shows a dialog for selecting an activity from the user's supervised activities.
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
  Timer? _debounce;
  List<Activity> _activities = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchActivities() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get current membership to filter by supervisor
      final localStorage = ref.read(localStorageServiceProvider);
      final membership = localStorage.currentMembership;

      if (membership == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Session expired. Please sign in again.';
        });
        return;
      }

      final activityRepository = ref.read(activityRepositoryProvider);

      // Create request with membershipId to get supervised activities
      final request = PaginationRequestWrapper(
        page: 1,
        pageSize: 100,
        data: GetFetchActivitiesRequest(
          membershipId: membership.id,
          search: _searchQuery.isNotEmpty ? _searchQuery : null,
        ),
      );

      final result = await activityRepository.fetchActivities(
        paginationRequest: request,
      );

      if (!mounted) return;

      result.when(
        onSuccess: (response) {
          setState(() {
            _activities = response.data;
            _isLoading = false;
          });
        },
        onFailure: (failure) {
          setState(() {
            _isLoading = false;
            _errorMessage = failure.message;
          });
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load activities';
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      // Hide keyboard after debounce
      FocusScope.of(context).unfocus();
      setState(() => _searchQuery = query);
      _fetchActivities();
    });
  }

  @override
  Widget build(BuildContext context) {
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
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
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
              _errorMessage!,
              style: BaseTypography.bodyMedium.copyWith(color: BaseColor.error),
              textAlign: TextAlign.center,
            ),
            Gap.h16,
            TextButton(onPressed: _fetchActivities, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_activities.isEmpty) {
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
              _searchQuery.isNotEmpty
                  ? 'No activities found for "$_searchQuery"'
                  : 'No activities found',
              style: BaseTypography.bodyMedium.toSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: _activities.length,
      separatorBuilder: (context, index) => Gap.h8,
      itemBuilder: (context, index) {
        final activity = _activities[index];
        return _ActivityCard(
          activity: activity,
          onPressed: () => context.pop<Activity>(activity),
        );
      },
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
