import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat_shared/extensions.dart';

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
    isScrollControlled: true,
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
    final l10n = context.l10n;
    final baseColor = isApprove ? BaseColor.green : BaseColor.red;
    final icon = isApprove ? AppIcons.success : AppIcons.reject;
    final title = isApprove
        ? l10n.approval_confirmApproveTitle
        : l10n.approval_confirmRejectTitle;
    final description = isApprove
        ? l10n.approval_confirmApproveDescription
        : l10n.approval_confirmRejectDescription;
    final confirmText = isApprove ? l10n.btn_approve : l10n.btn_reject;

    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldStackActions =
            constraints.maxWidth < 420 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.1;
        final cancelButton = ButtonWidget.outlined(
          text: l10n.btn_cancel,
          onTap: () => Navigator.of(context).pop(false),
        );
        final confirmButton = ButtonWidget.primary(
          text: confirmText,
          onTap: () => Navigator.of(context).pop(true),
        );

        return Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth >= 640
                  ? 560
                  : constraints.maxWidth,
            ),
            child: Material(
              color: BaseColor.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(BaseSize.radiusLg),
                topRight: Radius.circular(BaseSize.radiusLg),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: BaseSize.w24,
                    right: BaseSize.w24,
                    top: BaseSize.w24,
                    bottom:
                        BaseSize.w24 + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: BaseSize.w40,
                          height: BaseSize.h4,
                          decoration: BoxDecoration(
                            color: BaseColor.neutral30,
                            borderRadius: BorderRadius.circular(
                              BaseSize.radiusSm,
                            ),
                          ),
                        ),
                      ),
                      Gap.h16,
                      Center(
                        child: Container(
                          width: BaseSize.w56,
                          height: BaseSize.w56,
                          decoration: BoxDecoration(
                            color: baseColor[50],
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: FaIcon(
                            icon,
                            size: BaseSize.w32,
                            color: baseColor[700],
                          ),
                        ),
                      ),
                      Gap.h16,
                      Text(
                        title,
                        style: BaseTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: BaseColor.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Gap.h8,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: BaseSize.w12,
                          vertical: BaseSize.h8,
                        ),
                        decoration: BoxDecoration(
                          color: BaseColor.surfaceMedium,
                          borderRadius: BorderRadius.circular(
                            BaseSize.radiusMd,
                          ),
                          border: Border.all(
                            color: BaseColor.neutral[200]!,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          activityTitle,
                          style: BaseTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: BaseColor.primaryText,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: shouldStackActions ? 3 : 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Gap.h12,
                      Text(
                        description,
                        style: BaseTypography.bodyMedium.toSecondary,
                        textAlign: TextAlign.center,
                      ),
                      Gap.h24,
                      if (shouldStackActions) ...[
                        cancelButton,
                        Gap.h12,
                        confirmButton,
                      ] else
                        Row(
                          children: [
                            Expanded(child: cancelButton),
                            Gap.w12,
                            Expanded(child: confirmButton),
                          ],
                        ),
                      Gap.h8,
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
