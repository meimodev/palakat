import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:palakat/app/widgets/button_new_event.dart';
import 'package:palakat/app/widgets/card_event.dart';
import 'package:palakat/app/widgets/dialog_new_event.dart';
import 'package:palakat/app/widgets/layout_no_member.dart';
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
      child: Obx(
        () => AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: controller.isLoading.isTrue
              ? _buildLoading()
              : _BuildMainLayout(
                  controller: controller,
                ),
        ),
      ),
    );
  }

  _buildLoading() => const CircularProgressIndicator(color: Palette.primary);
}

class _BuildMainLayout extends StatelessWidget {
  const _BuildMainLayout({Key? key, required this.controller})
      : super(key: key);

  final CalendarController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Calendar',
          style: TextStyle(
            fontSize: 36.sp,
          ),
        ),
        SizedBox(height: Insets.medium.h),
        controller.user.membershipId.isEmpty
            ? Expanded(child: _BuildLayoutNoMember(onFinishRegister: () {}))
            : Expanded(
                child: _BuildPublishedEventList(
                  controller: controller,
                ),
              ),
      ],
    );
  }
}

class _BuildLayoutNoMember extends StatelessWidget {
  const _BuildLayoutNoMember({Key? key, required this.onFinishRegister})
      : super(key: key);

  final void Function() onFinishRegister;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LayoutNoMember(
        caption:
            "Publish your activity to local church members where you registered",
        onFinishRegister: onFinishRegister,
      ),
    );
  }
}

class _BuildPublishedEventList extends StatelessWidget {
  const _BuildPublishedEventList({Key? key, required this.controller})
      : super(key: key);

  final CalendarController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
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
          "Your Published Events (${controller.events.length})",
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
                            DateTime dateTime,
                            List<String> reminders,
                          ) {}),
                    );
                  },
                  event: controller.events[index],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
