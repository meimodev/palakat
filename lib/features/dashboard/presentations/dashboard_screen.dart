import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';

import 'widgets/widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ScreenTitleWidget.titleOnly(
            title: "Dashboard",
          ),
          Gap.h12,
          MembershipCardWidget(
            variant: MembershipCardWidgetVariant.unsigned,
            title: "Some Very Long Sting for",
            subTitle: "Subtitle of the card",
            bipra: "AAA",
            onPressedCard: () {
              print("Card Pressed");
            },
            columnNumber: '90',
          ),
          Gap.h24,
          ActivityWidget(
            onPressedViewAll: () {
              print("View All Pressed");
            },
            activities: [
              'act1',
              'act2',
              'act3',
              'act4',
              'act5',
              'act6',
              'act7',
            ],
            cardsHeight: BaseSize.customWidth(100),
            onPressedCardDatePreview: () async {
              await showDialogPreviewDayActivitiesWidget(
                context: context,
                data: [
                  {"title": "This is the activity type", "type": "type1"},
                  {"title": "This is the activity type", "type": "type2"},
                  {"title": "This is the activity type", "type": "type3"},
                  {"title": "This is the activity type", "type": "type4"},
                  {"title": "This is the activity type", "type": "type5"},
                  {"title": "This is the activity type", "type": "type6"},
                  {"title": "This is the activity type", "type": "type7"},
                ],
                onPressedConfirm: () {},
                title: 'Mon, 25 Jan',
              );
            },
          ),
          Gap.h12,
          AnnouncementWidget(
            onPressedViewAll: () {
              print("view all announcement");
            },
            announcements: [
              "announcement about lorem ipsum 1",
              "announcement about lorem ipsum 2",
              "announcement about lorem ipsum 3",
            ],
          ),
          Gap.h12,
          ArticlesWidget(
            onPressedViewAll: () {
              print("view all articles");
            },
            data: [
              "Title of the article 1",
              "Title of the article 2",
              "Title of the article 3 lorem ipsum",
            ],
          ),
        ],
      ),
    );
  }
}
