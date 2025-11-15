import 'package:flutter/material.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/extensions.dart';

class CardAnnouncementWidget extends StatelessWidget {
  const CardAnnouncementWidget({
    super.key,
    required this.title,
    required this.onPressedCard,
    required this.onPressedDownload,
    required this.publishedOn,
  });

  final String title;
  final DateTime publishedOn;
  final VoidCallback onPressedCard;
  final VoidCallback onPressedDownload;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BaseColor.cardBackground1,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      surfaceTintColor: BaseColor.yellow[50],
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onPressedCard,
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w16),
          child: Row(
            children: [
              // Document icon in circle
              Container(
                width: BaseSize.w40,
                height: BaseSize.w40,
                decoration: BoxDecoration(
                  color: BaseColor.yellow[100],
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: BaseColor.yellow[200]!.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Assets.icons.line.documentOutline.svg(
                  width: BaseSize.w20,
                  height: BaseSize.w20,
                  colorFilter: BaseColor.yellow[700]!.filterSrcIn,
                ),
              ),
              Gap.w12,
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: BaseTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Gap.h4,
                    Text(
                      publishedOn.EEEEddMMMyyyy,
                      style: BaseTypography.labelMedium.copyWith(
                        color: BaseColor.yellow[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Gap.w12,
              // Download button
              Material(
                color: BaseColor.yellow[50],
                elevation: 2,
                shadowColor: Colors.black.withValues(alpha: 0.1),
                shape: const CircleBorder(),
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  onTap: onPressedDownload,
                  child: Container(
                    width: BaseSize.w40,
                    height: BaseSize.w40,
                    alignment: Alignment.center,
                    child: Assets.icons.line.download.svg(
                      width: BaseSize.w20,
                      height: BaseSize.w20,
                      colorFilter: BaseColor.yellow[700]!.filterSrcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
