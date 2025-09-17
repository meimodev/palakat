import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/assets/assets.gen.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/extensions/date_time_extension.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/core/models/models.dart' hide Column;
import 'package:palakat/features/approval/presentations/widgets/approval_status_pill.dart';
import 'package:palakat/features/approval/presentations/widgets/approver_chip.dart';
import 'package:palakat/features/approval/presentations/approval_controller.dart';

class ApprovalDetailScreen extends ConsumerWidget {
  const ApprovalDetailScreen({
    super.key,
    required this.approvalId,
    this.currentMembershipId,
  });
 
  final int approvalId;
  final int? currentMembershipId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch approval data by id from controller/state
    final state = ref.watch(approvalControllerProvider);
    final approval = state.approvals.firstWhere(
      (a) => a.id == approvalId,
      orElse: () => const Approval(
        id: -1,
        description: '',
        supervisor: Membership(id: -1, accountId: -1, churchId: -1, columnId: -1, baptize: false, sidi: false),
        approvers: <Approver>[],
      ),
    );

    if (approval.id == -1) {
      return ScaffoldWidget(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenTitleWidget.primary(
              leadIcon: Assets.icons.line.chevronBackOutline,
              title: "Approval Details",
              onPressedLeadIcon: () => context.pop(),
              leadIconColor: BaseColor.primary3,
            ),
            Gap.h16,
            const InfoBoxWidget(
              message: 'Approval not found. It may have been removed or is unavailable.',
            ),
          ],
        ),
      );
    }

    ApprovalStatus overallStatus(List<Approver> items) {
      final hasRejected = items.any((e) => e.status == ApprovalStatus.rejected);
      if (hasRejected) return ApprovalStatus.rejected;
      final hasUnconfirmed = items.any(
        (e) => e.status == ApprovalStatus.unconfirmed,
      );
      if (hasUnconfirmed) return ApprovalStatus.unconfirmed;
      return ApprovalStatus.approved;
    }

    Widget statusPill(ApprovalStatus s) => ApprovalStatusPill(status: s);

    final overall = overallStatus(approval.approvers);
    final bool isMinePending = approval.approvers.any(
      (ap) =>
          ap.status == ApprovalStatus.unconfirmed &&
          ap.membership.id == currentMembershipId,
    );

    return ScaffoldWidget(
      persistBottomWidget:
          overall == ApprovalStatus.unconfirmed && isMinePending
          ? Container(
              decoration: BoxDecoration(
                color: BaseColor.white,
                border: Border(
                  top: BorderSide(
                    color: BaseColor.teal.shade600.withValues(alpha: 0.12),
                    width: 1,
                  ),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                BaseSize.w12,
                BaseSize.h8,
                BaseSize.w12,
                BaseSize.h12,
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: ButtonWidget.outlined(
                        text: 'Reject',
                        icon: Assets.icons.line.times.svg(
                          width: BaseSize.w18,
                          height: BaseSize.w18,
                          colorFilter: ColorFilter.mode(
                            BaseColor.red.shade500,
                            BlendMode.srcIn,
                          ),
                        ),
                        textColor: BaseColor.red.shade500,
                        outlineColor: BaseColor.red.shade500,
                        focusColor: BaseColor.red.shade400,
                        overlayColor: BaseColor.red.shade400.withValues(
                          alpha: 0.12,
                        ),
                        buttonSize: ButtonSize.small,
                        onTap: () {
                          // TODO: implement reject action
                          context.pop();
                        },
                      ),
                    ),
                    Gap.w12,
                    Expanded(
                      child: ButtonWidget.outlined(
                        text: 'Approve',
                        icon: Assets.icons.fill.checkCircle.svg(
                          width: BaseSize.w18,
                          height: BaseSize.w18,
                          colorFilter: ColorFilter.mode(
                            BaseColor.green.shade600,
                            BlendMode.srcIn,
                          ),
                        ),
                        textColor: BaseColor.green.shade600,
                        outlineColor: BaseColor.green.shade600,
                        focusColor: BaseColor.green.shade400,
                        overlayColor: BaseColor.green.shade400.withValues(
                          alpha: 0.12,
                        ),
                        buttonSize: ButtonSize.small,
                        onTap: () {
                          context.pop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenTitleWidget.primary(
            leadIcon: Assets.icons.line.chevronBackOutline,
            title: "Approval Details",
            onPressedLeadIcon: () => context.pop(),
            leadIconColor: BaseColor.primary3,
          ),
          Gap.h16,
          Material(
            clipBehavior: Clip.hardEdge,
            color: BaseColor.cardBackground1,
            borderRadius: BorderRadius.circular(BaseSize.radiusMd),
            child: Padding(
              padding: EdgeInsets.all(BaseSize.w12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (approval.description.isNotEmpty) ...[
                    Text(
                      'Description',
                      style: BaseTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: BaseColor.secondaryText,
                      ),
                    ),
                    Gap.h6,
                    Text(approval.description, style: BaseTypography.bodyMedium),
                  ],
                ],
              ),
            ),
          ),
          // Supervisor info card
          Gap.h12,
          Material(
            clipBehavior: Clip.hardEdge,
            color: BaseColor.cardBackground1,
            borderRadius: BorderRadius.circular(BaseSize.radiusMd),
            child: Padding(
              padding: EdgeInsets.all(BaseSize.w12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Supervisor',
                    style: BaseTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: BaseColor.secondaryText,
                    ),
                  ),
                  Gap.h6,
                  Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: BaseSize.w16,
                            color: BaseColor.blue.shade500.withValues(
                              alpha: 0.9,
                            ),
                          ),
                          Gap.w8,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  approval.supervisor.account?.name ?? 'Unknown',
                                  style: BaseTypography.bodySmall.copyWith(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Gap.h4,
                                Text(
                                  (approval.supervisor.membershipPositions.isNotEmpty
                                      ? approval.supervisor
                                            .membershipPositions
                                            .first
                                            .name
                                      : 'Member'),
                                  style: BaseTypography.bodySmall.copyWith(
                                    color: BaseColor.secondaryText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      Gap.w8,
                      DividerWidget(
                        axis: Axis.vertical,
                        thickness: 1,
                        height: 16,
                        color: BaseColor.green.shade600.withValues(alpha: 0.24),
                      ),
                      Gap.w8,
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: BaseSize.w16,
                            color: BaseColor.yellow.shade600.withValues(
                              alpha: 0.95,
                            ),
                          ),
                          Gap.w8,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (() {
                                  final dt = approval.createdAt ?? DateTime.now();
                                  return "${dt.EEEEddMMMyyyy} ${dt.HHmm}";
                                })(),
                                style: BaseTypography.bodySmall,
                              ),
                              Gap.h4,
                              Text(
                                (() {
                                  final dt = approval.createdAt ?? DateTime.now();
                                  // Human readable date below
                                  return dt.toFromNow;
                                })(),
                                style: BaseTypography.bodySmall.copyWith(
                                  color: BaseColor.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (approval.approvers.isNotEmpty) ...[
            Gap.h12,
            Material(
              clipBehavior: Clip.hardEdge,
              color: BaseColor.cardBackground1,
              borderRadius: BorderRadius.circular(BaseSize.radiusMd),
              child: Padding(
                padding: EdgeInsets.all(BaseSize.w12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Approvers',
                      style: BaseTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: BaseColor.secondaryText,
                      ),
                    ),
                    Gap.h6,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: approval.approvers.map((ap) {
                        final name = ap.membership.account?.name ?? 'Unknown';
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
                ),
              ),
            ),
          ],
          if (overall == ApprovalStatus.unconfirmed &&
              approval.approvers.any(
                (ap) =>
                    ap.status == ApprovalStatus.approved &&
                    ap.membership.id == currentMembershipId,
              )) ...[
            Gap.h12,
            const InfoBoxWidget(
              message:
                  'Waiting on other approver to either accept or reject this approval',
            ),
          ],
          Gap.h12,
          if (overall == ApprovalStatus.unconfirmed) ...[
            if (!isMinePending) statusPill(ApprovalStatus.unconfirmed),
            if (!isMinePending) Gap.h8,
          ] else ...[
            statusPill(overall),
          ],
        ],
      ),
    );
  }
}
