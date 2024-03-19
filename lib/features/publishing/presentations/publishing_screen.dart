import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/models/activity_overview.dart';
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
            onPressedCard: () {
              context.pushNamed(AppRoute.activityPublish);
            },
            data: [
              {
                "title": "Publish Service",
                "description":
                    "This is the service that needed to be publish, like yourth service, or general service",
                "onPressed": () {
                  print("Service");
                }
              },
              {
                "title": "Publish Event",
                "description":
                    "This is the service that needed to be publish, like yourth service, or general service",
                "onPressed": () {
                  print("Event");
                }
              },
              {
                "title": "Publish Announcement",
                "description":
                    "This is the service that needed to be publish, like yourth service, or general service",
                "onPressed": () {
                  print("Announcement");
                }
              },
              {
                "title": "Publish Article",
                "description":
                    "This is the service that needed to be publish, like yourth service, or general service",
                "onPressed": () {
                  print("Article");
                }
              },
              {
                "title": "Publish Fund Raising",
                "description":
                    "This is the service that needed to be publish, like yourth service, or general service",
                "onPressed": () {
                  print("Fund Raising");
                }
              },
            ],
          ),
          Gap.h24,
          PublishByYouWidget(
            data: [
              ActivityOverview(
                id: "1234-1234",
                title: "This is the title of the published data",
                type: ActivityType.service,
              ),
              ActivityOverview(
                id: "1234-4411",
                title: "Second title of the published data",
                type: ActivityType.event,
              ),
              ActivityOverview(
                id: "1234-4556",
                title: "published data of the activity overview number 3",
                type: ActivityType.announcement,
              ),
            ],
            onPressedViewAll: () {
              context.pushNamed(AppRoute.viewAll);
            },
            onPressedCard: (activityOverview) {},

          ),
        ],
      ),
    );
  }
}
