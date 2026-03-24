import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
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
      return _buildFallbackDialog(
        context: context,
        child: LoadingShimmer(
          isLoading: true,
          child: PalakatShimmerPlaceholders.listSection(),
        ),
      );
    }

    if (state.errorMessage != null && state.activities.isEmpty) {
      return _buildFallbackDialog(
        context: context,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.error_outline,
                size: 22,
                color: AppColors.error,
              ),
            ),
            Gap.h16,
            Text(
              l10n.err_error,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            Gap.h4,
            Text(
              state.errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
              textAlign: TextAlign.center,
            ),
            Gap.h16,
            OutlinedButton.icon(
              onPressed: () => ref
                  .read(activityPickerControllerProvider.notifier)
                  .fetchActivities(refresh: true),
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(l10n.btn_retry),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(
                  color: AppColors.error.withValues(alpha: 0.28),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
                ),
              ),
            ),
          ],
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

  Widget _buildFallbackDialog({
    required BuildContext context,
    required Widget child,
  }) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Material(
          color: Colors.transparent,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
            side: BorderSide(color: AppColors.ghostBorder(0.08)),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
              boxShadow: SanctuaryDepth.ambient(opacity: 0.04, blur: 22),
            ),
            child: Padding(padding: const EdgeInsets.all(24), child: child),
          ),
        ),
      ),
    );
  }
}

/// List item widget for displaying an activity in the picker.
class _ActivityListItem extends StatelessWidget {
  const _ActivityListItem({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = Jiffy.parseFromDateTime(
      activity.date,
    ).format(pattern: 'dd MMM yyyy, HH:mm');
    final activityTypeColor = _getActivityTypeColor();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: activityTypeColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
            ),
            alignment: Alignment.center,
            child: FaIcon(
              _getActivityTypeIcon(),
              size: 16,
              color: activityTypeColor,
            ),
          ),
          Gap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Gap.h4,
                Row(
                  children: [
                    FaIcon(
                      AppIcons.calendar,
                      size: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    Gap.w4,
                    Expanded(
                      child: Text(
                        dateStr,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Gap.h4,
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: activityTypeColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
                  ),
                  child: Text(
                    activity.activityType.displayName,
                    style: theme.textTheme.labelMedium!.copyWith(
                      color: activityTypeColor,
                      fontWeight: FontWeight.w600,
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
        return AppColors.primary;
      case 'event':
        return AppColors.secondary;
      case 'announcement':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }
}
