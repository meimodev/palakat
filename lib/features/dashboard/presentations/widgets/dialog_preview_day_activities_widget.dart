import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/models/activity_overview.dart';
import 'package:palakat/core/widgets/widgets.dart';

Future<void> showDialogPreviewDayActivitiesWidget({
  required BuildContext context,
  required void Function(ActivityOverview activityOverview)
      onPressedCardActivity,
  required List<ActivityOverview> data,
  required String title,
}) async {
  await showCustomDialogWidget(
    context: context,
    title: title,
    scrollControlled: true,
    content: _DialogPreviewDayActivitiesWidget(
      data: data,
      onPressedCard: onPressedCardActivity,
    ),
  );
}

class _DialogPreviewDayActivitiesWidget extends StatelessWidget {
  const _DialogPreviewDayActivitiesWidget({
    required this.data,
    required this.onPressedCard,
  });

  final List<ActivityOverview> data;
  final void Function(ActivityOverview activityOverview) onPressedCard;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: BaseSize.customHeight(300),
          ),
          child: ListView.separated(
            padding: EdgeInsets.symmetric(
              horizontal: BaseSize.w12,
            ),
            separatorBuilder: (_, __) => Gap.h12,
            itemCount: data.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final activity = data[index];
              return CardOverviewListItemWidget(
                title: activity.title,
                type: activity.type,
                onPressedCard: () => onPressedCard(activity),
              );
            },
          ),
        ),
      ],
    );
  }
}
