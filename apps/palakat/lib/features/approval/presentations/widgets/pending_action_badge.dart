import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:palakat/core/constants/constants.dart';

/// A badge widget that displays the count of pending approvals requiring user action.
/// Displayed prominently at the top of the approval screen.
class PendingActionBadge extends StatelessWidget {
  const PendingActionBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count == 0) {
      return Container(
        padding: EdgeInsets.all(BaseSize.w16),
        decoration: BoxDecoration(
          color: BaseColor.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: BaseColor.green.shade200, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(BaseSize.w8),
              decoration: BoxDecoration(
                color: BaseColor.green.shade100,
                shape: BoxShape.circle,
              ),
              child: FaIcon(
                AppIcons.success,
                size: BaseSize.w24,
                color: BaseColor.green.shade600,
              ),
            ),
            Gap.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All caught up!',
                    style: BaseTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: BaseColor.green.shade700,
                    ),
                  ),
                  Gap.h4,
                  Text(
                    'No pending approvals requiring your action',
                    style: BaseTypography.bodySmall.copyWith(
                      color: BaseColor.green.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(BaseSize.w16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [BaseColor.teal.shade500, BaseColor.teal.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: BaseColor.teal.shade500.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: BaseSize.w48,
            height: BaseSize.w48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              count.toString(),
              style: BaseTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Gap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pending Your Action',
                  style: BaseTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Gap.h4,
                Text(
                  count == 1
                      ? '1 approval waiting for your review'
                      : '$count approvals waiting for your review',
                  style: BaseTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          FaIcon(
            AppIcons.arrowForward,
            size: BaseSize.w16,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}
