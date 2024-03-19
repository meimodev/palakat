import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/models/activity_overview.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/presentation.dart';

class ViewAllScreen extends StatelessWidget {
  const ViewAllScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void onPressedCardActivity(ActivityOverview activityOverview) {
      context.pushNamed(
        AppRoute.activityDetail,
        extra: RouteParam(
          params: {
            RouteParamKey.activityId: activityOverview.id,
          },
        ),
      );
    }

    return ScaffoldWidget(
      child: Column(
        children: [
          ScreenTitleWidget.primary(
            title: "Activity This Week",
            leadIcon: Assets.icons.line.chevronBackOutline,
            leadIconColor: Colors.black,
            onPressedLeadIcon: context.pop,
          ),
          Gap.h24,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: BaseSize.w12),
            child: Column(
              children: [
                CardActivitySectionWidget(
                  title: '12 January 2024',
                  activities: [
                    ActivityOverview(
                      id: "1",
                      title:
                          "Long String to show the card rendering capabilities to trim this long string to make no sense",
                      type: ActivityType.service,
                    ),
                    ActivityOverview(
                      id: "2",
                      title: "lorem ipsum 2",
                      type: ActivityType.announcement,
                    ),
                  ],
                  onPressedCard: onPressedCardActivity,
                ),
                Gap.h24,
                CardActivitySectionWidget(
                  title: '13 January 2024',
                  today: true,
                  activities: [
                    ActivityOverview(
                      id: "12",
                      title: "lorem ipsum 1",
                      type: ActivityType.service,
                    ),
                    ActivityOverview(
                      id: "12",
                      title: "lorem ipsum 2",
                      type: ActivityType.event,
                    ),
                  ],
                  onPressedCard: onPressedCardActivity,
                ),
                Gap.h24,
                CardActivitySectionWidget(
                  title: '14 January 2024',
                  activities: [
                    ActivityOverview(
                      id: "11",
                      title: "lorem ipsum 1",
                      type: ActivityType.service,
                    ),
                    ActivityOverview(
                      id: "12",
                      title: "lorem ipsum 2",
                      type: ActivityType.event,
                    ),
                  ],
                  onPressedCard: onPressedCardActivity,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

