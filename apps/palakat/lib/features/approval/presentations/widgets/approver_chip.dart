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
          final statusLabel = Text(
            ApproverStatusBadge.getStatusLabelLocalized(context, status),
            style: BaseTypography.labelMedium.copyWith(
              color: ApproverStatusBadge.getStatusColor(status),
              fontWeight: FontWeight.w600,
            ),
          );

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ApproverStatusBadge(
                status: status,
                iconSize: BaseSize.w22,
                showLabel: false,
              ),
              Gap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      spacing: BaseSize.w6,
                      runSpacing: BaseSize.h4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          name,
                          style: BaseTypography.bodyMedium.copyWith(
                            color: isCurrentUser
                                ? BaseColor.teal.shade800
                                : BaseColor.textPrimary,
                            fontWeight: isCurrentUser
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                        ),
                        if (isCurrentUser)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: BaseSize.w8,
                              vertical: BaseSize.h4,
                            ),
                            decoration: BoxDecoration(
                              color: BaseColor.teal.shade600,
                              borderRadius: BorderRadius.circular(
                                BaseSize.radiusSm,
                              ),
                            ),
                            child: Text(
                              context.l10n.lbl_you,
                              style: BaseTypography.labelMedium.copyWith(
                                color: BaseColor.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (updatedAt != null &&
                        status != ApprovalStatus.unconfirmed)
                      Padding(
                        padding: EdgeInsets.only(top: BaseSize.h6),
                        child: Text(
                          "${updatedAt!.slashDate} ${updatedAt!.HHmm}",
                          style: BaseTypography.bodyMedium.copyWith(
                            color: isCurrentUser
                                ? BaseColor.teal.shade700
                                : BaseColor.secondaryText,
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
      return Material(
        color: BaseColor.teal.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BaseSize.radiusMd),
          side: BorderSide(color: BaseColor.teal.shade200, width: 1),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: BaseSize.h8,
            horizontal: BaseSize.w8,
          ),
          child: buildContent(),
        ),
      );
    }

    // No decoration for non-current users
    return Padding(
      padding: EdgeInsets.symmetric(vertical: BaseSize.h8),
      child: buildContent(),
    );
  }
}
