import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/extensions/date_time_extension.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/core/assets/assets.gen.dart';
import 'package:palakat/core/models/models.dart' hide Column;
import 'package:palakat/features/approval/presentations/widgets/approval_status_pill.dart';
import 'package:palakat/features/approval/presentations/widgets/approver_chip.dart';

class ApprovalCardWidget extends StatelessWidget {
  const ApprovalCardWidget({
    super.key,
    required this.approval,
    this.currentMembershipId,
    required this.onTap,
    required this.onApprove,
    required this.onReject,
  });

  final Activity approval;
  final int? currentMembershipId;
  final VoidCallback onTap;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    ApprovalStatus overallStatus(List<Approver> items) {
      // Priority: any rejected -> rejected; else any unconfirmed -> unconfirmed; else approved
      final hasRejected = items.any((e) => e.status == ApprovalStatus.rejected);
      if (hasRejected) return ApprovalStatus.rejected;
      final hasUnconfirmed = items.any(
        (e) => e.status == ApprovalStatus.unconfirmed,
      );
      if (hasUnconfirmed) return ApprovalStatus.unconfirmed;
      return ApprovalStatus.approved;
    }

    final overall = overallStatus(approval.approvers);
    final bool isMinePending = approval.approvers.any(
      (ap) =>
          ap.status == ApprovalStatus.unconfirmed &&
          ap.membership.id == currentMembershipId,
    );

    Widget statusPill(ApprovalStatus s) => ApprovalStatusPill(status: s);

    return Material(
      clipBehavior: Clip.hardEdge,
      color: BaseColor.cardBackground1,
      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      approval.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: BaseTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: BaseColor.primaryText,
                      ),
                    ),
                  ),
                  Gap.w8,
                  Icon(
                    Icons.chevron_right_rounded,
                    size: BaseSize.w20,
                    color: BaseColor.teal.shade600.withValues(alpha: 0.9),
                  ),
                ],
              ),
              Gap.h6,
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: BaseSize.w16,
                    color: BaseColor.blue.shade500.withValues(alpha: 0.9),
                  ),
                  Gap.w4,
                  Expanded(
                    child: Text(
                      approval.supervisor.account?.name ?? "",
                      style: BaseTypography.bodySmall.copyWith(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Gap.w8,
                  DividerWidget(
                    axis: Axis.vertical,
                    thickness: 1,
                    height: 16,
                    color: BaseColor.green.shade600.withValues(alpha: 0.24),
                  ),
                  Gap.w8,
                  Icon(
                    Icons.schedule,
                    size: BaseSize.w16,
                    color: BaseColor.yellow.shade600.withValues(alpha: 0.95),
                  ),
                  Gap.w4,
                  Text(
                    approval.createdAt.slashDate ?? "",
                    style: BaseTypography.bodySmall.copyWith(),
                  ),
                ],
              ),
              Gap.h6,
              if (approval.approvers.isNotEmpty) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: approval.approvers.map((ap) {
                    final name = ap.membership.account?.name ?? '-';
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      child: ApproverChip(
                        name: name,
                        status: ap.status,
                        updatedAt: ap.updatedAt,
                      ),
                    );
                  }).toList(),
                ),
              ],
              Gap.h6,
              // Conditional actions / status
              if (overall == ApprovalStatus.unconfirmed) ...[
                // Show unconfirmed status pill above actions when the pending approver is not me
                if (!isMinePending) statusPill(ApprovalStatus.unconfirmed),
                Gap.h8,
                if (isMinePending)
                  Row(
                    children: [
                      Expanded(
                        child: ButtonWidget.outlinedIcon(
                          icon: Assets.icons.line.times.svg(
                            width: BaseSize.w18,
                            height: BaseSize.w18,
                            colorFilter: ColorFilter.mode(
                              BaseColor.red.shade500,
                              BlendMode.srcIn,
                            ),
                          ),
                          outlineColor: BaseColor.red.shade500,
                          focusColor: BaseColor.red.shade400,
                          overlayColor: BaseColor.red.shade400.withValues(
                            alpha: 0.12,
                          ),
                          buttonSize: ButtonSize.small,
                          onTap: onReject,
                        ),
                      ),
                      Gap.w12,
                      Expanded(
                        child: ButtonWidget.outlinedIcon(
                          icon: Assets.icons.fill.checkCircle.svg(
                            width: BaseSize.w18,
                            height: BaseSize.w18,
                            colorFilter: ColorFilter.mode(
                              BaseColor.green.shade600,
                              BlendMode.srcIn,
                            ),
                          ),
                          outlineColor: BaseColor.green.shade600,
                          focusColor: BaseColor.green.shade400,
                          overlayColor: BaseColor.green.shade400.withValues(
                            alpha: 0.12,
                          ),
                          buttonSize: ButtonSize.small,
                          onTap: onApprove,
                        ),
                      ),
                    ],
                  ),
              ] else ...[
                statusPill(overall),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
