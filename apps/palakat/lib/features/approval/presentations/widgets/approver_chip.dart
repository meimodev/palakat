import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/features/approval/presentations/widgets/approver_status_badge.dart';
import 'package:palakat_shared/extensions.dart';

/// A widget that displays an approver's name and status in a clean list format.
///
/// This widget displays approver information without a colored background container,
/// using typography styling for name emphasis and integrating [ApproverStatusBadge]
/// for prominent status display in the leading position.
///
/// When [isCurrentUser] is true, the approver name is highlighted with a distinct
/// background color to help users quickly identify their own approval status.
///
/// **Feature: approval-card-detail-redesign, Property 1: Approver name containers have no colored background**
class ApproverChip extends StatelessWidget {
  const ApproverChip({
    super.key,
    required this.name,
    required this.status,
    this.updatedAt,
    this.isCurrentUser = false,
  });

  final String name;
  final ApprovalStatus status;
  final DateTime? updatedAt;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    // Base row content for both current user and other approvers
    Widget buildContent() {
      return LayoutBuilder(
        builder: (context, constraints) {
          final shouldStackStatus =
              constraints.maxWidth < 340 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.1;
          final foregroundColor = isCurrentUser
              ? AppColors.onPrimary
              : AppColors.onSurface;
          final secondaryForegroundColor = isCurrentUser
              ? AppColors.onPrimary.withValues(alpha: 0.78)
              : AppColors.onSurfaceVariant;
          final statusForegroundColor = isCurrentUser
              ? AppColors.onPrimary
              : ApproverStatusBadge.getStatusColor(status);
          final statusLabel = Text(
            ApproverStatusBadge.getStatusLabelLocalized(context, status),
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
              color: statusForegroundColor,
              fontWeight: FontWeight.w600,
            ),
          );

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ApproverStatusBadge(
                status: status,
                iconSize: 22.0,
                showLabel: false,
                colorOverride: isCurrentUser ? AppColors.onPrimary : null,
              ),
              Gap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      spacing: 6.0,
                      runSpacing: 4.0,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          name,
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                color: foregroundColor,
                                fontWeight: isCurrentUser
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                        ),
                        if (isCurrentUser)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.onPrimary.withValues(
                                alpha: 0.12,
                              ),
                              border: Border.all(
                                color: AppColors.onPrimary.withValues(
                                  alpha: 0.18,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(4.0),
                              boxShadow: SanctuaryDepth.ambient(
                                opacity: 0.02,
                                blur: 6,
                              ),
                            ),
                            child: Text(
                              context.l10n.lbl_you,
                              style: Theme.of(context).textTheme.labelMedium!
                                  .copyWith(
                                    color: AppColors.onPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                      ],
                    ),
                    if (updatedAt != null &&
                        status != ApprovalStatus.unconfirmed)
                      Padding(
                        padding: EdgeInsets.only(top: 6.0),
                        child: Text(
                          "${updatedAt!.slashDate} ${updatedAt!.HHmm}",
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                color: secondaryForegroundColor,
                                fontWeight: FontWeight.w400,
                              ),
                        ),
                      ),
                    if (shouldStackStatus) ...[Gap.h8, statusLabel],
                  ],
                ),
              ),
              if (!shouldStackStatus) ...[
                Gap.w12,
                Flexible(child: statusLabel),
              ],
            ],
          );
        },
      );
    }

    // Highlight container when this is the current user
    if (isCurrentUser) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 12),
        ),
        child: Material(
          color: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(color: AppColors.surfaceContainerLowest, width: 1),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: buildContent(),
          ),
        ),
      );
    }

    // No decoration for non-current users
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: buildContent(),
    );
  }
}
