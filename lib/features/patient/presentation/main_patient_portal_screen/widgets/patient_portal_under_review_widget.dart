import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';

import 'widgets.dart';

class PatientPortalUnderReviewWidget extends StatelessWidget {
  const PatientPortalUnderReviewWidget({super.key});

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
              Assets.images.review1.image(
                width: BaseSize.customWidth(120),
                height: BaseSize.customHeight(120),
              ),
              Gap.customGapHeight(30),
              Text(
                LocaleKeys.text_yourAccountIsUnderReview.tr(),
                style: TypographyTheme.textMBold.toNeutral80,
              ),
              Gap.customGapHeight(10),
              Text(
                LocaleKeys.text_pleaseWait1x24Hours.tr(),
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
