import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;

class ChurchRequestStatusCardWidget extends StatelessWidget {
  final ChurchRequest churchRequest;

  const ChurchRequestStatusCardWidget({super.key, required this.churchRequest});

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(churchRequest.status);

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
                        "Church Registration Request",
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

  _StatusInfo _getStatusInfo(RequestStatus status) {
    switch (status) {
      case RequestStatus.todo:
        return _StatusInfo(
          statusLabel: 'On Review',
          message: 'Your request is on us and soon will be acted upon.',
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
          statusLabel: 'On Progress',
          message: 'YAY! Your request is being processed.',
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
          statusLabel: 'Completed',
          message:
              'Your church has been registered! You can now select it in when editing membership data.',
          icon: AppIcons.success,
          iconColor: BaseColor.green[700]!,
          iconBackgroundColor: BaseColor.green[50]!,
          backgroundColor: BaseColor.green[50]!,
          borderColor: BaseColor.green[200]!,
          badgeBackgroundColor: BaseColor.green[100]!,
          badgeTextColor: BaseColor.green[700]!,
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
