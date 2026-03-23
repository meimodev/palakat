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
      color: AppColors.surfaceContainerLowest,
      elevation: 1,
      shadowColor: AppColors.onSurface,
      surfaceTintColor: AppColors.warning,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: InkWell(
        onTap: onPressedCard,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: AppColors.warning.shade100,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: AppColors.warning.shade200,
                  ),
                  boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 8),
                ),
                alignment: Alignment.center,
                child: FaIcon(
                  AppIcons.document,
                  size: 20.0,
                  color: AppColors.warning.shade700,
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
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Gap.h4,
                    Text(
                      publishedOn.EEEEddMMMyyyy,
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (canDownload) ...[
                Gap.w12,
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 8),
                  ),
                  child: Material(
                    color: AppColors.warning.shade100,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(
                        color: AppColors.warning.shade200,
                        width: 1,
                      ),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: InkWell(
                    onTap: onPressedDownload,
                    child: Container(
                      width: 40.0,
                      height: 40.0,
                      alignment: Alignment.center,
                      child: FaIcon(
                        AppIcons.download,
                        size: 18.0,
                        color: AppColors.warning.shade700,
                      ),
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
