import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/utils.dart';

class CardDatePreviewWidget extends StatelessWidget {
  const CardDatePreviewWidget({
    super.key,
    required this.date,
    this.selected = false,
    required this.onPressedCardDatePreview,
    this.height,
    this.width,
  });

  final int date;
  final bool selected;
  final VoidCallback onPressedCardDatePreview;

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressedCardDatePreview,
      child: Container(
        height: height,
        width: width,
        padding: EdgeInsets.only(
          top: BaseSize.h6,
          left: BaseSize.w6,
          right: BaseSize.w6,
        ),
        decoration: BoxDecoration(
          color: BaseColor.cardBackground1,
          borderRadius: BorderRadius.circular(BaseSize.radiusMd),
          border: Border.all(
            color: selected ? BaseColor.primaryText : BaseColor.transparent,
          ),
        ),
        child: Column(
          children: [
            Text(
              "SUN",
              style: BaseTypography.bodyMedium.toSecondary,
            ),
            Text(
              date.toString(),
              style: BaseTypography.headlineSmall,
            ),
            Gap.h6,
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "2 Service",
                  style: BaseTypography.labelSmall.toBold,
                ),
                Text(
                  "4 Events",
                  style: BaseTypography.labelSmall.toBold,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
