import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:palakat/app/widgets/card_event.dart';
import 'package:palakat/app/widgets/dialog_event_detail.dart';
import 'package:palakat/app/widgets/dialog_simple_confirm.dart';
import 'package:palakat/data/models/event.dart';
import 'package:palakat/data/models/user_app.dart';
import 'package:palakat/shared/shared.dart';

import 'dashboard_controller.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({Key? key}) : super(key: key);

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
              : _BuildListBody(
                  onTapAccountCard: controller.onTapAccountCard,
                  user: controller.user,
                  eventsThisWeek: controller.events,
                  onPressedSignOutButton: controller.onPressedSignOutButton,
                ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: Palette.primary),
    );
  }
}

class _BuildListBody extends StatelessWidget {
  const _BuildListBody({
    Key? key,
    required this.user,
    required this.eventsThisWeek,
    required this.onTapAccountCard,
    required this.onPressedSignOutButton,
  }) : super(key: key);

  final UserApp? user;
  final List<Event> eventsThisWeek;
  final void Function() onTapAccountCard;
  final void Function() onPressedSignOutButton;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Dashboard',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontSize: 36.sp,
                  ),
            ),
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => DialogSimpleConfirm(
                    title: "Heads Up !",
                    description: "Proceed to Log out of this account ?",
                    onPressedPositive: onPressedSignOutButton,
                  ),
                );
              },
              icon: const Icon(Icons.logout_outlined),
              splashRadius: 30.sp,
            ),
          ],
        ),
        SizedBox(height: Insets.medium.h * .75),
        Material(
          clipBehavior: Clip.hardEdge,
          elevation: 0,
          color: Palette.primary,
          borderRadius: BorderRadius.circular(9.sp),
          child: InkWell(
            onTap: onTapAccountCard,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Insets.small.w,
                vertical: Insets.small.h,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(Insets.small.sp * .75),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(9),
                                color: Palette.accent,
                              ),
                              child: Icon(
                                Icons.church_outlined,
                                size: 24.sp,
                                color: Palette.primary,
                              ),
                            ),
                            SizedBox(
                              width: Insets.small.w,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    '${user?.membership?.church?.name ?? "-"}, ${user?.membership?.church?.location ?? "-"}',
                                    style: TextStyle(
                                      color: Palette.cardForeground,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  if (user != null && user!.membership != null)
                                    Text(
                                      'Kolom ${user!.membership!.column}',
                                      style: TextStyle(
                                        color: Palette.cardForeground,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: Insets.small.h),
                        Center(
                          child: Text(
                            user!.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                              color: Palette.accent,
                            ),
                          ),
                        ),
                        SizedBox(height: Insets.small.h),
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
        SizedBox(height: Insets.small.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'This Week (${eventsThisWeek.length})',
              style: TextStyle(
                fontSize: 14.sp,
              ),
            ),
            Expanded(
              child: Text(
                ' ${Jiffy().startOf(Units.WEEK).dateTime.toDated} '
                '${Jiffy().startOf(Units.WEEK).dateTime.toMonthMMMM} '
                ' - ${Jiffy().endOf(Units.WEEK).dateTime.toDated} '
                '${Jiffy().endOf(Units.WEEK).dateTime.toMonthMMMM}',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 12.sp,
                ),
              ),
            ),
          ],
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
