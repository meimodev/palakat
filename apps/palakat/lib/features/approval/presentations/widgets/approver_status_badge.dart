import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:palakat/core/constants/constants.dart';

/// A widget that displays an approver's status with a colored icon and optional label.
///
/// The badge shows:
/// - Green checkmark for approved status
/// - Red X for rejected status
/// - Amber clock for unconfirmed/pending status
///
/// **Feature: approval-card-detail-redesign, Property 2: Status icon color matches approval status**
class ApproverStatusBadge extends StatelessWidget {
  const ApproverStatusBadge({
    super.key,
    required this.status,
    this.iconSize,
    this.showLabel = true,
  });

  /// The approval status to display
  final ApprovalStatus status;

  /// The size of the status icon. Defaults to 20dp if not specified.
  final double? iconSize;

  /// Whether to show the status label text. Defaults to true.
  final bool showLabel;

  /// Returns the appropriate icon for the given approval status.
  ///
  /// - Approved: checkmark circle icon
  /// - Rejected: cancel/X icon
  /// - Unconfirmed: schedule/clock icon
  static IconData getStatusIcon(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.approved:
        return AppIcons.successSolid;
      case ApprovalStatus.rejected:
        return AppIcons.cancel;
      case ApprovalStatus.unconfirmed:
        return AppIcons.pending;
    }
  }

  /// Returns the appropriate color for the given approval status.
  ///
  /// - Approved: green
  /// - Rejected: red
  /// - Unconfirmed: amber/yellow
  static Color getStatusColor(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.approved:
        return BaseColor.green.shade600;
      case ApprovalStatus.rejected:
        return BaseColor.red.shade500;
      case ApprovalStatus.unconfirmed:
        return BaseColor.yellow.shade700;
    }
  }

  /// Returns the display label for the given approval status.
  static String getStatusLabel(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.approved:
        return 'Approved';
      case ApprovalStatus.rejected:
        return 'Rejected';
      case ApprovalStatus.unconfirmed:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = getStatusColor(status);
    final icon = getStatusIcon(status);
    final label = getStatusLabel(status);
    final size = iconSize ?? BaseSize.w20;

    if (!showLabel) {
      return FaIcon(icon, size: size, color: color);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(icon, size: size, color: color),
        Gap.w4,
        Text(
          label,
          style: BaseTypography.bodySmall.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
