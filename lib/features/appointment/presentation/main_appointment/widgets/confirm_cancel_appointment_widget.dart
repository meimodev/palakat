import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

void showConfirmCancelAppointmentDialog({
  required BuildContext context,
  required TextEditingController controller,
  required void Function() onTapYes,
}) {
  showGeneralDialogWidget(
    context,
    image: Assets.images.questionMark.image(
      width: BaseSize.customWidth(90),
      height: BaseSize.customWidth(90),
    ),
    avoidKeyboard: true,
    title: LocaleKeys.text_cancelAppointment.tr(),
    subtitle: LocaleKeys.text_areYouSureYouWantToCancelYourAppointment.tr(),
    primaryButtonTitle: LocaleKeys.text_yes.tr(),
    secondaryButtonTitle: LocaleKeys.text_no.tr(),
    content: Padding(
      padding: EdgeInsets.only(
        left: BaseSize.w12,
        right: BaseSize.w12,
        top: BaseSize.h20,
        bottom: BaseSize.h8,
      ),
      child: InputFormWidget(
        controller: controller,
        hintText: LocaleKeys.text_reasonYouCancelTheAppointment.tr(),
        hasIconState: false,
        validator: ValidationBuilder(label: LocaleKeys.text_reason.tr())
            .required()
            .build(),
        label: LocaleKeys.text_reason.tr(),
        keyboardType: TextInputType.text,
        hasBorderState: false,
        maxLines: 1,
      ),
    ),
    action: () {
      onTapYes();
    },
    onSecondaryAction: () {
      context.pop();
    },
  );
}
