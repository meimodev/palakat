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
            padding: EdgeInsets.all(BaseSize.w12),
            decoration: BoxDecoration(
              color: hasActivity ? BaseColor.blue[50] : BaseColor.white,
              borderRadius: BorderRadius.circular(BaseSize.radiusMd),
              border: Border.all(
                color: hasError
                    ? BaseColor.error.withValues(alpha: 0.5)
                    : hasActivity
                    ? BaseColor.blue[200]!
                    : BaseColor.neutral[300]!,
              ),
            ),
            child: hasActivity
                ? _buildSelectedActivityInfo()
                : _buildEmptyPlaceholder(context),
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: BaseSize.customHeight(3)),
            child: Text(
              errorText!,
              textAlign: TextAlign.center,
              style: BaseTypography.bodySmall.copyWith(color: BaseColor.error),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyPlaceholder(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(BaseSize.w8),
          decoration: BoxDecoration(
            color: BaseColor.neutral[100],
            borderRadius: BorderRadius.circular(BaseSize.radiusSm),
          ),
          child: FaIcon(
            AppIcons.event,
            size: BaseSize.w20,
            color: BaseColor.neutral[500],
          ),
        ),
        Gap.w12,
        Expanded(
          child: Text(
            context.l10n.hint_selectActivity,
            style: BaseTypography.bodyMedium.copyWith(
              color: BaseColor.neutral[500],
            ),
          ),
        ),
        FaIcon(
          AppIcons.forward,
          size: BaseSize.w20,
          color: BaseColor.neutral[400],
        ),
      ],
    );
  }

  Widget _buildSelectedActivityInfo() {
    final activity = selectedActivity!;
    final dateStr = Jiffy.parseFromDateTime(
      activity.date,
    ).format(pattern: 'dd MMM yyyy');

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(BaseSize.w8),
          decoration: BoxDecoration(
            color: BaseColor.blue[100],
            borderRadius: BorderRadius.circular(BaseSize.radiusSm),
          ),
          child: FaIcon(
            AppIcons.event,
            size: BaseSize.w20,
            color: BaseColor.blue[600],
          ),
        ),
        Gap.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.title,
                style: BaseTypography.bodyMedium.copyWith(
                  color: BaseColor.blue[700],
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Gap.h4,
              Row(
                children: [
                  FaIcon(
                    AppIcons.calendar,
                    size: BaseSize.w12,
                    color: BaseColor.blue[600],
                  ),
                  Gap.w4,
                  Text(
                    dateStr,
                    style: BaseTypography.bodySmall.copyWith(
                      color: BaseColor.blue[600],
                    ),
                  ),
                  Gap.w8,
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: BaseSize.w6,
                      vertical: BaseSize.customHeight(2),
                    ),
                    decoration: BoxDecoration(
                      color: BaseColor.blue[100],
                      borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                    ),
                    child: Text(
                      activity.activityType.displayName,
                      style: BaseTypography.bodySmall.copyWith(
                        color: BaseColor.blue[700],
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        FaIcon(AppIcons.edit, size: BaseSize.w18, color: BaseColor.blue[600]),
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
