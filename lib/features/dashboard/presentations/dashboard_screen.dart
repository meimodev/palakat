import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/models/models.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';

import 'widgets/widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final membership = Membership(
      id: "id",
      account: Account(
        id: "id",
        phone: "phone",
        name: "name",
        dob: DateTime.now(),
        gender: Gender.male,
        maritalStatus: MaritalStatus.married,
      ),
      church: Church(
        id: "id",
        name: "somename",
        location: Location(
          latitude: 1,
          longitude: 1,
          name: "some location",
        ),
      ),
      columnNumber: "22",
      baptize: true,
      sidi: true,
      bipra: Bipra.youths,
    );
    final activities = [
      'act1',
      'act2',
      'act3',
      'act4',
      'act5',
      'act6',
      'act7',
    ];

    return ScaffoldWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ScreenTitleWidget.titleOnly(
            title: "Dashboard",
          ),
          Gap.h12,
          MembershipCardWidget(
            membership: membership,
            onPressedCard: () => context.pushNamed(AppRoute.account),
          ),
          Gap.h24,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: BaseSize.w12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ActivityWidget(
                  onPressedViewAll: () async =>
                      await context.pushNamed(AppRoute.viewAll),
                  activities: activities,
                  cardsHeight: BaseSize.customWidth(80),
                  onPressedCardDatePreview: () async {
                    await showDialogPreviewDayActivitiesWidget(
                      title: 'Mon, 25 Jan',
                      context: context,
                      data: List.generate(
                        3,
                        (index) => ActivityOverview(
                          id: "id $index",
                          title: "Activity Title $index",
                          type: ActivityType.values[
                              Random().nextInt(ActivityType.values.length)],
                        ),
                      ),
                      onPressedCardActivity: (activityOverview) {
                        context.pushNamed(
                          AppRoute.activityDetail,
                          extra: RouteParam(
                            params: {
                              RouteParamKey.activityId: activityOverview.id,
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
                Gap.h12,
                AnnouncementWidget(
                  onPressedViewAll: () async {
                    await context.pushNamed(AppRoute.viewAll);
                  },
                  announcements: [
                    "announcement about lorem ipsum 1",
                    "announcement about lorem ipsum 2",
                    "announcement about lorem ipsum 3",
                  ],
                ),
                Gap.h12,
                ArticlesWidget(
                  onPressedViewAll: () async {
                    await context.pushNamed(AppRoute.viewAll);
                  },
                  data: [
                    "Title of the article 1",
                    "Title of the article 2",
                    "Title of the article 3 lorem ipsum",
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
