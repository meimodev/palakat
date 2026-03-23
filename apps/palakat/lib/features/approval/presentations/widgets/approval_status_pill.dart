import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/extensions.dart';

class ApprovalStatusPill extends StatelessWidget {
  const ApprovalStatusPill({super.key, required this.status});

  final ApprovalStatus status;

  Color _statusColor(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.approved:
        return AppColors.success.shade600;
      case ApprovalStatus.rejected:
        return AppColors.error.shade500;
      case ApprovalStatus.unconfirmed:
        return AppColors.warning.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = _statusColor(status);
    IconData icon;
    String label;
    switch (status) {
      case ApprovalStatus.approved:
        icon = AppIcons.successSolid;
        label = l10n.status_approved;
        break;
      case ApprovalStatus.rejected:
        icon = AppIcons.cancel;
        label = l10n.status_rejected;
        break;
      case ApprovalStatus.unconfirmed:
        icon = AppIcons.pending;
        label = l10n.status_pending;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 20.0, color: color),
          Gap.w8,
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
