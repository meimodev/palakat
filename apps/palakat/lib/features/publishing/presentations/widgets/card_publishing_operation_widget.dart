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
      color: AppColors.primary,
      elevation: 2,
      shadowColor: AppColors.primary.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onPressedCard,
        splashColor: AppColors.primary.withValues(alpha: 0.3),
        highlightColor: AppColors.primary.withValues(alpha: 0.2),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48.0,
                height: 48.0,
                decoration: BoxDecoration(
                  color: AppColors.onPrimary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: FaIcon(
                  AppIcons.add,
                  size: 32.0,
                  color: AppColors.onPrimary,
                ),
              ),
              Gap.w16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onPrimary,
                      ),
                    ),
                    Gap.h4,
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColors.onPrimary.withValues(alpha: 0.9),
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
                size: 24.0,
                color: AppColors.onPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
