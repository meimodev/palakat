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
      return Row(
        children: [
          // Status badge in leading position for immediate visibility
          ApproverStatusBadge(
            status: status,
            iconSize: BaseSize.w20,
            showLabel: false,
          ),
          Gap.w12,
          // Name with typography styling (font weight) for emphasis
          // Current user gets additional visual distinction
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: BaseTypography.bodyMedium.copyWith(
                          color: isCurrentUser
                              ? BaseColor.teal.shade800
                              : BaseColor.black,
                          fontWeight: isCurrentUser
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isCurrentUser) ...[
                      Gap.w6,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: BaseSize.w6,
                          vertical: BaseSize.customHeight(2),
                        ),
                        decoration: BoxDecoration(
                          color: BaseColor.teal.shade600,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          context.l10n.lbl_you,
                          style: BaseTypography.labelSmall.copyWith(
                            color: BaseColor.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (updatedAt != null && status != ApprovalStatus.unconfirmed)
                  Padding(
                    padding: EdgeInsets.only(top: BaseSize.h4),
                    child: Text(
                      "${updatedAt!.slashDate} ${updatedAt!.HHmm}",
                      style: BaseTypography.bodySmall.copyWith(
                        color: isCurrentUser
                            ? BaseColor.teal.shade700
                            : BaseColor.secondaryText,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Status label on trailing for additional context
          Text(
            ApproverStatusBadge.getStatusLabelLocalized(context, status),
            style: BaseTypography.bodySmall.copyWith(
              color: ApproverStatusBadge.getStatusColor(status),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    // Highlight container when this is the current user
    if (isCurrentUser) {
      return Container(
        padding: EdgeInsets.symmetric(
          vertical: BaseSize.h8,
          horizontal: BaseSize.w8,
        ),
        decoration: BoxDecoration(
          color: BaseColor.teal.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: BaseColor.teal.shade300, width: 1.5),
        ),
        child: buildContent(),
      );
    }

    // No decoration for non-current users
    return Padding(
      padding: EdgeInsets.symmetric(vertical: BaseSize.h8),
      child: buildContent(),
    );
  }
}
