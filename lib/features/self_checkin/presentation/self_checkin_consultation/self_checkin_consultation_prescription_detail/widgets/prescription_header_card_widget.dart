import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/features/food_menu_request/presentations/food_menu_request_summary/widgets/widgets.dart';

class PrescriptionHeaderCardWidget extends StatelessWidget {
  const PrescriptionHeaderCardWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: BaseSize.h4),
      decoration: BoxDecoration(
        border: Border.all(color: BaseColor.neutral.shade20, width: 1),
        borderRadius: BorderRadius.circular(BaseSize.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              children: [
                Assets.icons.line.medicalFile.svg(
                    height: BaseSize.customHeight(24),
                    width: BaseSize.customHeight(24),
                    colorFilter: BaseColor.primary3.filterSrcIn),
                Gap.w8,
                Text(
                  LocaleKeys.text_prescription.tr(),
                  style: TypographyTheme.textLSemiBold.toNeutral60,
                ),
              ],
            ),
            Gap.h8,
            const HLineDivider(),
            Gap.h8,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocaleKeys.text_status.tr().toUpperCase(),
                  style: TypographyTheme.textXSRegular.toNeutral60,
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                  decoration: BoxDecoration(
                    color: BaseColor.primary1,
                    border:
                        Border.all(color: BaseColor.neutral.shade20, width: 0),
                    borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                  ),
                  child: Text(
                    LocaleKeys.text_readyToRedeemed.tr(),
                    style: TypographyTheme.textXSRegular.toPrimary,
                  ),
                ),
              ],
            ),
            Gap.h16,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocaleKeys.text_prescNo.tr().toUpperCase(),
                  style: TypographyTheme.textXSRegular.toNeutral60,
                ),
                Text(
                  "PR2112NF29N",
                  style: TypographyTheme.textLSemiBold.toNeutral70,
                ),
              ],
            ),
            Gap.h16,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocaleKeys.text_doctor.tr().toUpperCase(),
                  style: TypographyTheme.textXSRegular.toNeutral60,
                ),
                Gap.w64,
                Expanded(
                  child: Text(
                    "dr. Leon Gerald, SpPD",
                    style: TypographyTheme.textLSemiBold.toNeutral70,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            Gap.h16,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocaleKeys.text_dateOfIssue.tr().toUpperCase(),
                  style: TypographyTheme.textXSRegular.toNeutral60,
                ),
                Text(
                  "16 MAR 2023 13:30",
                  style: TypographyTheme.textLSemiBold.toNeutral70,
                ),
              ],
            ),
            Gap.h16,
          ],
        ),
      ),
    );
  }
}
