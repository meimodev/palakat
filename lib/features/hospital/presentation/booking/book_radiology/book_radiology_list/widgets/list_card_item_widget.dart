import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/features/domain.dart';

class ListCardItemWidget extends StatelessWidget {
  const ListCardItemWidget(
      {super.key, required this.service, required this.onTap});

  final BookServiceModel service;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(
        BaseSize.customRadius(12),
      ),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: BaseSize.customWidth(16),
          vertical: BaseSize.customHeight(16),
        ),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: BaseColor.neutral.shade20,
          ),
          borderRadius: BorderRadius.circular(
            BaseSize.customRadius(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              service.category,
              style: TypographyTheme.textSRegular.toPrimary,
            ),
            Gap.h4,
            Text(
              service.name,
              style: TypographyTheme.textLRegular.toNeutral80,
            ),
            Gap.customGapHeight(6),
            Row(
              children: [
                Assets.icons.line.mapPin.svg(
                  width: BaseSize.w20,
                  height: BaseSize.h20,
                  colorFilter: BaseColor.primary3.filterSrcIn,
                ),
                Gap.customGapWidth(2),
                Text(
                  service.locations,
                  style: TypographyTheme.textSRegular.toNeutral60,
                ),
              ],
            ),
            Gap.h12,
            Text(
              service.price,
              style: TypographyTheme.bodyRegular.copyWith(
                fontWeight: FontWeight.w500,
                color: BaseColor.neutral.shade80,
              ),
            ),
            service.discountPrice != null ? Gap.h4 : const SizedBox(),
            service.discountPrice != null
                ? Text(
                    service.discountPrice!,
                    style: TypographyTheme.textMRegular.copyWith(
                      color: BaseColor.neutral.shade50,
                      decoration: TextDecoration.lineThrough,
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
