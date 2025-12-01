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
    final bool isService = type == ActivityType.service;
    final IconData iconData = isService
        ? Icons.church_outlined
        : Icons.event_outlined;
    final Color bgColor = isService
        ? BaseColor.green[100]!
        : BaseColor.blue[100]!;
    final Color iconColor = isService
        ? BaseColor.green[700]!
        : BaseColor.blue[700]!;
    final Color chipBg = isService ? BaseColor.green[50]! : BaseColor.blue[50]!;
    final Color chipFg = isService
        ? BaseColor.green[700]!
        : BaseColor.blue[700]!;
    final Color chipBorder = isService
        ? BaseColor.green[200]!
        : BaseColor.blue[200]!;

    return Material(
      color: BaseColor.cardBackground1,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      surfaceTintColor: isService ? BaseColor.green[50] : BaseColor.blue[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onPressedCard,
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w12),
          child: Row(
            children: [
              // Icon container
              Container(
                width: BaseSize.w32,
                height: BaseSize.w32,
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
                child: Icon(iconData, size: BaseSize.w16, color: iconColor),
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
                      style: BaseTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: BaseColor.black,
                      ),
                    ),
                    Gap.h6,
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: BaseSize.w8,
                        vertical: BaseSize.h4,
                      ),
                      decoration: BoxDecoration(
                        color: chipBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: chipBorder, width: 1),
                      ),
                      child: Text(
                        type.name,
                        style: BaseTypography.labelSmall.copyWith(
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
                size: BaseSize.w20,
                color: BaseColor.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
