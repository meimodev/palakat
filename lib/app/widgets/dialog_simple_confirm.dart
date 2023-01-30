
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:palakat/app/widgets/button_confirm_dialog.dart';
import 'package:palakat/app/widgets/screen_title.dart';
import 'package:palakat/shared/shared.dart';

class DialogSimpleConfirm extends StatelessWidget {
  const DialogSimpleConfirm({
    Key? key,
    this.title,
    this.description,
    this.onPressedPositive,
     this.onPressedNegative,
  }) : super(key: key);

  final String? title;
  final String? description;
  final void Function()? onPressedPositive;
  final void Function()? onPressedNegative;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      clipBehavior: Clip.hardEdge,
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Insets.medium.w,
          vertical: Insets.medium.h,
        ),
        color: Palette.scaffold,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ScreenTitle(title: title ?? "Heads Up", hideBack: true),
            SizedBox(height: Insets.small.h),
            Text(description ?? "Are you sure ?",
                style: TextStyle(
                  fontSize: 20.sp,
                )),
            SizedBox(height: Insets.medium.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ButtonConfirmDialog(
                  icon: const Icon(Icons.close_outlined),
                  onPressed: () {
                    if (onPressedNegative != null) {
                      onPressedNegative!();
                    }
                    Navigator.pop(context, false);
                  },
                  invertColor: true,
                ),
                ButtonConfirmDialog(
                  icon: const Icon(Icons.check_outlined, color: Palette.accent),
                  onPressed: () {
                    if (onPressedPositive != null) {
                      onPressedPositive!();
                    }
                    Navigator.pop(context, true);
                  },
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}
