import 'package:palakat_shared/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:palakat_shared/constants.dart';
import 'package:palakat_shared/theme.dart';

class CardOverviewListItemWidget extends StatelessWidget {
  const CardOverviewListItemWidget({
    super.key,
    required this.title,
    required this.type,
    required this.onPressedCard,
  });

  final String title;
  final VoidCallback onPressedCard;
  final ActivityType type;

  @override
  Widget build(BuildContext context) {
    // Determine icon and colors based on activity type
    final bool isAnnouncement = type == ActivityType.announcement;
    final bool isService = type == ActivityType.service;

    final IconData iconData = isService
        ? Icons.church_outlined
        : isAnnouncement
        ? Icons.campaign_outlined
        : Icons.event_outlined;

    final Color bgColor = AppColors.primary;

    final Color iconColor = AppColors.primary.shade100;

    final Color chipBg = AppColors.primary;

    final Color chipFg = AppColors.primary.shade100;

    final Color chipBorder = AppColors.secondary;

    return Material(
      color: AppColors.surfaceContainerLowest,
      elevation: 1,
      shadowColor: AppColors.onSurface,
      surfaceTintColor: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onPressedCard,
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 32.0,
                height: 32.0,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(iconData, size: 16.0, color: iconColor),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    Gap.h6,
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: chipBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: chipBorder, width: 1),
                      ),
                      child: Text(
                        type.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          color: chipFg,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Gap.w8,
              // Arrow indicator
              Icon(
                Icons.chevron_right,
                size: 20.0,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
