import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/models/models.dart' hide Column;
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
  final List<DateTime> thisWeekDates = DateTime.now().generateThisWeekDates;

  late final activities = widget.activities
      .where((element) =>
  element.type == ActivityType.service ||
      element.type == ActivityType.event).toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentTitleWidget(
          onPressedViewAll: widget.onPressedViewAll,
          count: activities.length,
          title: 'Activities this week',
        ),
        Gap.h6,
        activities.isEmpty
            ? const SizedBox()
            : SizedBox(
                height: widget.cardsHeight + BaseSize.w16,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: thisWeekDates.length,
                  separatorBuilder: (context, index) => Gap.w12,
                  itemBuilder: (context, index) {
                    final day = thisWeekDates[index];
                    return CardDatePreviewWidget(
                      width: widget.cardsHeight,
                      date: day,
                      eventCount: activities
                          .where((e) =>
                              e.activityDate.isSameDay(day) &&
                              e.type == ActivityType.event)
                          .length,
                      serviceCount: activities
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
