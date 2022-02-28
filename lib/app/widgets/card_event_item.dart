import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:palakat/shared/theme.dart';

class CardEventItem extends StatelessWidget {
  const CardEventItem({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isValue = false,
    this.builder,
  }) : super(key: key);

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isValue;
  final Widget? builder;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(9.sp),
      color: Palette.cardForeground,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Insets.small.w,
            vertical: Insets.small.h,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      text,
                      style: Theme.of(context).textTheme.headline1?.copyWith(
                            fontSize: 14.sp,
                            color: isValue ? Palette.primary : Colors.grey,
                          ),
                    ),
                  ),
                  icon != null
                      ? Icon(
                          icon!,
                          size: 15.sp,
                          color: Colors.grey,
                        )
                      : const SizedBox(),
                ],
              ),
              builder != null ? builder! : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}