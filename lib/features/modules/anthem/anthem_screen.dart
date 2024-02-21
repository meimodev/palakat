import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:palakat/core/widgets/bottom_navbar.dart';
import 'package:palakat/app/widgets/screen_wrapper.dart';
import 'package:palakat/shared/theme.dart';

class AnthemScreen extends StatelessWidget {
  const AnthemScreen({Key? key}) : super(key: key);

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
                  'Song book',
                  style: Theme.of(context).textTheme.headline1?.copyWith(
                        fontSize: 36.sp,
                      ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Coming soon ...',
                      style: Theme.of(context)
                          .textTheme
                          .headline1
                          ?.copyWith(fontSize: 16.sp, color: Colors.grey),
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
                activeIndex: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}