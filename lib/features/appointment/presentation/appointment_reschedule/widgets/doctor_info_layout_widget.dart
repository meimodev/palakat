import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

class DoctorInfoLayoutWidget extends StatelessWidget {
  const DoctorInfoLayoutWidget({
    super.key,
    required this.name,
    required this.field,
    required this.price,
    this.isLoadingPrice = false,
    required this.imageUrl,
  });

  final String name;
  final String field;
  final int price;
  final bool isLoadingPrice;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(BaseSize.w16),
      decoration: BoxDecoration(
        border: Border.all(
          color: BaseColor.neutral.shade20,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(BaseSize.radiusLg),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.all(
              Radius.circular(BaseSize.radiusLg),
            ),
            child: Stack(
              children: <Widget>[
                ImageNetworkWidget(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  width: BaseSize.customWidth(82),
                  height: BaseSize.customWidth(82),
                ),
              ],
            ),
          ),
          Gap.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TypographyTheme.bodySemiBold.fontColor(
                    BaseColor.neutral.shade60,
                  ),
                ),
                Gap.h8,
                Text(
                  field,
                  style: TypographyTheme.textSRegular.fontColor(
                    BaseColor.neutral.shade60,
                  ),
                ),
                Gap.h8,
                isLoadingPrice
                    ? ShimmerWidget(height: BaseSize.h16)
                    : Text(
                        "${price.toRupiah}/session",
                        style: TypographyTheme.textMSemiBold.fontColor(
                          BaseColor.secondary2,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
