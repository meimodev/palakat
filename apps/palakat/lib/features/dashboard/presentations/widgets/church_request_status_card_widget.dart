import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;
import 'package:palakat_shared/core/extension/extension.dart';

class ChurchRequestStatusCardWidget extends StatelessWidget {
  final ChurchRequest churchRequest;

  const ChurchRequestStatusCardWidget({super.key, required this.churchRequest});

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(context, churchRequest.status);
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
        border: Border.all(color: statusInfo.borderColor, width: 1),
        boxShadow: SanctuaryDepth.ambient(opacity: 0.03, blur: 20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  color: statusInfo.iconBackgroundColor,
                  border: Border.all(color: AppColors.ghostBorder(0.06)),
                  borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
                  boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  statusInfo.icon,
                  size: 18.0,
                  color: statusInfo.iconColor,
                ),
              ),
              Gap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.churchRequest_title,
                      style: theme.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Gap.h4,
                    Text(
                      context.l10n.churchRequest_membershipStatusSubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Gap.w8,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: statusInfo.badgeBackgroundColor,
                  borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
                  border: Border.all(color: AppColors.ghostBorder(0.06)),
                  boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 8),
                ),
                child: Text(
                  statusInfo.statusLabel,
                  style: theme.textTheme.labelMedium!.copyWith(
                    color: statusInfo.badgeTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          Gap.h16,
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
              border: Border.all(color: AppColors.ghostBorder(0.06)),
              boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 12),
            ),
            child: Text(
              statusInfo.message,
              style: theme.textTheme.bodyMedium!.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _StatusInfo _getStatusInfo(BuildContext context, RequestStatus status) {
    switch (status) {
      case RequestStatus.todo:
        return _StatusInfo(
          statusLabel: context.l10n.churchRequest_status_onReview,
          message: context.l10n.churchRequest_statusMessage_onReview,
          icon: AppIcons.schedule,
          iconColor: AppColors.warning,
          iconBackgroundColor: AppColors.warning.withValues(alpha: 0.12),
          backgroundColor: AppColors.surfaceContainerLowest,
          borderColor: AppColors.ghostBorder(0.08),
          badgeBackgroundColor: AppColors.warning.withValues(alpha: 0.12),
          badgeTextColor: AppColors.warning,
        );
      case RequestStatus.doing:
        return _StatusInfo(
          statusLabel: context.l10n.churchRequest_status_onProgress,
          message: context.l10n.churchRequest_statusMessage_onProgress,
          icon: AppIcons.sync,
          iconColor: AppColors.primary,
          iconBackgroundColor: AppColors.primary.withValues(alpha: 0.12),
          backgroundColor: AppColors.surfaceContainerLowest,
          borderColor: AppColors.ghostBorder(0.08),
          badgeBackgroundColor: AppColors.primary.withValues(alpha: 0.12),
          badgeTextColor: AppColors.primary,
        );
      case RequestStatus.done:
        return _StatusInfo(
          statusLabel: context.l10n.status_completed,
          message: context.l10n.churchRequest_statusMessage_completed,
          icon: AppIcons.success,
          iconColor: AppColors.success,
          iconBackgroundColor: AppColors.success.withValues(alpha: 0.12),
          backgroundColor: AppColors.surfaceContainerLowest,
          borderColor: AppColors.ghostBorder(0.08),
          badgeBackgroundColor: AppColors.success.withValues(alpha: 0.12),
          badgeTextColor: AppColors.success,
        );
      case RequestStatus.rejected:
        final note = churchRequest.decisionNote?.trim();
        final msg = (note == null || note.isEmpty)
            ? context.l10n.status_rejected
            : '${context.l10n.status_rejected} (${context.l10n.lbl_note}: $note)';
        return _StatusInfo(
          statusLabel: context.l10n.status_rejected,
          message: msg,
          icon: AppIcons.error,
          iconColor: AppColors.error,
          iconBackgroundColor: AppColors.error.withValues(alpha: 0.12),
          backgroundColor: AppColors.surfaceContainerLowest,
          borderColor: AppColors.ghostBorder(0.08),
          badgeBackgroundColor: AppColors.error.withValues(alpha: 0.12),
          badgeTextColor: AppColors.error,
        );
    }
  }
}

class _StatusInfo {
  final String statusLabel;
  final String message;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color backgroundColor;
  final Color borderColor;
  final Color badgeBackgroundColor;
  final Color badgeTextColor;

  _StatusInfo({
    required this.statusLabel,
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.badgeBackgroundColor,
    required this.badgeTextColor,
  });
}
