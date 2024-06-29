import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/models/models.dart';
import 'package:palakat/core/widgets/widgets.dart';

Future<void> showDialogPreviewDayActivitiesWidget({
  required BuildContext context,
  required void Function(Activity activity)
      onPressedCardActivity,
  required List<Activity> data,
  required String title,
}) async {
  await showDialogCustomWidget(
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

  final List<Activity> data;
  final void Function(Activity activityOverview) onPressedCard;

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
