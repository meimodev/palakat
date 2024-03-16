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
    required this.onPressedDownload,
  });

  final String title;
  final VoidCallback onPressedCard;
  final VoidCallback onPressedDownload;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: onPressedCard,
            child: Container(
              padding: EdgeInsets.only(
                left: BaseSize.w12,
                top: BaseSize.h12,
                bottom: BaseSize.h12,
              ),
              decoration: BoxDecoration(
                color: BaseColor.cardBackground1,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(BaseSize.radiusMd),
                  bottomLeft: Radius.circular(BaseSize.radiusMd),
                ),
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
                ],
              ),
            ),
          ),
        ),
        InkWell(
          onTap: onPressedDownload,
          child: Container(
            padding: EdgeInsets.only(
              right: BaseSize.w12,
              top: BaseSize.h12,
              bottom: BaseSize.h12,          ),
            decoration: BoxDecoration(
              color: BaseColor.cardBackground1,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(BaseSize.radiusMd),
                bottomRight: Radius.circular(BaseSize.radiusMd),
              ),

            ),
            child: Row(
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
            ),
          ),
        )
      ],
    );
  }
}
