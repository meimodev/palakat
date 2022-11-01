import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:palakat/shared/theme.dart';

class BottomNavbar extends StatelessWidget {
  const BottomNavbar(
      {Key? key, required this.tabController, required this.activeIndex})
      : super(key: key);

  final TabController tabController;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Insets.small.w),
      margin: EdgeInsets.only(
        left: Insets.small.w,
        right: Insets.small.w,
        bottom: 5.h,
      ),
      height: 50.sp,
      decoration: BoxDecoration(
        color: Palette.primary,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TabBar(
        controller: tabController,
        indicatorColor: Colors.transparent,
        labelColor: Palette.textPrimary,
        unselectedLabelColor: Palette.negative,
        tabs: [
          _buildBottomNavbarButton(
            icon: Icons.home,
            active: activeIndex == 0,
          ),
          _buildBottomNavbarButton(
            icon: Icons.add_alert,
            active: activeIndex == 1,
          ),
          _buildBottomNavbarButton(
            icon: Icons.access_alarm,
            active: activeIndex == 2,
          ),
        ],
      ),
    );
  }

  _buildBottomNavbarButton({
    required IconData icon,
    required bool active,
  }) {
    return Tab(
      child: Icon(
        icon,
        size: 18.sp,
        color: active ? Colors.white : Colors.grey.shade500,
      ),
    );
  }
}
