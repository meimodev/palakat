import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_admin/core/extension/date_time_extension.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/core/assets/assets.gen.dart';
import 'package:palakat_admin/models.dart' hide Column;
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
          ap.membership!.id == currentMembershipId,
    );

    Widget statusPill(ApprovalStatus s) => ApprovalStatusPill(status: s);

    return Material(
      color: BaseColor.cardBackground1,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      surfaceTintColor: BaseColor.teal[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title row with chevron
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      approval.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: BaseTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: BaseColor.black,
                      ),
                    ),
                  ),
                  Gap.w8,
                  Icon(
                    Icons.chevron_right,
                    size: BaseSize.w24,
                    color: BaseColor.secondaryText,
                  ),
                ],
              ),
              Gap.h12,
              // Supervisor and date info
              Row(
                children: [
                  Container(
                    width: BaseSize.w32,
                    height: BaseSize.w32,
                    decoration: BoxDecoration(
                      color: BaseColor.blue[100],
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.person_outline,
                      size: BaseSize.w16,
                      color: BaseColor.blue[700],
                    ),
                  ),
                  Gap.w8,
                  Expanded(
                    child: Text(
                      approval.supervisor.account?.name ?? "",
                      style: BaseTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Gap.w12,
                  Icon(
                    Icons.schedule_outlined,
                    size: BaseSize.w16,
                    color: BaseColor.secondaryText,
                  ),
                  Gap.w4,
                  Text(
                    "${approval.createdAt.slashDate} ${approval.createdAt.HHmm}",
                    style: BaseTypography.bodySmall.copyWith(
                      color: BaseColor.secondaryText,
                    ),
                  ),
                ],
              ),
              // Approvers list
              if (approval.approvers.isNotEmpty) ...[
                Gap.h12,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: approval.approvers.map((ap) {
                    final name = ap.membership?.account?.name ?? '-';
                    return Padding(
                      padding: EdgeInsets.only(bottom: BaseSize.h6),
                      child: ApproverChip(
                        name: name,
                        status: ap.status,
                        updatedAt: ap.updatedAt,
                      ),
                    );
                  }).toList(),
                ),
              ],
              Gap.h12,
              // Conditional actions / status
              if (overall == ApprovalStatus.unconfirmed) ...[
                // Show unconfirmed status pill above actions when the pending approver is not me
                if (!isMinePending) statusPill(ApprovalStatus.unconfirmed),
                if (isMinePending) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ButtonWidget.outlinedIcon(
                          icon: Assets.icons.line.times.svg(
                            width: BaseSize.w20,
                            height: BaseSize.w20,
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
                            width: BaseSize.w20,
                            height: BaseSize.w20,
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
                ],
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
