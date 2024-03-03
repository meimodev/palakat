import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';

import 'widgets/widgets.dart';

class PublishingScreen extends StatelessWidget {
  const PublishingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Gap.h48,
            const ScreenTitleWidget(
              title: "Publishing",
              variant: ScreenTitleWidgetVariant.titleOnly,
            ),
            Gap.h12,
            PublishingOperationsListWidget(
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
              onPressedViewAll: () {
                print("View All Publish By You");
              },
              data: [
                {
                  "title": "This is the title of the published data",
                  "type": "Service",
                  "onPressed": () {
                    print("service");
                  },
                },
                {
                  "title": "This is the title of the published data",
                  "type": "Announcement",
                  "onPressed": () {
                    print("Announcement");
                  },
                },
                {
                  "title": "This is the title of the published data",
                  "type": "Event",
                  "onPressed": () {
                    print("Event");
                  },
                },
              ],
            ),
            Gap.h56,
          ],
        ),
      ),
    );
  }
}
