import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/models/activity_overview.dart';
import 'package:palakat/core/widgets/widgets.dart';

class PublishByYouWidget extends StatelessWidget {
  const PublishByYouWidget({
    super.key,
    required this.onPressedViewAll,
    required this.data,
    required this.onPressedCard,
  });

  final VoidCallback onPressedViewAll;
  final void Function(ActivityOverview activityOverview) onPressedCard;
  final List<ActivityOverview> data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentTitleWidget(
          onPressedViewAll: onPressedViewAll,
          count: data.length,
          title: 'Publish By You',
        ),
        Gap.h12,
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => Gap.h6,
          itemCount: data.length,
          itemBuilder: (context, index) {
            final activity = data[index];
            return CardOverviewListItemWidget(
              title: activity.title,
              type: activity.type,
              onPressedCard: () => onPressedCard(activity),
            );
          },
        ),
        Gap.h6,
      ],
    );
  }
}
