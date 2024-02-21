import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';

class PackageInfoDiscountLayoutWidget extends StatelessWidget {
  const PackageInfoDiscountLayoutWidget({
    super.key,
    required this.category,
    required this.name,
    required this.price,
    this.discountPrice,
  });

  final String category;
  final String name;
  final String price;
  final String? discountPrice;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w20,
        vertical: BaseSize.h20,
      ),
      decoration: BoxDecoration(
        color: BaseColor.primary1,
        borderRadius: BorderRadius.circular(
          BaseSize.radiusMd,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            category,
            style: TypographyTheme.textMRegular.toPrimary,
          ),
          Gap.customGapHeight(6),
          Text(
            name,
            style: TypographyTheme.textXLRegular.toNeutral80.w500,
          ),
          Gap.h20,
          Text(
            price,
            style: TypographyTheme.textXLSemiBold.toNeutral70,
          ),
          discountPrice != null
              ? Text(
                  discountPrice!,
                  style: TypographyTheme.textMRegular.copyWith(
                    color: BaseColor.neutral.shade50,
                    decoration: TextDecoration.lineThrough,
                  ),
                )
              : const SizedBox(),
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
