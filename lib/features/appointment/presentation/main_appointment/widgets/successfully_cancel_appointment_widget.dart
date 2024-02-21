import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

void showSuccessfullyCancelAppointmentDialog({
  required BuildContext context,
  required void Function() onProceedTap,
}) {
  showGeneralDialogWidget(
    context,
    image: Assets.images.check.image(
      width: BaseSize.customWidth(100),
      height: BaseSize.customWidth(100),
    ),
    title: LocaleKeys.text_youHaveCanceledYourAppointment.tr(),
    subtitle: LocaleKeys.text_weWillReturnYourPaymentWithin2x24Hours.tr(),
    primaryButtonTitle: LocaleKeys.text_backToAppointment.tr(),
    content: Gap.h28,
    action: () {
      onProceedTap();
    },
  );
}
