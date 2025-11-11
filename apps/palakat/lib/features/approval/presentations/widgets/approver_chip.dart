import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_admin/core/extension/date_time_extension.dart';

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
        horizontal: BaseSize.w12,
        vertical: BaseSize.h8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: BaseSize.w8,
            height: BaseSize.w8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: BaseSize.customWidth(10)),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: name,
                    style: BaseTypography.bodyMedium.copyWith(
                      color: BaseColor.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (updatedAt != null && status != ApprovalStatus.unconfirmed) ...[
                    TextSpan(
                      text: '  •  ',
                      style: BaseTypography.bodySmall.copyWith(
                        color: BaseColor.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: "${updatedAt!.slashDate} ${updatedAt!.HHmm}",
                      style: BaseTypography.bodySmall.copyWith(
                        color: BaseColor.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
