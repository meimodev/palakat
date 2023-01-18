import 'package:flutter/material.dart';
import 'package:palakat/shared/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScreenTitle extends StatelessWidget {
  const ScreenTitle({
    Key? key,
    required this.title,
    this.onPressedBack,
    this.hideBack = false,
  }) : super(key: key);

  final String title;
  final Future<bool> Function()? onPressedBack;
  final bool hideBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        hideBack
            ? const SizedBox()
            : InkWell(
                onTap: () async {
                  if (onPressedBack != null) {
                    if (await onPressedBack!()) {
                      Navigator.pop(context);
                    }
                    return;
                  }
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back,
                  color: Palette.primary,
                  size: 30.sp,
                ),
              ),
        hideBack ? const SizedBox() : SizedBox(width: Insets.small.w),
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
