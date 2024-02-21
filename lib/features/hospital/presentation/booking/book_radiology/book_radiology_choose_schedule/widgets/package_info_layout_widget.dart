import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';

class PackageInfoLayoutWidget extends StatelessWidget {
  const PackageInfoLayoutWidget({
    super.key,
    required this.category,
    required this.name,
    required this.price,
  });

  final String category;
  final String name;
  final String price;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w16,
        vertical: BaseSize.h16,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: BaseColor.neutral.shade20,
        ),
        borderRadius: BorderRadius.circular(
          BaseSize.radiusMd,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            name,
            style: TypographyTheme.bodySemiBold.toNeutral60,
          ),
          Gap.customGapHeight(4),
          Text(
            category,
            style: TypographyTheme.textSRegular.toNeutral60,
          ),
          Gap.h20,
          Text(
            price,
            style: TypographyTheme.textXLSemiBold.toNeutral70,
          ),
          Row(
            children: [
              Text("*", style: TypographyTheme.textSRegular.toRed500),
              Text(
                LocaleKeys.text_priceIncludedWithTheGeneralDoctor.tr(),
                style: TypographyTheme.textSRegular.toNeutral60,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
