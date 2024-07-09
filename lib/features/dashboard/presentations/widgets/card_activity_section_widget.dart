import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/models/models.dart' hide Column;
import 'package:palakat/core/utils/utils.dart';
import 'package:palakat/core/widgets/widgets.dart';

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
        Row(
          children: [
            Text(
              "$title ",
              style: today
                  ? BaseTypography.titleMedium.toBold
                  : BaseTypography.titleMedium,
            ),
            Text(
              activities.isNotEmpty ? "(${activities.length})" : "-",
              style: BaseTypography.bodySmall,
            ),
          ],
        ),
        Gap.h12,
        ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: BaseSize.w12),
          itemCount: activities.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (_, __) => Gap.h12,
          itemBuilder: (_, index) {
            final activity = activities[index];
            return CardOverviewListItemWidget(
              title: activity.title,
              type: activity.type,
              onPressedCard: () => onPressedCard(activity),
            );
          },
        ),
        Gap.h12,
      ],
    );
  }
}
