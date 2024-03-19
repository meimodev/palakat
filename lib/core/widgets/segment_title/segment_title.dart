import 'package:flutter/material.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/utils.dart';

class SegmentTitleWidget extends StatelessWidget {
  const SegmentTitleWidget({
    super.key,
    required this.onPressedViewAll,
    required this.count,
    required this.title,
  });

  final void Function() onPressedViewAll;
  final int count;
  final String title;

  @override
  Widget build(BuildContext context) {
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
