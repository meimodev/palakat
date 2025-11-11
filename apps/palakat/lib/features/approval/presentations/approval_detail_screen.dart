import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/assets/assets.gen.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/approval/presentations/widgets/approval_status_pill.dart';
import 'package:palakat/features/approval/presentations/widgets/approver_chip.dart';
import 'package:palakat/features/approval/presentations/approval_detail_controller.dart';
import 'package:palakat_admin/core/extension/extension.dart';
import 'package:palakat_admin/core/models/models.dart' hide Column;

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
    final controller = ref.read(
      approvalDetailControllerProvider(activityId: activityId).notifier,
    );
    final detailState = ref.watch(
      approvalDetailControllerProvider(activityId: activityId),
    );
    final activity = detailState.activity;

    final overall = activity != null ? _getOverallStatus(activity.approvers) : null;
    final bool isMinePending = activity != null &&
        activity.approvers.any(
          (ap) =>
              ap.status == ApprovalStatus.unconfirmed &&
              ap.membership!.id == currentMembershipId,
        );

    return ScaffoldWidget(
      persistBottomWidget:
          (overall == ApprovalStatus.unconfirmed && isMinePending)
              ? _buildActionButtons(context)
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
          LoadingWrapper(
            loading: detailState.loadingScreen,
            hasError: detailState.errorMessage != null && detailState.loadingScreen == false,
            errorMessage: detailState.errorMessage,
            onRetry: () => controller.fetch(activityId),
            shimmerPlaceholder: Column(
              children: [
                PalakatShimmerPlaceholders.infoCard(),
                Gap.h12,
                PalakatShimmerPlaceholders.infoCard(),
                Gap.h12,
                PalakatShimmerPlaceholders.approvalCard(),
              ],
            ),
            child: activity == null
                ? const InfoBoxWidget(
                    message:
                        'Approval not found. It may have been removed or is unavailable.',
                  )
                : _buildActivityDetails(context, ref, activity),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityDetails(
    BuildContext context,
    WidgetRef ref,
    Activity activity,
  ) {
    final overall = _getOverallStatus(activity.approvers);
    final bool isMinePending = activity.approvers.any(
      (ap) =>
          ap.status == ApprovalStatus.unconfirmed &&
          ap.membership!.id == currentMembershipId,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildActivityInfoCard(activity),
          Gap.h12,
          _buildSupervisorCard(activity),
          Gap.h12,
          _buildApproversCard(activity),
          if (activity.location != null) ...[
            Gap.h12,
            _buildLocationCard(context, activity),
          ],
          if (activity.note?.trim().isNotEmpty ?? false) ...[
            Gap.h12,
            _buildNoteCard(activity),
          ],
          if (overall == ApprovalStatus.unconfirmed &&
              activity.approvers.any(
                (ap) =>
                    ap.status == ApprovalStatus.approved &&
                    ap.membership!.id == currentMembershipId,
              )) ...[
            Gap.h12,
            const InfoBoxWidget(
              message:
                  'Waiting on other approver to either accept or reject this approval',
            ),
          ],
          Gap.h12,
          if (overall == ApprovalStatus.unconfirmed) ...[
            if (!isMinePending) ApprovalStatusPill(status: overall),
            if (!isMinePending) Gap.h8,
          ] else ...[
            ApprovalStatusPill(status: overall),
          ],
        ],
      );
  }

  ApprovalStatus _getOverallStatus(List<Approver> items) {
    final hasRejected = items.any((e) => e.status == ApprovalStatus.rejected);
    if (hasRejected) return ApprovalStatus.rejected;
    final hasUnconfirmed = items.any(
      (e) => e.status == ApprovalStatus.unconfirmed,
    );
    if (hasUnconfirmed) return ApprovalStatus.unconfirmed;
    return ApprovalStatus.approved;
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BaseColor.white,
        border: Border(
          top: BorderSide(
            color: BaseColor.teal.shade600.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: BaseSize.h12,
        horizontal: BaseSize.w12,
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
    );
  }

  Widget _buildActivityInfoCard(Activity activity) {
    return Material(
      clipBehavior: Clip.hardEdge,
      color: BaseColor.cardBackground1,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      surfaceTintColor: BaseColor.teal[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(BaseSize.w16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: BaseSize.w40,
                  height: BaseSize.w40,
                  decoration: BoxDecoration(
                    color: BaseColor.teal[100],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: BaseColor.teal[200]!.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.event_note_outlined,
                    size: BaseSize.w20,
                    color: BaseColor.teal[700],
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: Text(
                    'Activity Information',
                    style: BaseTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: BaseColor.black,
                    ),
                  ),
                ),
                _buildActivityTypeBadge(activity.activityType),
              ],
            ),
            Gap.h16,
            _buildInfoRow(
              icon: Icons.tag_outlined,
              iconColor: BaseColor.blue.shade500,
              label: 'Activity ID',
              value: '#${activity.id}',
            ),
            Gap.h12,
            _buildInfoRow(
              icon: Icons.title,
              iconColor: BaseColor.teal.shade600,
              label: 'Title',
              value: activity.title,
            ),
            if (activity.description?.isNotEmpty ?? false) ...[
              Gap.h12,
              _buildInfoRow(
                icon: Icons.description_outlined,
                iconColor: BaseColor.neutral.shade60,
                label: 'Description',
                value: activity.description!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSupervisorCard(Activity activity) {
    return Material(
      clipBehavior: Clip.hardEdge,
      color: BaseColor.cardBackground1,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      surfaceTintColor: BaseColor.blue[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(BaseSize.w16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: BaseSize.w40,
                  height: BaseSize.w40,
                  decoration: BoxDecoration(
                    color: BaseColor.blue[100],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: BaseColor.blue[200]!.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.person_outline,
                    size: BaseSize.w20,
                    color: BaseColor.blue[700],
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: Text(
                    'Supervisor',
                    style: BaseTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: BaseColor.black,
                    ),
                  ),
                ),
              ],
            ),
            Gap.h16,
            _buildInfoRow(
              icon: Icons.person_outline,
              iconColor: BaseColor.blue.shade600,
              label: 'Name',
              value: activity.supervisor.account?.name ?? 'Unknown',
            ),
            Gap.h12,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.badge_outlined,
                  size: BaseSize.w20,
                  color: BaseColor.teal.shade600,
                ),
                Gap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Positions',
                        style: BaseTypography.labelMedium.copyWith(
                          color: BaseColor.secondaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Gap.h8,
                      Builder(
                        builder: (context) {
                          final positions =
                              activity.supervisor.membershipPositions;
                          final labels = positions.isNotEmpty
                              ? positions.map((e) => e.name).toList()
                              : <String>['Member'];

                          return Wrap(
                            spacing: BaseSize.w8,
                            runSpacing: BaseSize.h8,
                            children: labels.map((label) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: BaseSize.w12,
                                  vertical: BaseSize.h6,
                                ),
                                decoration: BoxDecoration(
                                  color: BaseColor.teal.shade50,
                                  border: Border.all(
                                    color: BaseColor.teal.shade200,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  label,
                                  style: BaseTypography.bodySmall.copyWith(
                                    color: BaseColor.teal.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
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
            Gap.h12,
            _buildInfoRow(
              icon: Icons.schedule,
              iconColor: BaseColor.yellow.shade600,
              label: 'Created',
              value: (() {
                final dt = activity.createdAt;
                return "${dt.EEEEddMMMyyyy} ${dt.HHmm} • ${dt.toFromNow}";
              })(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApproversCard(Activity activity) {
    return Material(
      clipBehavior: Clip.hardEdge,
      color: BaseColor.cardBackground1,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      surfaceTintColor: BaseColor.green[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(BaseSize.w16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: BaseSize.w40,
                  height: BaseSize.w40,
                  decoration: BoxDecoration(
                    color: BaseColor.green[100],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: BaseColor.green[200]!.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.approval_outlined,
                    size: BaseSize.w20,
                    color: BaseColor.green[700],
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: Text(
                    'Approvers',
                    style: BaseTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: BaseColor.black,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: BaseSize.w10,
                    vertical: BaseSize.h4,
                  ),
                  decoration: BoxDecoration(
                    color: BaseColor.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: BaseColor.green[200]!,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    activity.approvers.length.toString(),
                    style: BaseTypography.labelMedium.copyWith(
                      color: BaseColor.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Gap.h16,
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: activity.approvers.map((ap) {
                final name = ap.membership?.account?.name ?? 'Unknown';
                return Padding(
                  padding: EdgeInsets.only(bottom: BaseSize.h8),
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
    );
  }

  Widget _buildLocationCard(BuildContext context, Activity activity) {
    return Material(
      clipBehavior: Clip.hardEdge,
      color: BaseColor.cardBackground1,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      surfaceTintColor: BaseColor.red[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(BaseSize.w16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: BaseSize.w40,
                  height: BaseSize.w40,
                  decoration: BoxDecoration(
                    color: BaseColor.red[100],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: BaseColor.red[200]!.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.place_outlined,
                    size: BaseSize.w20,
                    color: BaseColor.red[700],
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: Text(
                    'Location',
                    style: BaseTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: BaseColor.black,
                    ),
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
                      size: BaseSize.w20,
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
            Gap.h16,
            _buildInfoRow(
              icon: Icons.location_on,
              iconColor: BaseColor.red.shade500,
              label: 'Address',
              value: activity.location?.name ?? "-",
            ),
            if (activity.location != null) ...[
              Gap.h12,
              _buildInfoRow(
                icon: Icons.my_location,
                iconColor: BaseColor.blue.shade500,
                label: 'Coordinates',
                value:
                    "${activity.location!.latitude.toStringAsFixed(5)}, ${activity.location!.longitude.toStringAsFixed(5)}",
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(Activity activity) {
    return Material(
      clipBehavior: Clip.hardEdge,
      color: BaseColor.cardBackground1,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      surfaceTintColor: BaseColor.yellow[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(BaseSize.w16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: BaseSize.w40,
                  height: BaseSize.w40,
                  decoration: BoxDecoration(
                    color: BaseColor.yellow[100],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: BaseColor.yellow[200]!.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.sticky_note_2_outlined,
                    size: BaseSize.w20,
                    color: BaseColor.yellow[700],
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: Text(
                    'Note',
                    style: BaseTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: BaseColor.black,
                    ),
                  ),
                ),
              ],
            ),
            Gap.h16,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.note_outlined,
                  size: BaseSize.w20,
                  color: BaseColor.yellow.shade600,
                ),
                Gap.w12,
                Expanded(
                  child: Text(
                    activity.note ?? "-",
                    style: BaseTypography.bodyMedium.copyWith(
                      color: BaseColor.black,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: BaseSize.w20,
          color: iconColor,
        ),
        Gap.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: BaseTypography.labelMedium.copyWith(
                  color: BaseColor.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Gap.h4,
              Text(
                value,
                style: BaseTypography.bodyMedium.copyWith(
                  color: BaseColor.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityTypeBadge(ActivityType type) {
    final Color baseColor = type == ActivityType.announcement
        ? BaseColor.yellow.shade600
        : (type == ActivityType.event
              ? BaseColor.green.shade600
              : BaseColor.blue.shade600);

    final IconData iconData = type == ActivityType.announcement
        ? Icons.campaign_outlined
        : (type == ActivityType.event
              ? Icons.event_outlined
              : Icons.info_outline);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w10,
        vertical: BaseSize.h6,
      ),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.1),
        border: Border.all(
          color: baseColor.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: BaseSize.w14,
            color: baseColor,
          ),
          Gap.w6,
          Text(
            type.name.toCamelCase,
            style: BaseTypography.labelMedium.copyWith(
              color: baseColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
