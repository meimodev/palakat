import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/models/models.dart';
import 'package:palakat/core/utils/extensions/date_time_extension.dart';
import 'package:palakat/core/widgets/widgets.dart';

import 'widgets.dart';

class ActivityWidget extends StatefulWidget {
  const ActivityWidget({
    super.key,
    required this.onPressedViewAll,
    required this.cardsHeight,
    required this.activities,
    required this.onPressedCardDatePreview,
  });

  final VoidCallback onPressedViewAll;
  final List<Activity> activities;
  final double cardsHeight;
  final void Function(DateTime) onPressedCardDatePreview;

  @override
  State<ActivityWidget> createState() => _ActivityWidgetState();
}

class _ActivityWidgetState extends State<ActivityWidget> {
  List<Activity> thisWeekActivity = [];

 final List<DateTime> thisWeek = DateTime.now().generateThisWeekDates;

  @override
  void initState() {
    super.initState();

    thisWeekActivity = widget.activities
        .where((e) => e.activityDate.isOnThisWeek(DateTime.now()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentTitleWidget(
          onPressedViewAll: widget.onPressedViewAll,
          count: widget.activities.length,
          title: 'Activities',
        ),
        Gap.h6,
        SizedBox(
          height: widget.cardsHeight + BaseSize.w16,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: thisWeek.length,
            separatorBuilder: (context, index) => Gap.w12,
            itemBuilder: (context, index) {
              final day = thisWeek[index];
              return CardDatePreviewWidget(
                width: widget.cardsHeight,
                date: day,
                eventCount: thisWeekActivity
                    .where((e) =>
                        e.activityDate.isSameDay(day) &&
                        e.type == ActivityType.event)
                    .length,
                serviceCount: thisWeekActivity
                    .where((e) =>
                        e.activityDate.isSameDay(day) &&
                        e.type == ActivityType.service)
                    .length,
                onPressedCardDatePreview: () =>
                    widget.onPressedCardDatePreview(day),
              );
            },
          ),
        ),
      ],
    );
  }
}
