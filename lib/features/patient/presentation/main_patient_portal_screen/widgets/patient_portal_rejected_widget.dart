import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/features/patient/presentation/main_patient_portal_screen/widgets/widgets.dart';

class PatientPortalRejectedWidget extends StatelessWidget {
  const PatientPortalRejectedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TitleLayoutWidget(
          authorized: false,
          bottomPadding: false,
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Assets.images.rejected.image(
                width: BaseSize.customWidth(120),
                height: BaseSize.customHeight(120),
              ),
              Gap.customGapHeight(30),
              Text(
                LocaleKeys.text_yourAccountIsRejected.tr(),
                style: TypographyTheme.textMBold.toNeutral80,
              ),
              Gap.customGapHeight(10),
              Text(
                LocaleKeys.text_pleaseContactUsViaCallCenter.tr(),
                textAlign: TextAlign.center,
                style: TypographyTheme.textMRegular.toNeutral60,
              ),
            ],
          ),
        ),
      ],
    );
  }

}
