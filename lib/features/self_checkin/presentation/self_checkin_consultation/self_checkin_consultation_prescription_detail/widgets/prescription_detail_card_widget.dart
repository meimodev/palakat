import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/features/food_menu_request/presentations/food_menu_request_summary/widgets/widgets.dart';

class PrescriptionDetailCardWidget extends StatelessWidget {
  const PrescriptionDetailCardWidget({super.key, required this.prescription});

  final List<Map<String, dynamic>> prescription;

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
                Assets.icons.line.pill.svg(
                    height: BaseSize.customHeight(24),
                    width: BaseSize.customHeight(24),
                    colorFilter: BaseColor.primary3.filterSrcIn),
                Gap.w8,
                Text(
                  LocaleKeys.text_recommendation.tr(),
                  style: TypographyTheme.textLSemiBold.toNeutral60,
                ),
              ],
            ),
            Gap.h8,
            const HLineDivider(),
            Gap.h8,
            for (int i = 0; i < prescription.length; i++)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          prescription[i]['item_name'].toUpperCase(),
                          style: TypographyTheme.textMSemiBold.toNeutral80,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      ),
                      Gap.w16,
                      RichText(
                        text: TextSpan(
                          text: "Qty: ",
                          style: TypographyTheme.textXSRegular.toNeutral80,
                          children: <TextSpan>[
                            TextSpan(
                              text: prescription[i]['qty'].toString(),
                              style: TypographyTheme.textXSRegular.toNeutral60,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Gap.h4,
                  Text(
                    prescription[i]['dosage'],
                    textAlign: TextAlign.start,
                    style: TypographyTheme.textXSRegular.toNeutral60,
                  ),
                  Gap.h4,
                  Text(
                    prescription[i]['instructions'],
                    textAlign: TextAlign.start,
                    style: TypographyTheme.textXSRegular.toNeutral60,
                  ),
                  Gap.h4,
                  RichText(
                    textAlign: TextAlign.start,
                    text: TextSpan(
                      text: "Time: ",
                      style: TypographyTheme.textXSRegular.toNeutral80,
                      children: <TextSpan>[
                        TextSpan(
                          text: prescription[i]['time'],
                          style: TypographyTheme.textXSRegular.toNeutral60,
                        ),
                      ],
                    ),
                  ),
                  Gap.h4,
                  RichText(
                    textAlign: TextAlign.start,
                    text: TextSpan(
                      text: "Notes: ",
                      style: TypographyTheme.textXSRegular.toNeutral60,
                      children: <TextSpan>[
                        TextSpan(
                          text: prescription[i]['notes'],
                          style: TypographyTheme.textXSRegular.toNeutral60,
                        ),
                      ],
                    ),
                  ),
                  Gap.h8,
                ],
              ),
          ],
        ),
      ),
    );
  }
}
