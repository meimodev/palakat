import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/features/food_menu_request/presentations/food_menu_request_summary/widgets/widgets.dart';

class MedicationWidget extends StatelessWidget {
  const MedicationWidget({super.key, required this.prescription});

  final List<Map<String, dynamic>> prescription;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: BaseSize.h4),
      decoration: BoxDecoration(
        border: Border.all(
          color: BaseColor.neutral.shade20,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(BaseSize.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              children: [
                Assets.icons.line.pill.svg(
                  height: BaseSize.customHeight(24),
                  width: BaseSize.customHeight(24),
                  colorFilter: BaseColor.primary3.filterSrcIn,
                ),
                Gap.w8,
                Text(
                  LocaleKeys.text_medication.tr(),
                  style: TypographyTheme.textLSemiBold.toNeutral80,
                ),
              ],
            ),
            Gap.h8,
            const HLineDivider(),
            Gap.h8,
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: BaseColor.primary2,
                borderRadius: BorderRadius.circular(BaseSize.radiusLg),
              ),
              child: Row(
                children: [
                  Assets.icons.fill.checkCircle.svg(
                    height: BaseSize.customHeight(24),
                    width: BaseSize.customHeight(24),
                    colorFilter: BaseColor.primary3.filterSrcIn,
                  ),
                  Gap.w8,
                  Expanded(
                    child: Text(
                      LocaleKeys.text_medicationHasBeenUpdatedByThePharmacy
                          .tr(),
                      style: TypographyTheme.textXSRegular.toNeutral80,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
            Gap.h8,
            for (int i = 0; i < prescription.length; i++)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap.h12,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          prescription[i]['item_name'],
                          style: TypographyTheme.textMSemiBold.toNeutral80,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        prescription[i]['price'],
                        style: TypographyTheme.textMRegular.toNeutral80,
                      )
                    ],
                  ),
                  Text(
                    prescription[i]['uom'],
                    style: TypographyTheme.textSRegular.toNeutral50,
                  ),
                  RichText(
                    text: TextSpan(
                      text: "Qty: ",
                      style: TypographyTheme.textSRegular.toNeutral80,
                      children: <TextSpan>[
                        TextSpan(
                          text: prescription[i]['qty'].toString(),
                          style: TypographyTheme.textXSRegular.toNeutral60,
                        ),
                      ],
                    ),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}
