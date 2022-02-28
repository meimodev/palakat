import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:palakat/shared/routes.dart';
import 'package:palakat/shared/theme.dart';

class BottomNavbar extends StatelessWidget {
  const BottomNavbar({Key? key, required this.activeIndex}) : super(key: key);

  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200.w,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomNavbarButton(
            isActive: activeIndex == 0,
            onPressed: () {
              if (activeIndex != 0) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.home,
                  (route) => false,
                );
              }
            },
            icon: Icons.home_rounded,
          ),
          SizedBox(width: Insets.medium.w),
          _buildBottomNavbarButton(
            isActive: activeIndex == 1,
            onPressed: () {
              if (activeIndex != 1) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.calendar,
                  (route) => false,
                );
              }
            },
            icon: Icons.add_alarm_rounded,
          ),
          SizedBox(width: Insets.medium.w),
          _buildBottomNavbarButton(
            isActive: activeIndex == 2,
            onPressed: () {
              if (activeIndex != 2) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.anthem,
                  (route) => false,
                );
              }
            },
            icon: Icons.accessible_forward_rounded,
          ),
        ],
      ),
    );
  }

  _buildBottomNavbarButton({
    bool isActive = false,
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return Material(
      clipBehavior: Clip.hardEdge,
      shape: const CircleBorder(),
      color: isActive ? Palette.primary : Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: 33.sp,
          height: 33.sp,
          child: Center(
            child: Icon(
              icon,
              size: isActive ? 18.sp : 15.sp,
              color: isActive ? Palette.cardForeground : Palette.primary,
            ),
          ),
        ),
      ),
    );
  }
}