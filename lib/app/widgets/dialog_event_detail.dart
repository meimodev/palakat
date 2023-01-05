import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:palakat/data/models/event.dart';
import 'package:palakat/shared/theme.dart';

class DialogEventDetail extends StatelessWidget {
  const DialogEventDetail({
    Key? key,
    this.enableAlarm = false,
    this.onPressedDelete,
    required this.event,
  }) : super(key: key);

  final bool enableAlarm;
  final VoidCallback? onPressedDelete;
  final Event event;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(
          12.sp,
        ),
      ),
      child: SizedBox(
        width: 312.w,
        height: 360.h,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              top: Insets.medium.h,
              child: Container(
                padding: EdgeInsets.only(
                  left: Insets.medium.w,
                  right: Insets.medium.w,
                  bottom: Insets.small.h,
                  top: Insets.medium.h,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9.sp),
                  color: Palette.scaffold,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      event.title,
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(
                            fontSize: 24.sp,
                          ),
                    ),
                    Text(
                      event.location,
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(
                            fontSize: 14.sp,
                            color: Colors.grey,
                          ),
                    ),
                    SizedBox(height: Insets.small.h * .5),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Insets.small.w,
                        vertical: Insets.small.h,
                      ),
                      decoration: BoxDecoration(
                        color: Palette.cardForeground,
                        borderRadius: BorderRadius.circular(9.sp),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${event.year}\n${event.day}, ${event.date} ${event.monthF}',
                              style: TextStyle(
                                    fontSize: 18.sp,
                                  ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              event.time,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  ?.copyWith(
                                    fontSize: 18.sp,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: Insets.medium.h),
                    // Text(
                    //   '99 Reminder sets',
                    //   textAlign: TextAlign.center,
                    //   style: Theme.of(context).textTheme.bodyText1?.copyWith(
                    //         fontSize: 14.sp,
                    //       ),
                    // ),
                    // SizedBox(height: Insets.small.h),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reminders',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    ?.copyWith(
                                      color: Colors.grey,
                                      fontSize: 12.sp,
                                    ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: Insets.small.w),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    for (String e in event.reminders)
                                      Text(
                                        e,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            ?.copyWith(
                                              color: Colors.grey,
                                              fontSize: 12.sp,
                                            ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        enableAlarm
                            ? const _ButtonSetAlarm()
                            : const SizedBox(),
                        onPressedDelete != null
                            ? _buildButtonDelete(context, onPressedDelete!)
                            : const SizedBox(),
                      ],
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Insets.medium.w,
                  vertical: Insets.small.h * .5,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9.sp),
                  color: Palette.primary,
                ),
                child: Column(
                  children: [
                    Text(
                      event.authorName,
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(
                          color: Palette.cardForeground, fontSize: 10.sp),
                    ),
                    Text(
                      event.authorPhone,
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(
                          color: Palette.cardForeground, fontSize: 10.sp),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonDelete(BuildContext context, VoidCallback onPressed) {
    return Material(
      clipBehavior: Clip.hardEdge,
      borderRadius: BorderRadius.circular(9.sp),
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: Insets.small.h,
            horizontal: Insets.small.w,
          ),
          child: Center(
            child: Icon(
              Icons.delete,
              color: Palette.negative,
              size: 30.sp,
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonSetAlarm extends StatefulWidget {
  const _ButtonSetAlarm({
    Key? key,
  }) : super(key: key);


  @override
  State<_ButtonSetAlarm> createState() => _ButtonSetAlarmState();
}

class _ButtonSetAlarmState extends State<_ButtonSetAlarm> {
  bool isActive = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          isActive = !isActive;
        });
      },
      child: Container(
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: Palette.cardForeground,
          borderRadius: BorderRadius.circular(9.sp),
        ),
        child: Center(
          child: Icon(
            Icons.alarm,
            size: 30.sp,
            color: isActive ? Palette.positive : Palette.primary,
          ),
        ),
      ),
    );
  }
}