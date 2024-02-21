import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:palakat/core/widgets/bottom_navbar.dart';
import 'package:palakat/app/widgets/button_new_event.dart';
import 'package:palakat/app/widgets/card_event.dart';
import 'package:palakat/app/widgets/dialog_event_detail.dart';
import 'package:palakat/app/widgets/dialog_new_event.dart';
import 'package:palakat/app/widgets/screen_wrapper.dart';
import 'package:palakat/shared/theme.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      child: Stack(
        children: [
          Positioned(
            left: Insets.small.w,
            right: Insets.small.w,
            top: Insets.medium.h,
            bottom: (60.h + Insets.medium.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Calendar',
                  style: Theme.of(context).textTheme.headline1?.copyWith(
                        fontSize: 36.sp,
                      ),
                ),
                SizedBox(height: Insets.medium.h),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: Insets.small.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Your published events (123)',
                          style: Theme.of(context)
                              .textTheme
                              .headline1
                              ?.copyWith(fontSize: 14.sp),
                        ),
                        SizedBox(height: Insets.small.h * .5),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Palette.cardForeground,
                              borderRadius: BorderRadius.circular(9.sp),
                            ),
                            child: Column(
                              children: [
                                // Expanded(
                                //   child: ListView.builder(
                                //     itemCount: 1,
                                //     physics: const BouncingScrollPhysics(),
                                //     itemBuilder: (context, index) => CardEvent(
                                //       onPressed: () {
                                //         // showDialog(
                                //         //   context: context,
                                //         //   builder: (BuildContext context) =>
                                //         //       DialogEventDetail(
                                //         //     enableAlarm: false,
                                //         //     onPressedDelete: () {},
                                //         //     event: state.eventsWithAuthor(
                                //         //         "0812 1234 1234")[index],
                                //         //   ),
                                //         // );
                                //       },
                                //       enableAlarm: false,
                                //       event: state.eventsWithAuthor(
                                //         "0812 1234 1234",
                                //       )[index],
                                //     ),
                                //   ),
                                // ),
                                ButtonNewEvent(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => const DialogNewEvent(),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: Insets.medium.h,
            child: const Center(
              child: BottomNavbar(
                activeIndex: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
