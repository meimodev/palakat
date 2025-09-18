import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/assets/assets.gen.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/utils/extensions/extension.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/core/models/models.dart' hide Column;
import 'package:palakat/features/approval/presentations/widgets/approval_status_pill.dart';
import 'package:palakat/features/approval/presentations/widgets/approver_chip.dart';
import 'package:palakat/features/approval/presentations/approval_detail_controller.dart';

class ApprovalDetailScreen extends ConsumerWidget {
  const ApprovalDetailScreen({
    super.key,
    required this.activityId,
    this.currentMembershipId,
  });

  final int activityId;
  final int? currentMembershipId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(
      approvalDetailControllerProvider(activityId: activityId),
    );
    final activity = detailState.activity;

    if (detailState.loadingScreen) {
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
            const Center(child: CircularProgressIndicator()),
          ],
        ),
      );
    }

    if (activity == null) {
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
              message:
                  'Approval not found. It may have been removed or is unavailable.',
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

    final overall = overallStatus(activity.approvers);
    final bool isMinePending = activity.approvers.any(
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
              padding: EdgeInsets.symmetric(vertical: BaseSize.w12),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Activity information',
                        style: BaseTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: BaseColor.secondaryText,
                        ),
                      ),
                      Gap.w4,
                      Builder(
                        builder: (context) {
                          final type = activity.type;
                          final Color base = type == ActivityType.announcement
                              ? BaseColor.yellow.shade600
                              : (type == ActivityType.event
                                    ? BaseColor.green.shade600
                                    : BaseColor.blue.shade600);

                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: BaseSize.w8,
                              vertical: BaseSize.h4,
                            ),
                            decoration: BoxDecoration(
                              color: base.withValues(alpha: 0.12),
                              border: Border.all(
                                color: base.withValues(alpha: 0.36),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.campaign_outlined,
                                  size: BaseSize.w12,
                                  color: base,
                                ),
                                Gap.w4,
                                Text(
                                  activity.type.name.capitalizeEachWord,
                                  style: BaseTypography.bodySmall.copyWith(
                                    color: base,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Gap.h8,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.tag_outlined,
                        size: BaseSize.w16,
                        color: BaseColor.blue.shade500.withValues(alpha: 0.9),
                      ),
                      Gap.w8,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Activity ID',
                              style: BaseTypography.bodySmall.toSecondary,
                            ),
                            Gap.h4,
                            Text(
                              '#${activity.id}',
                              style: BaseTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Gap.h8,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.title,
                        size: BaseSize.w16,
                        color: BaseColor.green.shade600.withValues(alpha: 0.95),
                      ),
                      Gap.w8,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Title',
                              style: BaseTypography.bodySmall.toSecondary,
                            ),
                            Gap.h4,
                            Text(
                              activity.title,
                              style: BaseTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Gap.h8,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: BaseSize.w16,
                        color: BaseColor.neutral.shade60.withValues(alpha: 0.9),
                      ),
                      Gap.w8,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Description',
                              style: BaseTypography.bodySmall.toSecondary,
                            ),
                            Gap.h4,
                            Text(
                              (activity.description).valueOrDash,
                              style: BaseTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                    'Supervisor Information',
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
                                  activity.supervisor.account?.name ??
                                      'Unknown',
                                  style: BaseTypography.bodySmall.copyWith(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Gap.h4,
                                Builder(
                                  builder: (context) {
                                    final positions =
                                        activity.supervisor.membershipPositions;
                                    final labels = positions.isNotEmpty
                                        ? positions.map((e) => e.name).toList()
                                        : <String>['Member'];

                                    return Wrap(
                                      spacing: BaseSize.w6,
                                      runSpacing: BaseSize.h6,
                                      children: labels.map((label) {
                                        return Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: BaseSize.w8,
                                            vertical: BaseSize.h4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: BaseColor.neutral.shade60
                                                .withValues(alpha: 0.08),
                                            border: Border.all(
                                              color: BaseColor.neutral.shade60
                                                  .withValues(alpha: 0.24),
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Text(
                                            label,
                                            style: BaseTypography.bodySmall,
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  },
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
                                  final dt = activity.createdAt;
                                  return "${dt.EEEEddMMMyyyy} ${dt.HHmm}";
                                })(),
                                style: BaseTypography.bodySmall,
                              ),
                              Gap.h4,
                              Text(
                                (() {
                                  final dt = activity.createdAt;
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
                    children: activity.approvers.map((ap) {
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
          // Location card
          if (activity.location != null) ...[
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
                      'Location',
                      style: BaseTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: BaseColor.secondaryText,
                      ),
                    ),
                    Gap.h6,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: BaseSize.w16,
                          color: BaseColor.red.shade500.withValues(alpha: 0.95),
                        ),
                        Gap.w8,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (activity.location?.name).valueOrDash,
                                style: BaseTypography.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (activity.location != null) ...[
                                Gap.h4,
                                Text(
                                  "${activity.location!.latitude.toStringAsFixed(5)}, ${activity.location!.longitude.toStringAsFixed(5)}",
                                  style: BaseTypography.bodySmall.toSecondary,
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (activity.location != null)
                          IconButton(
                            tooltip: 'View on Map',
                            onPressed: () {
                              context.pushNamed(
                                AppRoute.publishingMap,
                                extra: RouteParam(
                                  params: {
                                    RouteParamKey.mapOperationType:
                                        MapOperationType.read,
                                    RouteParamKey.location: activity.location!
                                        .toJson(),
                                  },
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.map_outlined,
                              size: BaseSize.w18,
                              color: BaseColor.primary3,
                            ),
                            style: ButtonStyle(
                              overlayColor: WidgetStateProperty.all(
                                BaseColor.primary2.withValues(alpha: 0.12),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          // Note card
          if ((activity.note?.trim().isNotEmpty ?? false)) ...[
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
                      'Note',
                      style: BaseTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: BaseColor.secondaryText,
                      ),
                    ),
                    Gap.h6,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.sticky_note_2_outlined,
                          size: BaseSize.w16,
                          color: BaseColor.blue.shade500.withValues(alpha: 0.95),
                        ),
                        Gap.w8,
                        Expanded(
                          child: Text(
                            (activity.note).valueOrDash,
                            style: BaseTypography.bodySmall,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (overall == ApprovalStatus.unconfirmed &&
              activity.approvers.any(
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
