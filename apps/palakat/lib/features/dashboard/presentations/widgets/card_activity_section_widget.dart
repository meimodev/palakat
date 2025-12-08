import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;

class CardActivitySectionWidget extends StatelessWidget {
  const CardActivitySectionWidget({
    super.key,
    required this.title,
    required this.activities,
    this.today = false,
    required this.onPressedCard,
  });

  final String title;
  final List<Activity> activities;
  final bool today;
  final void Function(Activity activityOverview) onPressedCard;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section header with badge
        Row(
          children: [
            Flexible(
              child: Text(
                title,
                style: BaseTypography.titleMedium.copyWith(
                  fontWeight: today ? FontWeight.bold : FontWeight.w600,
                  color: BaseColor.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Gap.w8,
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: BaseSize.w10,
                vertical: BaseSize.h4,
              ),
              decoration: BoxDecoration(
                color: today ? BaseColor.teal[100] : BaseColor.teal[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: today ? BaseColor.teal[300]! : BaseColor.teal[200]!,
                  width: 1,
                ),
              ),
              child: Text(
                activities.length.toString(),
                style: BaseTypography.labelMedium.copyWith(
                  color: BaseColor.teal[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        Gap.h12,
        // List of activities
        if (activities.isEmpty)
          Container(
            padding: EdgeInsets.all(BaseSize.w16),
            decoration: BoxDecoration(
              color: BaseColor.cardBackground1,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: BaseColor.neutral20, width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(
                  AppIcons.eventBusy,
                  size: BaseSize.w24,
                  color: BaseColor.secondaryText,
                ),
                Gap.h8,
                Text(
                  "No activities",
                  textAlign: TextAlign.center,
                  style: BaseTypography.bodySmall.copyWith(
                    color: BaseColor.secondaryText,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: activities.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, _) => Gap.h8,
            itemBuilder: (_, index) {
              final activity = activities[index];
              return CardOverviewListItemWidget(
                title: activity.title,
                type: activity.activityType,
                onPressedCard: () => onPressedCard(activity),
              );
            },
          ),
        Gap.h16,
      ],
    );
  }
}
