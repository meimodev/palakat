import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/features/food_menu_request/presentations/food_menu_request_summary/widgets/widgets.dart';

class PrescriptionTermAndConditionWidget extends StatelessWidget {
  const PrescriptionTermAndConditionWidget({
    super.key,
    required this.htmlTermCondition,
  });

  final dynamic htmlTermCondition;
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
                  LocaleKeys.text_termAndConditionsSymbol.tr(),
                  style: TypographyTheme.textLSemiBold.toNeutral80,
                ),
              ],
            ),
            Gap.h8,
            const HLineDivider(),
            Html(
              data: htmlTermCondition,
              style: {
                "p": Style(
                    fontSize: FontSize(14.0), // Set font size to 14px
                    fontWeight: FontWeight.normal,
                    color: BaseColor
                        .neutral.shade60 // Set font weight to 400 (normal)
                    ),
                "li": Style(
                    fontSize: FontSize(14.0), // Set font size to 14px
                    fontWeight: FontWeight.normal,
                    color: BaseColor
                        .neutral.shade60 // Set font weight to 400 (normal)
                    ),
              },
            ),
          ],
        ),
      ),
    );
  }
}
