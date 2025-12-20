import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/features/finance/presentations/finance_create/widgets/activity_picker_controller.dart';
import 'package:palakat_shared/core/models/activity.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/widgets/searchable_dialog_picker.dart';

/// Shows a dialog for selecting an activity from the user's supervised activities.
/// Activities are searchable and sorted by date descending.
/// Requirements: 4.2
Future<Activity?> showActivityPickerDialog({required BuildContext context}) {
  return showDialog<Activity?>(
    context: context,
    builder: (context) => const _ActivityPickerDialog(),
  );
}

class _ActivityPickerDialog extends ConsumerWidget {
  const _ActivityPickerDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activityPickerControllerProvider);
    final l10n = context.l10n;

    if (state.isLoading && state.activities.isEmpty) {
      return const Dialog(
        child: SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (state.errorMessage != null && state.activities.isEmpty) {
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error, size: 48, color: BaseColor.error),
              const SizedBox(height: 16),
              Text(
                state.errorMessage!,
                style: TextStyle(color: BaseColor.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => ref
                    .read(activityPickerControllerProvider.notifier)
                    .fetchActivities(refresh: true),
                child: Text(l10n.btn_retry),
              ),
            ],
          ),
        ),
      );
    }

    return SearchableDialogPicker<Activity>(
      title: l10n.lbl_activity,
      searchHint: l10n.hint_searchByTitleDescription,
      items: state.activities,
      itemBuilder: (activity) => _ActivityListItem(activity: activity),
      onFilter: (activity, query) =>
          activity.title.toLowerCase().contains(query) ||
          (activity.description?.toLowerCase().contains(query) ?? false),
      emptyStateMessage: state.searchQuery.isNotEmpty
          ? l10n.lbl_noResultsFor(state.searchQuery)
          : l10n.noData_results,
    );
  }
}

/// List item widget for displaying an activity in the picker.
class _ActivityListItem extends StatelessWidget {
  const _ActivityListItem({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final dateStr = Jiffy.parseFromDateTime(
      activity.date,
    ).format(pattern: 'dd MMM yyyy, HH:mm');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Activity type icon
          Container(
            padding: EdgeInsets.all(BaseSize.w8),
            decoration: BoxDecoration(
              color: _getActivityTypeColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(BaseSize.radiusSm),
            ),
            child: FaIcon(
              _getActivityTypeIcon(),
              size: BaseSize.w16,
              color: _getActivityTypeColor(),
            ),
          ),
          const SizedBox(width: 12),
          // Activity info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    FaIcon(
                      AppIcons.calendar,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        dateStr,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getActivityTypeColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                  ),
                  child: Text(
                    activity.activityType.displayName,
                    style: TextStyle(
                      color: _getActivityTypeColor(),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActivityTypeIcon() {
    switch (activity.activityType.name) {
      case 'service':
        return AppIcons.church;
      case 'event':
        return AppIcons.event;
      case 'announcement':
        return AppIcons.announcement;
      default:
        return AppIcons.event;
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
