import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;
import 'package:palakat/core/widgets/widgets.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentTitleWidget(
          onPressedViewAll: onPressedViewAll,
          count: data.length,
          title: 'Published By You',
          leadingIcon: AppIcons.person,
          leadingBg: BaseColor.teal[50],
          leadingFg: BaseColor.teal[700],
        ),
        Gap.h12,
        if (data.isEmpty)
          Container(
            padding: EdgeInsets.all(BaseSize.w24),
            decoration: BoxDecoration(
              color: BaseColor.cardBackground1,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: BaseColor.neutral20, width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  AppIcons.publishOutlined,
                  size: BaseSize.w48,
                  color: BaseColor.secondaryText,
                ),
                Gap.h12,
                Text(
                  "No published activities",
                  textAlign: TextAlign.center,
                  style: BaseTypography.titleMedium.copyWith(
                    color: BaseColor.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Gap.h4,
                Text(
                  "Start publishing activities to see them here",
                  textAlign: TextAlign.center,
                  style: BaseTypography.bodyMedium.copyWith(
                    color: BaseColor.secondaryText,
                  ),
                ),
              ],
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
