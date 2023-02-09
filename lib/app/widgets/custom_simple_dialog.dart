import 'package:flutter/material.dart';
import 'package:palakat/shared/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomSimpleDialog extends StatelessWidget {
  const CustomSimpleDialog({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.hardEdge,
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(12.sp),
      ),
      child: Container(
        color: Palette.scaffold,
        padding: EdgeInsets.symmetric(
          vertical: Insets.small.h,
          horizontal: Insets.medium.w,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 24.sp,
              ),
            ),
            SizedBox(height: Insets.small.h),
            Text(
              description,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w300,
              ),
            ),
            SizedBox(height: Insets.medium.h),
          ],
        ),
      ),
    );
  }
}
