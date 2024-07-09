import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/models/models.dart' hide Column;
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'widgets.dart';

class AnnouncementWidget extends StatelessWidget {
  const AnnouncementWidget({
    super.key,
    required this.onPressedViewAll,
    required this.announcements,
  });

  final void Function() onPressedViewAll;
  final List<Activity> announcements;

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentTitleWidget(
          onPressedViewAll: onPressedViewAll,
          count: announcements.length,
          title: 'Announcements',
        ),
        Gap.h6,
        ...announcements.map(
          (e) => Padding(
            padding: EdgeInsets.only(
              bottom: BaseSize.h6,
            ),
            child: CardAnnouncementWidget(
              title: e.title,
              publishedOn: e.publishDate,
              onPressedCard: () {
                context.pushNamed(
                  AppRoute.activityDetail,
                  extra: RouteParam(
                    params: {
                      RouteParamKey.activityId: e.serial,
                    },
                  ),
                );
              },
              onPressedDownload: () {
                print('Download ${e.title}');
              },
            ),
          ),
        ),
      ],
    );
  }
}
