import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/extensions.dart';

/// A badge widget that displays the count of pending approvals requiring user action.
/// Displayed prominently at the top of the approval screen.
class PendingActionBadge extends StatelessWidget {
  const PendingActionBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (count == 0) {
      return Material(
        color: AppColors.success.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(color: AppColors.success.shade200, width: 1),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: AppColors.success.shade100,
                  border: Border.all(color: AppColors.success.shade200),
                  shape: BoxShape.circle,
                  boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 8),
                ),
                alignment: Alignment.center,
                child: FaIcon(
                  AppIcons.success,
                  size: 24.0,
                  color: AppColors.success.shade600,
                ),
              ),
              Gap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.approval_allCaughtUpTitle,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.success.shade700,
                      ),
                    ),
                    Gap.h4,
                    Text(
                      l10n.approval_allCaughtUpSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColors.success.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              border: Border.all(color: AppColors.surfaceContainerLowest),
              shape: BoxShape.circle,
              boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 8),
            ),
            alignment: Alignment.center,
            child: Text(
              count.toString(),
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.surfaceContainerLowest,
              ),
            ),
          ),
          Gap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.approval_sectionPendingYourAction,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.surfaceContainerLowest,
                  ),
                ),
                Gap.h4,
                Text(
                  l10n.approval_pendingReviewCount(count),
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.surfaceContainerLowest,
                  ),
                ),
              ],
            ),
          ),
          FaIcon(
            AppIcons.arrowForward,
            size: 16.0,
            color: AppColors.surfaceContainerLowest,
          ),
        ],
      ),
    );
  }
}
