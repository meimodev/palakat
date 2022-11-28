import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:palakat/app/widgets/card_event.dart';
import 'package:palakat/app/widgets/dialog_event_detail.dart';
import 'package:palakat/data/models/event.dart';
import 'package:palakat/data/models/user.dart';
import 'package:palakat/shared/routes.dart';
import 'package:palakat/shared/theme.dart';

import 'dashboard_controller.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: Insets.medium.w,
        right: Insets.medium.w,
        top: Insets.small.h,
      ),
      child: Obx(
        () => AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _BuildListBody(
            isLoading: controller.isLoading.value,
            user: controller.user,
            eventsThisWeek: controller.eventsThisWeek,
          ),
        ),
      ),
    );
  }
}

class _BuildListBody extends StatelessWidget {
  const _BuildListBody({
    Key? key,
    required this.isLoading,
    required this.user,
    required this.eventsThisWeek,
  }) : super(key: key);

  final bool isLoading;
  final User user;
  final List<Event> eventsThisWeek;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Dashboard',
          style: Theme.of(context).textTheme.headline1?.copyWith(
                fontSize: 36.sp,
              ),
        ),
        SizedBox(height: Insets.small.h),
        Material(
          clipBehavior: Clip.hardEdge,
          elevation: 0,
          color: Palette.primary,
          borderRadius: BorderRadius.circular(9.sp),
          child: InkWell(
            onTap: () => Navigator.pushNamed(
              context,
              Routes.account,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Insets.small.w,
                vertical: Insets.small.h,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 21.sp,
                    backgroundColor: Palette.accent,
                  ),
                  SizedBox(
                    width: Insets.small.w,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          user.name,
                          style: TextStyle(
                            color: Palette.textAccent,
                            fontSize: 14.sp,
                          ),
                        ),
                        Text(
                          user.church.name,
                          style: TextStyle(
                            color: Palette.cardForeground,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Icon(
                      Icons.edit,
                      color: Palette.cardForeground,
                      size: 15.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: Insets.small.h * .5),
        Text(
          'This Week (${eventsThisWeek.length})',
          style: TextStyle(
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: Insets.small.h * .5),
        Expanded(
          child: ListView.builder(
            itemCount: eventsThisWeek.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) => CardEvent(
              isActive: index % 2 == 0,
              event: eventsThisWeek[index],
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => DialogEventDetail(
                    enableAlarm: true,
                    event: eventsThisWeek[index],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
