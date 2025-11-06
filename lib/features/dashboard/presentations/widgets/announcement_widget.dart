import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat_admin/core/models/models.dart' hide Column;
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
          leadingIcon: Icons.campaign,
          leadingBg: BaseColor.yellow[50],
          leadingFg: BaseColor.yellow[700],
        ),
        Gap.h12,
        if (announcements.isEmpty)
          const SizedBox()
        else
          ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: announcements.length,
            separatorBuilder: (_, _) => Gap.h12,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              return CardAnnouncementWidget(
                title: announcement.title,
                publishedOn: announcement.date,
                onPressedCard: () {
                  context.pushNamed(
                    AppRoute.activityDetail,
                    extra: RouteParam(
                      params: {
                        RouteParamKey.activity: announcement.toJson(),
                      },
                    ),
                  );
                },
                onPressedDownload: () {
                  // TODO: Implement download functionality
                },
              );
            },
          ),
      ],
    );
  }
}
