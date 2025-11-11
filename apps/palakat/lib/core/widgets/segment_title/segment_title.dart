import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';

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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: BaseColor.neutral20,
            width: 1,
          ),
        ),
        padding: EdgeInsets.symmetric(
          vertical: BaseSize.h24,
          horizontal: BaseSize.w16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: BaseSize.w32,
              color: BaseColor.secondaryText,
            ),
            Gap.h8,
            Text(
              "No $title available",
              textAlign: TextAlign.center,
              style: BaseTypography.bodyMedium.copyWith(
                color: BaseColor.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              if (leadingIcon != null)
                Container(
                  width: BaseSize.w40,
                  height: BaseSize.w40,
                  decoration: BoxDecoration(
                    color: leadingBg ?? BaseColor.teal[100],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (leadingBg ?? BaseColor.teal[200]!)
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    leadingIcon,
                    size: BaseSize.w20,
                    color: leadingFg ?? BaseColor.teal[700],
                  ),
                ),
              if (leadingIcon != null) Gap.w12,
              Flexible(
                child: Text(
                  title,
                  style: BaseTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: BaseColor.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Gap.w8,
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: BaseSize.w10,
                  vertical: BaseSize.h4,
                ),
                decoration: BoxDecoration(
                  color: BaseColor.teal[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: BaseColor.teal[200]!,
                    width: 1,
                  ),
                ),
                child: Text(
                  count.toString(),
                  style: BaseTypography.labelMedium.copyWith(
                    color: BaseColor.teal[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Gap.w12,
        InkWell(
          onTap: onPressedViewAll,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: BaseSize.w8,
              vertical: BaseSize.h4,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "View All",
                  style: BaseTypography.bodyMedium.copyWith(
                    color: BaseColor.teal[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Gap.w4,
                Icon(
                  Icons.arrow_forward,
                  size: BaseSize.w16,
                  color: BaseColor.teal[700],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
