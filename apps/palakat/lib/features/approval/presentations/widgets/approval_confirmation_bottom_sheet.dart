import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:palakat/core/constants/constants.dart';

/// Shows a confirmation bottom sheet for approval actions (approve/reject)
///
/// Returns `true` if the user confirms the action, `false` or `null` if cancelled.
Future<bool?> showApprovalConfirmationBottomSheet({
  required BuildContext context,
  required bool isApprove,
  required String activityTitle,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: BaseColor.transparent,
    builder: (dialogContext) => _ApprovalConfirmationContent(
      isApprove: isApprove,
      activityTitle: activityTitle,
    ),
  );
}

class _ApprovalConfirmationContent extends StatelessWidget {
  const _ApprovalConfirmationContent({
    required this.isApprove,
    required this.activityTitle,
  });

  final bool isApprove;
  final String activityTitle;

  @override
  Widget build(BuildContext context) {
    final baseColor = isApprove ? BaseColor.green : BaseColor.red;
    final icon = isApprove ? AppIcons.success : AppIcons.reject;
    final title = isApprove ? 'Approve Activity?' : 'Reject Activity?';
    final description = isApprove
        ? 'Are you sure you want to approve this activity? This action cannot be undone.'
        : 'Are you sure you want to reject this activity? This action cannot be undone.';
    final confirmText = isApprove ? 'Approve' : 'Reject';

    return Container(
      decoration: BoxDecoration(
        color: BaseColor.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(BaseSize.radiusLg),
          topRight: Radius.circular(BaseSize.radiusLg),
        ),
      ),
      padding: EdgeInsets.all(BaseSize.w24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: BaseSize.w40,
              height: BaseSize.h4,
              decoration: BoxDecoration(
                color: BaseColor.neutral30,
                borderRadius: BorderRadius.circular(BaseSize.radiusSm),
              ),
            ),
          ),
          Gap.h16,
          // Icon
          Center(
            child: Container(
              width: BaseSize.w56,
              height: BaseSize.w56,
              decoration: BoxDecoration(
                color: baseColor[50],
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: FaIcon(icon, size: BaseSize.w32, color: baseColor[700]),
            ),
          ),
          Gap.h16,
          // Title
          Text(
            title,
            style: BaseTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: BaseColor.black,
            ),
            textAlign: TextAlign.center,
          ),
          Gap.h8,
          // Activity title
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: BaseSize.w12,
              vertical: BaseSize.h8,
            ),
            decoration: BoxDecoration(
              color: BaseColor.neutral20,
              borderRadius: BorderRadius.circular(BaseSize.radiusSm),
            ),
            child: Text(
              activityTitle,
              style: BaseTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: BaseColor.primaryText,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Gap.h12,
          // Description
          Text(
            description,
            style: BaseTypography.bodyMedium.toSecondary,
            textAlign: TextAlign.center,
          ),
          Gap.h24,
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: BaseSize.h12),
                    side: BorderSide(color: BaseColor.neutral40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: BaseTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: BaseColor.secondaryText,
                    ),
                  ),
                ),
              ),
              Gap.w12,
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: baseColor[600],
                    foregroundColor: BaseColor.white,
                    padding: EdgeInsets.symmetric(vertical: BaseSize.h12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                    ),
                  ),
                  child: Text(
                    confirmText,
                    style: BaseTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: BaseColor.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Gap.h8,
        ],
      ),
    );
  }
}
