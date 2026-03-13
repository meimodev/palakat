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
          leadingBg: BaseColor.teal[50],
          leadingFg: BaseColor.teal[700],
        ),
        Gap.h12,
        if (data.isEmpty)
          Material(
            color: BaseColor.surfaceMedium,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(BaseSize.radiusLg),
              side: BorderSide(color: BaseColor.neutral[200]!, width: 1),
            ),
            child: Padding(
              padding: EdgeInsets.all(BaseSize.w24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: BaseSize.w56,
                    height: BaseSize.w56,
                    decoration: BoxDecoration(
                      color: BaseColor.primary[50],
                      borderRadius: BorderRadius.circular(BaseSize.radiusLg),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      AppIcons.publishOutlined,
                      size: BaseSize.w24,
                      color: BaseColor.primary,
                    ),
                  ),
                  Gap.h12,
                  Text(
                    l10n.publish_noPublishedActivities,
                    textAlign: TextAlign.center,
                    style: BaseTypography.titleMedium.copyWith(
                      color: BaseColor.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Gap.h4,
                  Text(
                    l10n.publish_noPublishedActivitiesSubtitle,
                    textAlign: TextAlign.center,
                    style: BaseTypography.bodyMedium.copyWith(
                      color: BaseColor.textSecondary,
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
