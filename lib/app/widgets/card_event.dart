import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:palakat/data/models/event.dart';
import 'package:palakat/shared/theme.dart';

class CardEvent extends StatelessWidget {
  const CardEvent({
    Key? key,
    this.isActive = false,
    required this.onPressed,
    this.enableAlarm = true,
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
            vertical: Insets.small.h,
          ),
          height: 80.h,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.day,
                    style: Theme.of(context).textTheme.bodyText1?.copyWith(
                          fontSize: 14.sp,
                          color: Palette.primary,
                        ),
                  ),
                  Text(
                    event.formattedDate,
                    style: Theme.of(context).textTheme.bodyText1?.copyWith(
                          fontSize: 11.sp,
                          color: Colors.grey,
                        ),
                  ),
                  Text(
                    event.time,
                    style: Theme.of(context).textTheme.bodyText1?.copyWith(
                          fontSize: 14.sp,
                          color: Palette.primary,
                        ),
                  ),
                ],
              ),
              SizedBox(width: Insets.small.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      event.title,
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(
                            fontSize: 14.sp,
                            color: Palette.primary,
                          ),
                    ),
                    Text(
                      event.location,
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(
                            fontSize: 11.sp,
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