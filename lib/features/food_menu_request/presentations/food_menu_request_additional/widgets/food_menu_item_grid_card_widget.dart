import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';

class FoodMenuItemGridCardWidget extends StatelessWidget {
  const FoodMenuItemGridCardWidget({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
  });

  final String imageUrl;
  final String title;
  final int price;


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(BaseSize.radiusLg),
        border: Border.all(
          color: BaseColor.neutral.shade20,
        ),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(BaseSize.radiusLg),
            ),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              height: BaseSize.customHeight(140),
            ),
          ),
          Gap.h8,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: BaseSize.w16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gap.customGapHeight(10),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TypographyTheme.textMSemiBold.toNeutral80,
                ),
                Gap.h8,
                Text(
                  price.toRupiah,
                  style: TypographyTheme.textSRegular.toNeutral60,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
