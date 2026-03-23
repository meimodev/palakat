import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat_shared/core/extension/extension.dart';

class PublishByYouWidget extends StatelessWidget {
  const PublishByYouWidget({
    super.key,
    required this.onPressedViewAll,
    required this.data,
    required this.onPressedCard,
  });

  final VoidCallback onPressedViewAll;
  final void Function(Activity activityOverview) onPressedCard;
  final List<Activity> data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentTitleWidget(
          onPressedViewAll: onPressedViewAll,
          count: data.length,
          title: l10n.publish_publishedByYou,
          leadingIcon: AppIcons.person,
          leadingBg: AppColors.secondary,
          leadingFg: AppColors.secondary,
        ),
        Gap.h12,
        if (data.isEmpty)
          Material(
            color: AppColors.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: BorderSide(color: AppColors.neutral, width: 1),
            ),
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56.0,
                    height: 56.0,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      AppIcons.publishOutlined,
                      size: 24.0,
                      color: AppColors.primary,
                    ),
                  ),
                  Gap.h12,
                  Text(
                    l10n.publish_noPublishedActivities,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Gap.h4,
                  Text(
                    l10n.publish_noPublishedActivitiesSubtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => Gap.h8,
            itemCount: data.length,
            itemBuilder: (context, index) {
              final activity = data[index];
              return CardOverviewListItemWidget(
                title: activity.title,
                type: activity.activityType,
                onPressedCard: () => onPressedCard(activity),
              );
            },
          ),
      ],
    );
  }
}
