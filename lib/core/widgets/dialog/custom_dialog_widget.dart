import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:palakat/core/assets/assets.gen.dart';
import 'package:palakat/core/utils/utils.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/core/constants/constants.dart';

/// [INFO] call the showCustomDialogWidget function to use the dialog
/// is in the customable content that can be used by adding the `content` parameter
Future<T?> showCustomDialogWidget<T>(
  /// [INFO] required params without name argument
  BuildContext context, {
  /// [INFO] required params with name argument
  required String title,
  String btnLeftText = '',
  String btnRightText = '',
  required VoidCallback? onTap,
  required Widget content,
  bool isFlexible = false,
  bool isDismissible = true,
  bool? isLoading,

  /// [INFO] not required params with name argument
  VoidCallback? onCancelTapLeft,
  VoidCallback? onCancelTapCenter,
  String? image,
  String? contentText,
  double? height,
  Widget? headerActionIcon,
  Function? headerActionOnTap,
  bool isScrollControlled = false,
  bool hideButtons = false,
  bool hideButtonsGap = false,
  bool avoidKeyboard = false,
  bool draggable = true,

  /// [INFO] set true hideLeftButton to hide the left cancel button
  /// params with name argument
  /// default value false
  bool hideLeftButton = false,
}) {
  final List<Widget> children = [
    Padding(
      padding: EdgeInsets.symmetric(vertical: BaseSize.h12),
      child: Center(
        child: Assets.icons.fill.slidePanel.svg(),
      ),
    ),
    Gap.h12,
    Padding(
      padding: horizontalPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: BaseTypography.heading3SemiBold.toNeutral80,
            textAlign: TextAlign.center,
          ),
          if (isDismissible || headerActionIcon != null) ...[
            GestureDetector(
              child: headerActionIcon ?? Assets.icons.line.times.svg(),
              onTap: () {
                headerActionOnTap != null
                    ? headerActionOnTap()
                    : Navigator.pop(context);
              },
            )
          ]
        ],
      ),
    ),
    Gap.h20,
    if (image != null) ...[
      SvgPicture.asset(
        image,
        width: BaseSize.customWidth(120),
        height: BaseSize.customHeight(120),
      ),
      Gap.h20,
    ],
    content,
    Gap.h8,
    if (contentText != null) ...[
      Text(
        contentText,
        style: BaseTypography.textLRegular,
        textAlign: TextAlign.center,
      ),
      Gap.h24,
    ] else
      Gap.h8,
    hideButtons
        ? Gap.customGapHeight(hideButtonsGap ? 0 : 64)
        : hideLeftButton
            ? Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: horizontalPadding,
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: BaseSize.h28, top: BaseSize.h16),
                        child: ButtonWidget.primary(
                          buttonSize: ButtonSize.medium,
                          color: BaseColor.primary3,
                          overlayColor: BaseColor.white.withOpacity(.5),
                          isShrink: true,
                          text: btnRightText,
                          onTap: onTap,
                        ),
                      ),
                    ),
                  )
                ],
              )
            : Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: BaseSize.w16,
                  vertical: BaseSize.h28,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: ButtonWidget.outlined(
                        buttonSize: ButtonSize.medium,
                        spacer: true,
                        isShrink: true,
                        text: btnLeftText,
                        onTap: () {
                          /// [INFO] this function to pop the widget
                          /// im not use context.pop() because err: _AssertionError ('package:go_router/src/matching.dart': Failed assertion: line 104 pos 9: '_matches.isNotEmpty': You have popped the last page off of the stack, there are no pages left to show)
                          onCancelTapLeft != null
                              ? onCancelTapLeft.call()
                              : Navigator.pop(context);
                        },
                      ),
                    ),
                    Gap.w12,
                    Expanded(
                      child: ButtonWidget.primary(
                        buttonSize: ButtonSize.medium,
                        isShrink: true,
                        text: btnRightText,
                        onTap: onTap,
                        isLoading: isLoading ?? false,
                      ),
                    )
                  ],
                ),
              ),
  ];

  return showModalBottomSheet<T>(
    /// [INFO] call context in every use of show dialog
    context: context,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: draggable,
    shape: RoundedRectangleBorder(
      // <-- SEE HERE
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(BaseSize.customRadius(16)),
      ),
    ),
    builder: (context) {
      if (isFlexible) {
        if (avoidKeyboard) {
          return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Wrap(
                children: children,
              ));
        }
        return Wrap(
          children: children,
        );
      }

      if (avoidKeyboard) {
        return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SizedBox(
              height: height,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: children,
              ),
            ));
      }

      return SizedBox(
        height: height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      );
    },
  );
}
