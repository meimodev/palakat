import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:palakat/core/widgets/bottom_navbar.dart';
import 'package:palakat/core/widgets/card_event.dart';
import 'package:palakat/core/widgets/dialog_event_detail.dart';
import 'package:palakat/core/widgets/screen_wrapper.dart';
import 'package:palakat/shared/routes.dart';
import 'package:palakat/shared/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                  'Home',
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
                                      crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          "Name",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1
                                              ?.copyWith(
                                            color: Palette.textAccent,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                        Text(
                                          "Church",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1
                                              ?.copyWith(
                                            color: Palette
                                                .cardForeground,
                                            fontSize: 12.sp,
                                            fontWeight:
                                            FontWeight.w300,
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
                          'This Week (12)',
                          style:
                              Theme.of(context).textTheme.headline1?.copyWith(
                                    fontSize: 14.sp,
                                  ),
                        ),
                        SizedBox(height: Insets.small.h * .5),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Palette.cardForeground,
                              borderRadius: BorderRadius.circular(9.sp),
                            ),
                            // child: ListView.builder(
                            //   itemCount: state.eventsThisWeek.length,
                            //   physics: const BouncingScrollPhysics(),
                            //   itemBuilder: (context, index) => CardEvent(
                            //     isActive: index % 2 == 0,
                            //     event: state.eventsThisWeek[index],
                            //     onPressed: () {
                            //       showDialog(
                            //         context: context,
                            //         builder: (BuildContext context) =>
                            //             DialogEventDetail(
                            //           enableAlarm: true,
                            //           event: state.eventsThisWeek[index],
                            //         ),
                            //       );
                            //     },
                            //   ),
                            // ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: Insets.medium.h,
            child: const Center(
              child: BottomNavbar(
                activeIndex: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
