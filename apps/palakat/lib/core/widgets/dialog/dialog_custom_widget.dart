import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/assets/assets.gen.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/core/constants/constants.dart';

Future<T?> showDialogCustomWidget<T>({
  required BuildContext context,
  required String title,
  required Widget content,
  bool scrollControlled = true,
  bool dismissible = true,
  bool dragAble = true,
  VoidCallback? onPopBottomSheet,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: scrollControlled,
    isDismissible: dismissible,
    enableDrag: dragAble,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(BaseSize.customRadius(BaseSize.radiusMd)),
      ),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.symmetric(horizontal: BaseSize.w12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Gap.h24,
          ScreenTitleWidget.bottomSheet(
            title: title,
            trailIcon: Assets.icons.line.times,
            trailIconColor: BaseColor.primaryText,
            onPressedTrailIcon: () {
              if (onPopBottomSheet != null) {
                onPopBottomSheet();
              }
              context.pop();
            },
          ),
          Gap.h16,
          content,
          Gap.h48,
        ],
      ),
    ),
  );
}
