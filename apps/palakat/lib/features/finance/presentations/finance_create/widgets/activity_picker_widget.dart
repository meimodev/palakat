import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/features/finance/presentations/finance_create/widgets/activity_picker_dialog.dart';
import 'package:palakat_shared/core/models/activity.dart';
import 'package:palakat_shared/core/extension/extension.dart';

/// Widget for selecting an activity in standalone finance creation mode.
/// Displays placeholder when no activity selected, or activity info when selected.
/// Requirements: 4.1, 4.3
class ActivityPickerWidget extends StatelessWidget {
  const ActivityPickerWidget({
    required this.selectedActivity,
    required this.onActivitySelected,
    this.errorText,
    super.key,
  });

  /// The currently selected activity, or null if none selected
  final Activity? selectedActivity;

  /// Callback when an activity is selected
  final ValueChanged<Activity?> onActivitySelected;

  /// Error text to display below the picker
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final hasActivity = selectedActivity != null;
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () => _openActivityPicker(context),
          child: Container(
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: hasActivity
                  ? AppColors.primary.withValues(alpha: 0.05)
                  : AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: hasError
                    ? AppColors.error.withValues(alpha: 0.5)
                    : hasActivity
                    ? AppColors.primary.withValues(alpha: 0.18)
                    : AppColors.outlineVariant,
              ),
            ),
            child: hasActivity
                ? _buildSelectedActivityInfo(context)
                : _buildEmptyPlaceholder(context),
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: 3),
            child: Text(
              errorText!,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyPlaceholder(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            border: Border.all(color: AppColors.ghostBorder(0.08)),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: FaIcon(
            AppIcons.event,
            size: 20.0,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Gap.w12,
        Expanded(
          child: Text(
            context.l10n.hint_selectActivity,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ),
        FaIcon(AppIcons.forward, size: 20.0, color: AppColors.onSurfaceVariant),
      ],
    );
  }

  Widget _buildSelectedActivityInfo(BuildContext context) {
    final activity = selectedActivity!;
    final dateStr = Jiffy.parseFromDateTime(
      activity.date,
    ).format(pattern: 'dd MMM yyyy');

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.18),
            ),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: FaIcon(AppIcons.event, size: 20.0, color: AppColors.primary),
        ),
        Gap.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.title,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Gap.h4,
              Wrap(
                spacing: 8.0,
                runSpacing: 6.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(
                        AppIcons.calendar,
                        size: 14.0,
                        color: AppColors.primary,
                      ),
                      Gap.w6,
                      Text(
                        dateStr,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.18),
                      ),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(
                      activity.activityType.displayName,
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        FaIcon(AppIcons.edit, size: 20.0, color: AppColors.primary),
      ],
    );
  }

  Future<void> _openActivityPicker(BuildContext context) async {
    final result = await showActivityPickerDialog(context: context);
    if (result != null) {
      onActivitySelected(result);
    }
  }
}
