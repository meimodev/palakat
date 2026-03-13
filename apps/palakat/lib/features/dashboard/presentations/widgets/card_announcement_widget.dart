import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/extensions.dart';

class CardAnnouncementWidget extends StatelessWidget {
  const CardAnnouncementWidget({
    super.key,
    required this.title,
    required this.onPressedCard,
    this.onPressedDownload,
    required this.publishedOn,
  });

  final String title;
  final DateTime publishedOn;
  final VoidCallback onPressedCard;
  final VoidCallback? onPressedDownload;

  @override
  Widget build(BuildContext context) {
    final canDownload = onPressedDownload != null;
    return Material(
      color: BaseColor.cardBackground1,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      surfaceTintColor: BaseColor.yellow[50],
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      ),
      child: InkWell(
        onTap: onPressedCard,
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w16),
          child: Row(
            children: [
              Container(
                width: BaseSize.w40,
                height: BaseSize.w40,
                decoration: BoxDecoration(
                  color: BaseColor.yellow[100],
                  borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: BaseColor.yellow[200]!.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: FaIcon(
                  AppIcons.document,
                  size: BaseSize.w20,
                  color: BaseColor.yellow[700],
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
                        fontWeight: FontWeight.w700,
                        color: BaseColor.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Gap.h4,
                    Text(
                      publishedOn.EEEEddMMMyyyy,
                      style: BaseTypography.labelMedium.copyWith(
                        color: BaseColor.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (canDownload) ...[
                Gap.w12,
                Material(
                  color: BaseColor.yellow[50],
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                    side: BorderSide(color: BaseColor.yellow[200]!, width: 1),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    onTap: onPressedDownload,
                    child: Container(
                      width: BaseSize.w40,
                      height: BaseSize.w40,
                      alignment: Alignment.center,
                      child: FaIcon(
                        AppIcons.download,
                        size: BaseSize.w18,
                        color: BaseColor.yellow[700],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
