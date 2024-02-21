import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/hospital/domain/hospital_list_item.dart';

class OurHospitalListItemWidget extends StatelessWidget {
  const OurHospitalListItemWidget({
    Key? key,
    required this.item,
    this.onPressedItem,
    this.padding,
    this.imageHeight,
    this.imageWidth,
    this.alignCenter = true,
  }) : super(key: key);

  final HospitalListItem item;
  final bool alignCenter;

  final double? imageHeight;
  final double? imageWidth;
  final void Function(HospitalListItem value)? onPressedItem;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressedItem != null ? () => onPressedItem!(item) : null,
      borderRadius: BorderRadius.circular(BaseSize.radiusLg),
      child: Container(
        padding: padding ?? EdgeInsets.all(BaseSize.w16),
        decoration: BoxDecoration(
          border: Border.all(
            color: BaseColor.neutral.shade20,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(
            BaseSize.radiusLg,
          ),
        ),
        child: Row(
          crossAxisAlignment: alignCenter
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            Container(
              clipBehavior: Clip.hardEdge,
              height: BaseSize.customWidth(imageHeight ?? 82),
              width: BaseSize.customWidth(imageWidth ?? 82),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(BaseSize.radiusLg),
                ),
              ),
              child: ImageNetworkWidget(
                imageUrl: item.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Gap.w16,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                alignCenter ? const SizedBox() : Gap.h8,
                Text(
                  item.name,
                  style: TypographyTheme.textLRegular.toNeutral80,
                ),
                Gap.customGapHeight(6),
                Row(
                  children: [
                    _buildRowItem(
                      icon: Assets.icons.line.mapPin,
                      text: item.distance,
                    ),
                    Gap.customGapWidth(6),
                    _buildRowItem(
                      icon: Assets.icons.line.mapPin2,
                      text: item.location,
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRowItem({
    required SvgGenImage icon,
    required String text,
  }) {
    return Row(
      children: [
        icon.svg(
          width: BaseSize.customWidth(20),
          height: BaseSize.customWidth(20),
          colorFilter: BaseColor.primary3.filterSrcIn,
        ),
        Gap.customGapWidth(2),
        Text(
          text,
          style:
              TypographyTheme.textSRegular.toNeutral50,
        ),
      ],
    );
  }
}
