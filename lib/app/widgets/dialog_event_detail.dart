import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:palakat/data/models/event.dart';
import 'package:palakat/data/models/user_app.dart';
import 'package:palakat/data/repos/user_repo.dart';
import 'package:palakat/shared/shared.dart';

class DialogEventDetail extends StatefulWidget {
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
  State<DialogEventDetail> createState() => _DialogEventDetailState();
}

class _DialogEventDetailState extends State<DialogEventDetail> {
  final userRepo = UserRepo();
  UserApp? author;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchAuthor();
  }

  void fetchAuthor() async {
    author = await userRepo.readUser(
      widget.event.authorId,
      populateWholeData: false,
    );
    setState(() {
      loading = false;
    });
  }

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
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: loading
              ? const Center(
                  child: CircularProgressIndicator(
                  color: Palette.primary,
                ))
              : Stack(
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
                              widget.event.title,
                              style: TextStyle(
                                    fontSize: 24.sp,
                                  ),
                            ),
                            Text(
                              widget.event.location,
                              style: TextStyle(
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.calendar_month_outlined,
                                    color: Palette.primary,
                                    size: 21.sp,
                                  ),
                                  SizedBox(width: Insets.small.w * .5),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${widget.event.eventDateTimeStamp.yeary}\n${widget.event.eventDateTimeStamp.dayEEEE}, ${widget.event.eventDateTimeStamp.dated} ${widget.event.eventDateTimeStamp.monthMMM}',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: Insets.small.w),
                                  Icon(
                                    Icons.schedule_outlined,
                                    color: Palette.primary,
                                    size: 21.sp,
                                  ),
                                  SizedBox(width: Insets.small.w * .5),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      widget.event.eventDateTimeStamp.timeHHmm,
                                      style: TextStyle(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Reminders',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: Insets.small.w),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            for (String e
                                                in widget.event.reminders)
                                              Text(
                                                e,
                                                style: TextStyle(
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
                                widget.enableAlarm
                                    ? const _ButtonSetAlarm()
                                    : const SizedBox(),
                                widget.onPressedDelete != null
                                    ? _buildButtonDelete(
                                        context, widget.onPressedDelete!)
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
                              author?.name ?? "",
                              style: TextStyle(
                                color: Palette.cardForeground,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                            Text(
                              author?.phone ?? "",
                              style: TextStyle(
                                color: Palette.cardForeground,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
