import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/assets/assets.gen.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/utils.dart';
import 'package:palakat/core/widgets/widgets.dart';

Future showSuccessAlertDialogWidget(
  BuildContext context, {
  required String title,
  String subtitle = '',
  required void Function() action,
  String actionButtonTitle = 'OK',
  bool isDissmissible = true,
}) {
  return showCustomDialogWidget(
    context,
    title: '',
    hideLeftButton: true,
    btnRightText: actionButtonTitle,
    onTap: () {
      action();
      context.pop();
    },
    content: Padding(
      padding: EdgeInsets.symmetric(
          horizontal: BaseSize.w64, vertical: BaseSize.h20),
      child: Expanded(
        child: Column(children: [
          Assets.images.check.image(
              width: BaseSize.customWidth(100),
              height: BaseSize.customWidth(100)),
          Gap.h32,
          Text(
            title,
            textAlign: TextAlign.center,
            style:
                BaseTypography.titleMedium.fontColor(BaseColor.neutral.shade80),
          ),
          Gap.h12,
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: BaseTypography.headlineSmall
                .fontColor(BaseColor.neutral.shade60),
          ),
        ]),
      ),
    ),
  );
}
