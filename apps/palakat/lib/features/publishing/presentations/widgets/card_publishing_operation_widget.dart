import 'package:flutter/material.dart';
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
      color: BaseColor.transparent,
      child: Container(
        decoration: BoxDecoration(
          // Solid teal primary color instead of gradient (Requirements 1.1, 3.1)
          color: BaseColor.primary[500],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: BaseColor.primary[300]!.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Material(
          color: BaseColor.transparent,
          child: InkWell(
            onTap: onPressedCard,
            splashColor: BaseColor.primary[400]!.withValues(alpha: 0.3),
            highlightColor: BaseColor.primary[600]!.withValues(alpha: 0.2),
            child: Padding(
              padding: EdgeInsets.all(BaseSize.w16),
              child: Row(
                children: [
                  // Plus icon with neutral background
                  Container(
                    width: BaseSize.w48,
                    height: BaseSize.w48,
                    decoration: BoxDecoration(
                      color: BaseColor.textOnPrimary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.add,
                      size: BaseSize.w32,
                      color: BaseColor.textOnPrimary,
                    ),
                  ),
                  Gap.w16,
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: BaseTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: BaseColor.textOnPrimary,
                          ),
                        ),
                        Gap.h4,
                        Text(
                          description,
                          style: BaseTypography.bodyMedium.copyWith(
                            color: BaseColor.textOnPrimary.withValues(
                              alpha: 0.9,
                            ),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Gap.w8,
                  // Arrow icon
                  Icon(
                    Icons.arrow_forward,
                    size: BaseSize.w24,
                    color: BaseColor.textOnPrimary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
