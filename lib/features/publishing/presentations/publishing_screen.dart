import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/routing.dart';
import 'package:palakat/core/widgets/widgets.dart';

import 'widgets/widgets.dart';

class PublishingScreen extends StatelessWidget {
  const PublishingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ScreenTitleWidget.titleOnly(
            title: "Publishing",
          ),
          Gap.h12,
          PublishingOperationsListWidget(
            children: [
              CardPublishingOperationWidget(
                title: "Publish Service",
                description:
                    "This is the service that needed to be publish, like yourth service, or general service",
                onPressedCard: () {
                  context.pushNamed(AppRoute.activityPublish,
                      extra: const RouteParam(params: {
                        RouteParamKey.activityType: ActivityType.service
                      }));
                },
              ),
              Gap.h12,
              CardPublishingOperationWidget(
                title: "Publish Event",
                description:
                    "This is the service that needed to be publish, like yourth service, or general service",
                onPressedCard: () {
                  context.pushNamed(AppRoute.activityPublish,
                      extra: const RouteParam(params: {
                        RouteParamKey.activityType: ActivityType.service
                      }));
                },
              ),
              Gap.h12,
              CardPublishingOperationWidget(
                title: "Publish Announcement",
                description:
                    "This is the service that needed to be publish, like yourth service, or general service",
                onPressedCard: () {
                  context.pushNamed(AppRoute.activityPublish,
                      extra: const RouteParam(params: {
                        RouteParamKey.activityType: ActivityType.announcement
                      }));
                },
              ),
            ],
          ),
          Gap.h24,
          // PublishByYouWidget(
          //   data: [
          //     ActivityOverview(
          //       id: "1234-1234",
          //       title: "This is the title of the published data",
          //       type: ActivityType.service,
          //     ),
          //     ActivityOverview(
          //       id: "1234-4411",
          //       title: "Second title of the published data",
          //       type: ActivityType.event,
          //     ),
          //     ActivityOverview(
          //       id: "1234-4556",
          //       title: "published data of the activity overview number 3",
          //       type: ActivityType.announcement,
          //     ),
          //   ],
          //   onPressedViewAll: () {
          //     context.pushNamed(AppRoute.viewAll);
          //   },
          //   onPressedCard: (activityOverview) {},
          // ),
        ],
      ),
    );
  }
}
