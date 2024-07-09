import 'package:flutter/material.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/utils.dart';

class SegmentTitleWidget extends StatelessWidget {
  const SegmentTitleWidget({
    super.key,
    this.onPressedViewAll,
    required this.count,
    required this.title,
  });

  final VoidCallback? onPressedViewAll;
  final int count;
  final String title;

  @override
  Widget build(BuildContext context) {
    if (count == 0) {
      return Container(
        decoration: BoxDecoration(
          color: BaseColor.cardBackground1,
          borderRadius: BorderRadius.circular(
            BaseSize.radiusMd,
          ),
        ),
        padding: EdgeInsets.symmetric(
          vertical: BaseSize.w24,
          horizontal: BaseSize.w8,
        ),
        child: Text(
          "Seems there is no $title related -_-",
          textAlign: TextAlign.center,
          style: BaseTypography.bodyMedium.toSecondary,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$title ($count)",
          style: BaseTypography.titleMedium.toSecondary,
        ),
        GestureDetector(
          onTap: onPressedViewAll,
          child: Row(
            children: [
              Text(
                "View All",
                style: BaseTypography.bodySmall.toSecondary,
              ),
              Gap.w4,
              Assets.icons.line.chevronForwardOutline.svg(
                colorFilter: BaseColor.secondaryText.filterSrcIn,
                width: BaseSize.w12,
                height: BaseSize.h12,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
