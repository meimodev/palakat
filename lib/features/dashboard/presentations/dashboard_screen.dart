import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';

import 'widgets/widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
              title: "Dashboard",
              variant: ScreenTitleWidgetVariant.titleOnly,
            ),
            Gap.h12,
            const MembershipCardWidget(),
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
              height: BaseSize.customWidth(100),
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
            Gap.h12,
            //TODO Later the news in the next phase
            // NewsWidget(
            //   onPressedViewAll: () {
            //     print("view all articles");
            //   },
            //   data: [
            //     "Title of the article 1",
            //     "Title of the article 2",
            //     "Title of the article 3 lorem ipsum",
            //   ],
            // ),
            Gap.h56,
          ],
        ),
      ),
    );
  }
}
