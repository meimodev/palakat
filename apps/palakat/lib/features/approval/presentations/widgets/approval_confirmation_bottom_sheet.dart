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
    backgroundColor: Colors.transparent,
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
    final baseColor = isApprove ? AppColors.success : AppColors.error;
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
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 24.0,
                    right: 24.0,
                    top: 24.0,
                    bottom:
                        24.0 + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40.0,
                          height: 4.0,
                          decoration: BoxDecoration(
                            color: AppColors.tertiary,
                            borderRadius: BorderRadius.circular(
                              4.0,
                            ),
                          ),
                        ),
                      ),
                      Gap.h16,
                      Center(
                        child: Container(
                          width: 56.0,
                          height: 56.0,
                          decoration: BoxDecoration(
                            color: baseColor[50],
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: FaIcon(
                            icon,
                            size: 32.0,
                            color: baseColor[700],
                          ),
                        ),
                      ),
                      Gap.h16,
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Gap.h8,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(
                            8.0,
                          ),
                          border: Border.all(
                            color: AppColors.outlineVariant,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          activityTitle,
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: shouldStackActions ? 3 : 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Gap.h12,
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium!.toSecondary,
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
