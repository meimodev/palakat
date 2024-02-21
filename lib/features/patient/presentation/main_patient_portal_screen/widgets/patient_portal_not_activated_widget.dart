import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

import 'widgets.dart';

class PatientPortalNotActivatedWidget extends StatelessWidget {
  const PatientPortalNotActivatedWidget(
      {super.key, required this.onPressedActivatePatientPortal});

  final void Function() onPressedActivatePatientPortal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TitleLayoutWidget(
          authorized: false,
          bottomPadding: true,
        ),
        Assets.images.completedTask1.image(
          width: BaseSize.customWidth(120),
          height: BaseSize.customHeight(120),
        ),
        Gap.customGapHeight(30),
        Text(
          LocaleKeys.text_activateYourPatientPortalToSee.tr(),
          style: TypographyTheme.textMRegular.toNeutral60,
        ),
        Gap.h24,
        ButtonWidget.primary(
          isShrink: true,
          text: LocaleKeys.text_activatePatientPortal.tr(),
          onTap: onPressedActivatePatientPortal,
        ),
      ],
    );
  }
}
