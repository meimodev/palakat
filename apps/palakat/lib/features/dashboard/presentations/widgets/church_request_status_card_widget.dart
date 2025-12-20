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

    return Container(
      padding: EdgeInsets.all(BaseSize.w12),
      decoration: BoxDecoration(
        color: statusInfo.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusInfo.borderColor, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: BaseSize.w32,
            height: BaseSize.w32,
            decoration: BoxDecoration(
              color: statusInfo.iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              statusInfo.icon,
              size: BaseSize.w16,
              color: statusInfo.iconColor,
            ),
          ),
          Gap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.churchRequest_title,
                        style: BaseTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: BaseColor.black,
                        ),
                      ),
                    ),
                    Gap.w8,
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: BaseSize.w6,
                        vertical: BaseSize.h4 / 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusInfo.badgeBackgroundColor,
                        borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                      ),
                      child: Text(
                        statusInfo.statusLabel,
                        style: BaseTypography.labelSmall.copyWith(
                          color: statusInfo.badgeTextColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                Gap.h4,
                Text(
                  statusInfo.message,
                  style: BaseTypography.bodySmall.copyWith(
                    color: BaseColor.neutral[600],
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
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
          iconColor: BaseColor.yellow[700]!,
          iconBackgroundColor: BaseColor.yellow[50]!,
          backgroundColor: BaseColor.yellow[50]!,
          borderColor: BaseColor.yellow[200]!,
          badgeBackgroundColor: BaseColor.yellow[100]!,
          badgeTextColor: BaseColor.yellow[700]!,
        );
      case RequestStatus.doing:
        return _StatusInfo(
          statusLabel: context.l10n.churchRequest_status_onProgress,
          message: context.l10n.churchRequest_statusMessage_onProgress,
          icon: AppIcons.sync,
          iconColor: BaseColor.blue[700]!,
          iconBackgroundColor: BaseColor.blue[50]!,
          backgroundColor: BaseColor.blue[50]!,
          borderColor: BaseColor.blue[200]!,
          badgeBackgroundColor: BaseColor.blue[100]!,
          badgeTextColor: BaseColor.blue[700]!,
        );
      case RequestStatus.done:
        return _StatusInfo(
          statusLabel: context.l10n.status_completed,
          message: context.l10n.churchRequest_statusMessage_completed,
          icon: AppIcons.success,
          iconColor: BaseColor.green[700]!,
          iconBackgroundColor: BaseColor.green[50]!,
          backgroundColor: BaseColor.green[50]!,
          borderColor: BaseColor.green[200]!,
          badgeBackgroundColor: BaseColor.green[100]!,
          badgeTextColor: BaseColor.green[700]!,
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
          iconColor: BaseColor.red[700]!,
          iconBackgroundColor: BaseColor.red[50]!,
          backgroundColor: BaseColor.red[50]!,
          borderColor: BaseColor.red[200]!,
          badgeBackgroundColor: BaseColor.red[100]!,
          badgeTextColor: BaseColor.red[700]!,
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
