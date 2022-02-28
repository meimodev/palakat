import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:palakat/shared/theme.dart';

class ButtonConfirmDialog extends StatelessWidget {
  const ButtonConfirmDialog(
      {Key? key,
      required this.icon,
      required this.onPressed,
      this.invertColor = false})
      : super(key: key);

  final Widget icon;
  final VoidCallback onPressed;
  final bool invertColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.hardEdge,
      shape: const CircleBorder(),
      color: invertColor ? Palette.cardForeground : Palette.primary,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.all(15.sp),
          child: icon,
        ),
      ),
    );
  }
}