import 'package:flutter/cupertino.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/utils.dart';
import 'package:palakat/core/widgets/widgets.dart';

Future showGeneralDialogWidget(
  BuildContext context, {
  Widget? image,
  String headerTitle = '',
  String? title,
  void Function()? action,
  Widget? content,
  String? subtitle,
  void Function()? onSecondaryAction,
  String? secondaryButtonTitle,
  String primaryButtonTitle = 'Ok',
  bool isDissmissible = true,
  bool avoidKeyboard = false,
  bool hideButtons = false,
}) {
  return showCustomDialogWidget(
    context,
    title: headerTitle,
    hideLeftButton: secondaryButtonTitle.isNull(),
    btnLeftText: secondaryButtonTitle.toString(),
    hideButtons: hideButtons,
    btnRightText: primaryButtonTitle,
    onCancelTapLeft: onSecondaryAction,
    onTap: action,
    isFlexible: true,
    isScrollControlled: true,
    avoidKeyboard: avoidKeyboard,
    content: Padding(
      padding: horizontalScreenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (image != null) ...[image, Gap.h28],
          if (title != null)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: BaseSize.customWidth(10),
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: BaseTypography.headlineSmall.toNeutral80,
              ),
            ),
          if (subtitle.isNotNull()) ...[
            Gap.h12,
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: BaseSize.customWidth(22.5),
              ),
              child: Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: BaseTypography.labelSmall.toNeutral60,
              ),
            ),
          ],
          if (content != null) content
        ],
      ),
    ),
  );
}