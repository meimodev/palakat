import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:palakat/shared/theme.dart';

class ButtonNewEvent extends StatelessWidget {
  const ButtonNewEvent({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.hardEdge,
      borderRadius: BorderRadius.circular(21.sp),
      color: Palette.primary,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: Insets.small.h,
          ),
          child: Center(
            child: Text(
              'New Event',
              style: Theme.of(context).textTheme.bodyText1?.copyWith(
                    color: Palette.cardForeground,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}