import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:palakat/shared/theme.dart';

class NextButton extends StatelessWidget {
  const NextButton({
    Key? key,
    required this.onPressedPositive,
    required this.title,
    this.end = false,
  }) : super(key: key);

  final VoidCallback onPressedPositive;
  final String title;
  final bool end;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(9),
      color: Palette.primary,
      child: InkWell(
        onTap: onPressedPositive,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Insets.small.w,
            vertical: Insets.small.h,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  textAlign: end? TextAlign.center : TextAlign.start,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: Palette.cardForeground,
                  ),
                ),
              ),
              end ? const SizedBox() : SizedBox(width: 6.w),
              end
                  ? const SizedBox()
                  : Icon(
                      Icons.arrow_forward_rounded,
                      color: Palette.cardForeground,
                      size: 21.sp,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
