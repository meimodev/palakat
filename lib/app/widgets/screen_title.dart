import 'package:flutter/material.dart';
import 'package:palakat/shared/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class ScreenTitle extends StatelessWidget {
  const ScreenTitle({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: Palette.primary,
            size: 30.sp,
          ),
        ),
        SizedBox(width: Insets.small.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 36.sp,
          ),
        ),
      ],
    );
  }
}
