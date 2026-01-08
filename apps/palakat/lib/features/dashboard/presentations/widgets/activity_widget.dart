import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat/core/widgets/widgets.dart';

import 'widgets.dart';

class ActivityWidget extends StatefulWidget {
  const ActivityWidget({
    super.key,
    required this.onPressedViewAll,
    required this.cardsHeight,
    required this.activities,
    required this.announcements,
    required this.birthdays,
    required this.onPressedCardDatePreview,
  });

  final VoidCallback onPressedViewAll;
  final List<Activity> activities;
  final List<Activity> announcements;
  final List<BirthdayItem> birthdays;
  final double cardsHeight;
  final void Function(DateTime) onPressedCardDatePreview;

  @override
  State<ActivityWidget> createState() => _ActivityWidgetState();
}

class _ActivityWidgetState extends State<ActivityWidget> {
  @override
  Widget build(BuildContext context) {
    final List<DateTime> thisWeekDates = DateTime.now().generateThisWeekDates;

    final activities = widget.activities
        .where(
          (Activity element) =>
              element.activityType == ActivityType.service ||
              element.activityType == ActivityType.event,
        )
        .toList(growable: false);

    final birthdays = widget.birthdays;
    final announcements = widget.announcements;

    if (activities.isEmpty && birthdays.isEmpty && announcements.isEmpty) {
      return const SizedBox();
    }

    int nonZeroCounterCount(DateTime day) {
      var count = 0;

      final birthdayCount = birthdays
          .where((b) => b.date.isSameDay(day))
          .length;
      if (birthdayCount > 0) count += 1;

      final serviceCount = activities
          .where(
            (e) =>
                e.date.isSameDay(day) && e.activityType == ActivityType.service,
          )
          .length;
      if (serviceCount > 0) count += 1;

      final eventCount = activities
          .where(
            (e) =>
                e.date.isSameDay(day) && e.activityType == ActivityType.event,
          )
          .length;
      if (eventCount > 0) count += 1;

      final announcementCount = announcements
          .where((a) => a.date.isSameDay(day))
          .length;
      if (announcementCount > 0) count += 1;

      return count;
    }

    int rowsForDay(DateTime day) {
      final count = nonZeroCounterCount(day);
      if (count == 0) return 0;
      if (count <= 2) return 1;
      return 2;
    }

    final maxRows = thisWeekDates.fold<int>(0, (maxValue, day) {
      final rows = rowsForDay(day);
      return rows > maxValue ? rows : maxValue;
    });

    final baseHeight = BaseSize.customHeight(76);
    final rowHeight = BaseSize.customHeight(24);
    final rowSpacing = BaseSize.customHeight(4);
    final countersHeight = maxRows == 0
        ? 0.0
        : (BaseSize.customHeight(6) +
              (maxRows * rowHeight) +
              ((maxRows - 1) * rowSpacing));
    final cardHeight = baseHeight + countersHeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentTitleWidget(
          onPressedViewAll: widget.onPressedViewAll,
          count: activities.length + birthdays.length + announcements.length,
          title:
              '${context.l10n.lbl_activity} - ${context.l10n.dateRangeFilter_thisWeek}',
          titleStyle: BaseTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: BaseColor.black,
          ),
          leadingIcon: AppIcons.calendar,
          leadingBg: BaseColor.blue[50],
          leadingFg: BaseColor.blue[700],
        ),
        Gap.h12,
        SizedBox(
          height: cardHeight + BaseSize.customHeight(8),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: thisWeekDates.length,
            separatorBuilder: (context, index) =>
                SizedBox(width: BaseSize.customWidth(12)),
            itemBuilder: (context, index) {
              final day = thisWeekDates[index];
              return CardDatePreviewWidget(
                width: widget.cardsHeight,
                height: cardHeight,
                date: day,
                announcementCount: announcements
                    .where((a) => a.date.isSameDay(day))
                    .length,
                birthdayCount: birthdays
                    .where((b) => b.date.isSameDay(day))
                    .length,
                eventCount: activities
                    .where(
                      (e) =>
                          e.date.isSameDay(day) &&
                          e.activityType == ActivityType.event,
                    )
                    .length,
                serviceCount: activities
                    .where(
                      (e) =>
                          e.date.isSameDay(day) &&
                          e.activityType == ActivityType.service,
                    )
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
