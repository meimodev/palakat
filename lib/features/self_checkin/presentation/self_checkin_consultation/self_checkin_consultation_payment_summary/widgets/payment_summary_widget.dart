import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/features/food_menu_request/presentations/food_menu_request_summary/widgets/widgets.dart';

class PaymentSummaryWidget extends StatelessWidget {
  const PaymentSummaryWidget({super.key, required this.paymentSummary});

  final List<Map<String, dynamic>> paymentSummary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: BaseSize.h4),
      decoration: BoxDecoration(
        border: Border.all(color: BaseColor.neutral.shade20, width: 1),
        borderRadius: BorderRadius.circular(BaseSize.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
        child: Column(
          children: [
            Row(
              children: [
                Assets.icons.line.listOfParts.svg(
                    height: BaseSize.customHeight(24),
                    width: BaseSize.customHeight(24),
                    colorFilter: BaseColor.primary3.filterSrcIn),
                Gap.w8,
                Text(
                  LocaleKeys.text_paymentSummary.tr(),
                  style: TypographyTheme.textLSemiBold.toNeutral80,
                ),
              ],
            ),
            Gap.h8,
            const HLineDivider(),
            Gap.h8,
            for (int i = 0; i < paymentSummary.length; i++)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          paymentSummary[i]['type'].toUpperCase(),
                          style: TypographyTheme.textMRegular.toNeutral60,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          softWrap: true,
                        ),
                      ),
                      Gap.w12,
                      Text(
                        paymentSummary[i]['price'],
                        style: TypographyTheme.textMRegular.toNeutral60,
                      ),
                    ],
                  ),
                  Gap.h16,
                ],
              ),
            HLineDivider(),
            Gap.h16,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    LocaleKeys.text_totalPayment.tr(),
                    style: TypographyTheme.textMSemiBold.toNeutral80,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    softWrap: true,
                  ),
                ),
                Gap.w12,
                Text(
                  "Rp 711.000",
                  style: TypographyTheme.textMSemiBold.toNeutral80,
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
