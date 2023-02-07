import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:palakat/app/widgets/button_new_event.dart';
import 'package:palakat/app/widgets/card_event.dart';
import 'package:palakat/app/widgets/dialog_new_event.dart';
import 'package:palakat/shared/theme.dart';

import 'calendar_controller.dart';

class CalendarScreen extends GetView<CalendarController> {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: Insets.medium.w,
        right: Insets.medium.w,
        top: Insets.large.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Calendar',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 36.sp,
                ),
          ),
          SizedBox(height: Insets.medium.h),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ButtonNewEvent(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => DialogNewEvent(
                        onPressedPositive: controller.onAddNewEvent,
                      ),
                    );
                  },
                ),
                SizedBox(height: Insets.small.h),
                Text(
                  "Your Published Events (0)",
                  style: TextStyle(
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: Insets.small.h * .5),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Palette.cardForeground,
                      borderRadius: BorderRadius.circular(12.sp),
                    ),
                    child: Obx(
                      () => ListView.builder(
                        primary: true,
                        itemCount: controller.events.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (_, index) => CardEvent(
                          enableAlarm: false,
                          onPressed: () {
                            final event = controller.events[index];
                            showDialog(
                              context: context,
                              builder: (_) => DialogNewEvent(
                                event: event,
                                onPressedPositive: (
                                  String title,
                                  String location,
                                  String dateTime,
                                  List<String> reminders,
                                ) {}
                              ),
                            );
                          },
                          event: controller.events[index],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
