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
    this.leadingIcon,
    this.leadingBg,
    this.leadingFg,
  });

  final VoidCallback? onPressedViewAll;
  final int count;
  final String title;
  final IconData? leadingIcon;
  final Color? leadingBg;
  final Color? leadingFg;

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
          "Seems there is no related $title  -_-",
          textAlign: TextAlign.center,
          style: BaseTypography.bodyMedium.toSecondary,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (leadingIcon != null)
              Container(
                width: BaseSize.w20,
                height: BaseSize.w20,
                decoration: BoxDecoration(
                  color: leadingBg ?? BaseColor.neutral20,
                  borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                  border: Border.all(color: (leadingBg ?? BaseColor.neutral20)),
                ),
                alignment: Alignment.center,
                child: Icon(
                  leadingIcon,
                  size: BaseSize.w14,
                  color: leadingFg ?? BaseColor.primaryText,
                ),
              ),
            if (leadingIcon != null) Gap.w8,
            Text(
              "$title ($count)",
              style: BaseTypography.titleMedium.toSecondary,
            ),
          ],
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
