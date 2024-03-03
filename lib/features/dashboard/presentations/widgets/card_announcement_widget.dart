import 'package:flutter/material.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/utils.dart';
import 'package:palakat/core/widgets/widgets.dart';

class CardAnnouncementWidget extends StatelessWidget {
  const CardAnnouncementWidget({
    super.key,
    required this.title,
    required this.onPressedCard,
  });

  final String title;
  final VoidCallback onPressedCard;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      onTap: onPressedCard,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: BaseSize.w12,
          vertical: BaseSize.h12,
        ),
        decoration: BoxDecoration(
          color: BaseColor.cardBackground1,
          borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        ),
        child: Row(
          children: [
            Assets.icons.line.document.svg(
              width: BaseSize.customFontSize(12),
              height: BaseSize.customFontSize(12),
              colorFilter: BaseColor.secondaryText.filterSrcIn,
            ),
            Gap.w12,
            Expanded(
              child: Text(
                title,
                style: BaseTypography.bodySmall,
              ),
            ),
            Gap.w12,
            Row(
              children: [
                DividerWidget(
                  color: BaseColor.primaryText,
                  height: BaseSize.h12,
                  thickness: 1,
                ),
                Gap.w12,
                Assets.icons.line.download.svg(
                  width: BaseSize.customFontSize(12),
                  height: BaseSize.customFontSize(12),
                  colorFilter: BaseColor.primaryText.filterSrcIn,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
