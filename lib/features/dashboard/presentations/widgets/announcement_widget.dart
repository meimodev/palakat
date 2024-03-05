import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'widgets.dart';

class AnnouncementWidget extends StatelessWidget {
  const AnnouncementWidget({
    super.key,
    required this.onPressedViewAll,
    required this.announcements,
  });

  final void Function() onPressedViewAll;
  final List<String> announcements;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentTitleWidget(
          onPressedViewAll: onPressedViewAll,
          count: announcements.length,
          title: 'Announcement',
        ),
        Gap.h6,
        ...announcements.map(
          (e) => Padding(
            padding: EdgeInsets.only(
              bottom: BaseSize.h6,
            ),
            child: CardAnnouncementWidget(
              title: e,
              onPressedCard: () {
                print(e);
              },
              onPressedDownload: () {
                print('Download');
              },
            ),
          ),
        ),
      ],
    );
  }
}
