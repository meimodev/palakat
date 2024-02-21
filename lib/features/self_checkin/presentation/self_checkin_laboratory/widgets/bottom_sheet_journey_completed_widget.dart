import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

void showJourneyCompletedDialogWidget(BuildContext context) {
  showGeneralDialogWidget(
    context,
    image: Assets.images.check.image(
      width: BaseSize.customWidth(100),
      height: BaseSize.customHeight(100),
    ),
    title: LocaleKeys.text_yourJourneyHasCompleted.tr(),
    subtitle:
    LocaleKeys.text_thankYouForTrustingUsAsTheHospitalOfYourChoice.tr(),
    content: Gap.h40,
    primaryButtonTitle: LocaleKeys.text_backToHome.tr(),
    action: () => context.goNamed(AppRoute.home),
  );
}