import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:palakat/data/models/event.dart';
import 'package:palakat/shared/shared.dart';

class CardEvent extends StatelessWidget {
  const CardEvent({
    Key? key,
    this.isActive = false,
    this.enableAlarm = true,
    required this.onPressed,
    required this.event,
  }) : super(key: key);

  final bool isActive;
  final VoidCallback onPressed;
  final bool enableAlarm;
  final Event event;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.hardEdge,
      borderRadius: BorderRadius.circular(9.sp),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Insets.small.w,
            vertical: Insets.small.h * .5,
          ),
          height: 60.h,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 50.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      event.eventDateTimeStamp.toDayEEEE,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Palette.primary,
                      ),
                    ),
                    Text(
                      event.eventDateTimeStamp.toTimeHHmm,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: Insets.small.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      event.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Palette.primary,
                      ),
                    ),
                    Text(
                      event.location,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: Insets.small.w),
              enableAlarm
                  ? Center(
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9.sp),
                          color: Colors.transparent,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 9.sp,
                          vertical: 9.sp,
                        ),
                        child: Icon(
                          Icons.alarm_rounded,
                          size: 18.sp,
                          color: isActive ? Palette.positive : Colors.grey,
                        ),
                      ),
                    )
                  : const SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}
