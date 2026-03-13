import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:palakat/core/constants/constants.dart';

class CardPublishingOperationWidget extends StatelessWidget {
  const CardPublishingOperationWidget({
    super.key,
    required this.title,
    required this.description,
    required this.onPressedCard,
  });

  final String title;
  final String description;
  final VoidCallback onPressedCard;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BaseColor.primary[500],
      elevation: 2,
      shadowColor: BaseColor.primary[300]!.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BaseSize.radiusLg),
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onPressedCard,
        splashColor: BaseColor.primary[400]!.withValues(alpha: 0.3),
        highlightColor: BaseColor.primary[600]!.withValues(alpha: 0.2),
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w16),
          child: Row(
            children: [
              Container(
                width: BaseSize.w48,
                height: BaseSize.w48,
                decoration: BoxDecoration(
                  color: BaseColor.textOnPrimary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: FaIcon(
                  AppIcons.add,
                  size: BaseSize.w32,
                  color: BaseColor.textOnPrimary,
                ),
              ),
              Gap.w16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: BaseTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: BaseColor.textOnPrimary,
                      ),
                    ),
                    Gap.h4,
                    Text(
                      description,
                      style: BaseTypography.bodyMedium.copyWith(
                        color: BaseColor.textOnPrimary.withValues(alpha: 0.9),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Gap.w8,
              FaIcon(
                AppIcons.arrowForwardIcon,
                size: BaseSize.w24,
                color: BaseColor.textOnPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
