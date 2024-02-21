import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

class BottomSheetAccountUnderReviewWidget extends StatelessWidget {
  const BottomSheetAccountUnderReviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Assets.images.search1.image(
            height: BaseSize.customHeight(100),
            width: BaseSize.customWidth(100),
          ),
          Gap.customGapHeight(30),
          Text(
            LocaleKeys.text_yourAccountIsUnderReview.tr(),
            textAlign: TextAlign.center,
            style: TypographyTheme.textLBold.toNeutral80,
          ),
          Gap.customGapHeight(10),
          Text(
            LocaleKeys.text_weWillSendAConfirmationAndInstruction.tr(),
            textAlign: TextAlign.center,
            style: TypographyTheme.textMRegular.toNeutral60,
          ),
          Gap.customGapHeight(40),
        ],
      ),
    );
  }
}

Future<void> showAccountUnderReviewDialog({
  required BuildContext context,
  required void Function() onPressedBackToHome,
  bool dismissible = true,
  bool draggable = true,
  VoidCallback? onPressedClose,

}) async{
  await showCustomDialogWidget(
    context,
    title: "",
    isDissmissible: dismissible,
    draggable: draggable,
    headerActionOnTap: onPressedClose,
    onTap: () {
      Navigator.of(context).pop();
      onPressedBackToHome();
    },
    hideLeftButton: true,
    isScrollControlled: true,
    btnRightText: LocaleKeys.text_backToHome.tr(),
    content: const BottomSheetAccountUnderReviewWidget(),
  );
}
