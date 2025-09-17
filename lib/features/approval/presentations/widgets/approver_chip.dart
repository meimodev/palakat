import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/extensions/date_time_extension.dart';

class ApproverChip extends StatelessWidget {
  const ApproverChip({
    super.key,
    required this.name,
    required this.status,
    this.updatedAt,
  });

  final String name;
  final ApprovalStatus status;
  final DateTime? updatedAt;

  Color _statusColor(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.approved:
        return BaseColor.green.shade600;
      case ApprovalStatus.rejected:
        return BaseColor.red.shade500;
      case ApprovalStatus.unconfirmed:
        return BaseColor.yellow.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w8,
        vertical: BaseSize.h4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(BaseSize.radiusSm),
        border: Border.all(
          color: color.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: BaseSize.w6,
            height: BaseSize.w6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          Gap.w8,
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: name,
                  style: BaseTypography.labelMedium.copyWith(
                    color: BaseColor.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (updatedAt != null && status != ApprovalStatus.unconfirmed) ...[
                  TextSpan(
                    text: '  •  ',
                    style: BaseTypography.labelMedium.copyWith(
                      color: BaseColor.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: "${updatedAt!.slashDate} - ${updatedAt!.HHmm}",
                    style: BaseTypography.labelMedium.copyWith(
                      color: BaseColor.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
