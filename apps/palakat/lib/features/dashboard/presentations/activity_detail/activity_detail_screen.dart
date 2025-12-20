import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/approval/presentations/widgets/approval_confirmation_bottom_sheet.dart';
import 'package:palakat/features/dashboard/presentations/activity_detail/activity_detail_controller.dart';
import 'package:palakat/features/dashboard/presentations/activity_detail/activity_detail_state.dart';
import 'package:palakat/features/operations/presentations/operations_controller.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;
import 'package:palakat_shared/core/repositories/repositories.dart';
import 'package:url_launcher/url_launcher.dart';

class ActivityDetailScreen extends ConsumerWidget {
  const ActivityDetailScreen({
    super.key,
    required this.activityId,
    this.isFromApprovalContext = false,
  });

  final int activityId;

  /// Flag indicating navigation from approval context (Req 6.2, 6.3)
  /// When true, approve/reject buttons are hidden (read-only mode)
  final bool isFromApprovalContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activityDetailControllerProvider(activityId));
    final l10n = context.l10n;

    if (state.isLoading) {
      return ScaffoldWidget(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScreenTitleWidget.primary(
                title: l10n.loading_activities,
                leadIcon: AppIcons.back,
                leadIconColor: Colors.black,
                onPressedLeadIcon: context.pop,
              ),
              Gap.h16,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: BaseSize.w12),
                child: LoadingShimmer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PalakatShimmerPlaceholders.activityCard(),
                      Gap.h16,
                      PalakatShimmerPlaceholders.infoCard(),
                      Gap.h16,
                      PalakatShimmerPlaceholders.listItemCard(),
                      Gap.h16,
                      PalakatShimmerPlaceholders.infoCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.errorMessage != null) {
      return ScaffoldWidget(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(BaseSize.w16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(AppIcons.error, size: 48, color: BaseColor.red),
                Gap.h16,
                Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                  style: BaseTypography.bodyMedium,
                ),
                Gap.h16,
                ElevatedButton(
                  onPressed: () => ref
                      .read(
                        activityDetailControllerProvider(activityId).notifier,
                      )
                      .fetchActivity(),
                  child: Text(l10n.btn_retry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final activity = state.activity;
    if (activity == null) {
      return ScaffoldWidget(
        child: Center(
          child: Text(
            l10n.msg_activityNotFound,
            style: BaseTypography.bodyMedium,
          ),
        ),
      );
    }

    return _buildContent(context, ref, state, activity);
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ActivityDetailState state,
    Activity activity,
  ) {
    // Check if supervisor can self-approve (Requirements: 8.1, 8.2)
    // Hide approval buttons when accessed from approval context (Req 6.3)
    // **Feature: approval-card-detail-redesign, Property 7: Activity detail from approval context has no action buttons**
    final showSelfApprovalButtons =
        state.isSupervisorApprovalPending && !isFromApprovalContext;

    return ScaffoldWidget(
      persistBottomWidget: showSelfApprovalButtons
          ? _buildSelfApprovalButtons(context, ref, state)
          : null,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenTitleWidget.primary(
              title: activity.activityType.displayName,
              subTitle: activity.title,
              leadIcon: AppIcons.back,
              leadIconColor: Colors.black,
              onPressedLeadIcon: context.pop,
            ),
            Gap.h16,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: BaseSize.w12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildActivityTypeIndicator(activity),
                  Gap.h12,
                  _buildBasicInfoSection(context, ref, activity),
                  Gap.h16,
                  _buildNoteSection(context, activity),
                  Gap.h16,
                  _buildScheduleSection(context, activity),
                  Gap.h16,
                  _buildLocationSection(context, activity),
                  Gap.h16,
                  _buildFinanceSection(context, activity),
                  Gap.h16,
                  _buildApproversSection(context, activity, state),
                  Gap.h16,
                  _buildSupervisorSection(context, activity),
                  Gap.h24,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the self-approval action buttons (approve/reject).
  /// Requirements: 8.2
  Widget _buildSelfApprovalButtons(
    BuildContext context,
    WidgetRef ref,
    ActivityDetailState state,
  ) {
    final isLoading = state.isApprovalLoading;
    final activityTitle = state.activity?.title ?? '';
    final controller = ref.read(
      activityDetailControllerProvider(activityId).notifier,
    );

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
              child: _buildRejectButton(
                context,
                ref,
                controller,
                isLoading,
                activityTitle,
              ),
            ),
            Gap.w12,
            Expanded(
              child: _buildApproveButton(
                context,
                ref,
                controller,
                isLoading,
                activityTitle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the reject button for self-approval.
  Widget _buildRejectButton(
    BuildContext context,
    WidgetRef ref,
    ActivityDetailController controller,
    bool isLoading,
    String activityTitle,
  ) {
    return _buildActionButton(
      text: context.l10n.btn_reject,
      icon: AppIcons.close,
      color: BaseColor.red.shade500,
      isLoading: isLoading,
      onTap: () async {
        final confirmed = await _showConfirmationDialog(
          context,
          isApprove: false,
          activityTitle: activityTitle,
        );
        if (confirmed != true || !context.mounted) return;

        final success = await controller.rejectSelfApproval();
        if (context.mounted && success) {
          ref.invalidate(operationsControllerProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.msg_activityRejected),
              backgroundColor: BaseColor.red[600],
            ),
          );
        }
      },
    );
  }

  /// Builds the approve button for self-approval.
  Widget _buildApproveButton(
    BuildContext context,
    WidgetRef ref,
    ActivityDetailController controller,
    bool isLoading,
    String activityTitle,
  ) {
    return _buildActionButton(
      text: context.l10n.btn_approve,
      icon: AppIcons.approve,
      color: BaseColor.green.shade600,
      isLoading: isLoading,
      onTap: () async {
        final confirmed = await _showConfirmationDialog(
          context,
          isApprove: true,
          activityTitle: activityTitle,
        );
        if (confirmed != true || !context.mounted) return;

        final success = await controller.approveSelfApproval();
        if (context.mounted && success) {
          ref.invalidate(operationsControllerProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.msg_activityApproved),
              backgroundColor: BaseColor.green[600],
            ),
          );
        }
      },
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Color color,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        onTap: isLoading ? null : onTap,
        overlayColor: WidgetStateProperty.all(color.withValues(alpha: 0.12)),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: BaseSize.w24,
            vertical: BaseSize.h8,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(BaseSize.radiusMd),
          ),
          child: isLoading
              ? Center(
                  child: SizedBox(
                    height: BaseSize.h18,
                    width: BaseSize.h18,
                    child: CircularProgressIndicator(color: color),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(icon, size: BaseSize.w18, color: color),
                    Gap.w8,
                    Text(
                      text,
                      style: BaseTypography.labelSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  /// Shows a confirmation dialog for approval actions.
  Future<bool?> _showConfirmationDialog(
    BuildContext context, {
    required bool isApprove,
    required String activityTitle,
  }) {
    return showApprovalConfirmationBottomSheet(
      context: context,
      isApprove: isApprove,
      activityTitle: activityTitle,
    );
  }

  Widget _buildActivityTypeIndicator(Activity activity) {
    final typeConfig = _getTypeConfig(activity);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w12,
        vertical: BaseSize.h8,
      ),
      decoration: BoxDecoration(
        color: typeConfig.backgroundColor,
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        border: Border.all(color: typeConfig.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            typeConfig.icon,
            size: BaseSize.w18,
            color: typeConfig.iconColor,
          ),
          Gap.w8,
          Text(
            typeConfig.label,
            style: BaseTypography.titleMedium.copyWith(
              color: typeConfig.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _TypeConfig _getTypeConfig(Activity activity) {
    switch (activity.activityType) {
      case ActivityType.service:
        return _TypeConfig(
          icon: AppIcons.church,
          label: activity.activityType.displayName,
          backgroundColor: BaseColor.primary[50]!,
          borderColor: BaseColor.primary[200]!,
          iconColor: BaseColor.primary[700]!,
          textColor: BaseColor.primary[700]!,
        );
      case ActivityType.event:
        return _TypeConfig(
          icon: AppIcons.event,
          label: activity.activityType.displayName,
          backgroundColor: BaseColor.blue[50]!,
          borderColor: BaseColor.blue[200]!,
          iconColor: BaseColor.blue[700]!,
          textColor: BaseColor.blue[700]!,
        );
      case ActivityType.announcement:
        return _TypeConfig(
          icon: AppIcons.announcement,
          label: activity.activityType.displayName,
          backgroundColor: BaseColor.yellow[50]!,
          borderColor: BaseColor.yellow[200]!,
          iconColor: BaseColor.yellow[700]!,
          textColor: BaseColor.yellow[700]!,
        );
    }
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    String? subtitle,
    Color? iconBgColor,
    Color? iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: BaseColor.white,
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        border: Border.all(color: BaseColor.neutral[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(BaseSize.w12),
            decoration: BoxDecoration(
              color: BaseColor.neutral[50],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(BaseSize.radiusMd),
                topRight: Radius.circular(BaseSize.radiusMd),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(BaseSize.w6),
                  decoration: BoxDecoration(
                    color: iconBgColor ?? BaseColor.primary[50],
                    borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                  ),
                  child: Icon(
                    icon,
                    size: BaseSize.w16,
                    color: iconColor ?? BaseColor.primary[600],
                  ),
                ),
                Gap.w8,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: BaseTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: BaseColor.textPrimary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        Gap.h4,
                        Text(
                          subtitle,
                          style: BaseTypography.bodyMedium.copyWith(
                            color: BaseColor.neutral[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(BaseSize.w12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupervisorSection(BuildContext context, Activity activity) {
    final supervisor = activity.supervisor;
    final positions = supervisor.membershipPositions;
    return _buildSectionCard(
      title: context.l10n.section_personInCharge,
      icon: AppIcons.person,
      iconBgColor: BaseColor.teal[50],
      iconColor: BaseColor.teal[600],
      children: [
        Container(
          padding: EdgeInsets.all(BaseSize.w12),
          decoration: BoxDecoration(
            color: BaseColor.teal[50],
            borderRadius: BorderRadius.circular(BaseSize.radiusSm),
            border: Border.all(color: BaseColor.teal[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                supervisor.account?.name ?? context.l10n.lbl_unknown,
                style: BaseTypography.titleMedium.copyWith(
                  color: BaseColor.teal[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (supervisor.account?.phone != null) ...[
                Gap.h4,
                Row(
                  children: [
                    FaIcon(
                      AppIcons.phone,
                      size: BaseSize.w12,
                      color: BaseColor.teal[600],
                    ),
                    Gap.w4,
                    Text(
                      supervisor.account?.phone ?? '',
                      style: BaseTypography.bodySmall.copyWith(
                        color: BaseColor.teal[600],
                      ),
                    ),
                  ],
                ),
              ],
              if (positions.isNotEmpty) ...[
                Gap.h8,
                Wrap(
                  spacing: BaseSize.w6,
                  runSpacing: BaseSize.h4,
                  children: positions
                      .map(
                        (p) => Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: BaseSize.w8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: BaseColor.teal[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            p.name,
                            style: BaseTypography.labelSmall.copyWith(
                              color: BaseColor.teal[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection(
    BuildContext context,
    WidgetRef ref,
    Activity activity,
  ) {
    final l10n = context.l10n;
    final hasBipra = activity.bipra != null;
    final hasFile = activity.fileId != null;

    final fileName =
        activity.file?.originalName ??
        (activity.file?.path?.split('/').last ?? l10n.lbl_na);

    final activityIdText = activity.id != null
        ? '#${activity.id}'
        : l10n.lbl_na;

    final createdAtText =
        '${activity.createdAt.EEEEddMMMyyyy} ${activity.createdAt.HHmm} • ${activity.createdAt.toFromNow}';
    final updatedAtText = activity.updatedAt != null
        ? '${activity.updatedAt!.EEEEddMMMyyyy} ${activity.updatedAt!.HHmm} • ${activity.updatedAt!.toFromNow}'
        : l10n.lbl_na;

    return _buildSectionCard(
      title: l10n.section_basicInformation,
      icon: AppIcons.info,
      subtitle: activity.title,
      children: [
        _buildInfoRow(
          icon: AppIcons.info,
          iconColor: BaseColor.blue[600],
          label: l10n.lbl_activityId,
          value: activityIdText,
        ),
        Gap.h12,
        _buildInfoRow(
          icon: AppIcons.createdAt,
          iconColor: BaseColor.neutral[600],
          label: l10n.lbl_createdAt,
          value: createdAtText,
        ),
        Gap.h12,
        _buildInfoRow(
          icon: AppIcons.schedule,
          iconColor: BaseColor.neutral[600],
          label: l10n.lbl_updatedAt,
          value: updatedAtText,
        ),
        Gap.h12,
        _buildInfoRow(
          icon: AppIcons.document,
          iconColor: BaseColor.primary[600],
          label: l10n.tbl_file,
          value: hasFile ? fileName : l10n.lbl_na,
          onTap: hasFile
              ? () async {
                  final repo = ref.read(fileManagerRepositoryProvider);
                  final result = await repo.resolveDownloadUrl(
                    fileId: activity.fileId!,
                  );
                  result.when(
                    onSuccess: (url) => _openUrl(url),
                    onFailure: (failure) {
                      final msg = failure.message.trim();
                      if (msg.isEmpty) {
                        return;
                      }
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(msg)));
                    },
                  );
                }
              : null,
        ),
        Gap.h12,
        if (hasBipra)
          _buildBipraInfo(context, activity)
        else
          _buildInfoRow(
            icon: AppIcons.info,
            iconColor: BaseColor.blue[600],
            label: l10n.lbl_targetAudience,
            value: l10n.lbl_notSpecified,
          ),
        Gap.h12,
        _buildInfoRow(
          icon: AppIcons.description,
          iconColor: BaseColor.teal[600],
          label: l10n.lbl_description,
          value:
              (activity.description != null &&
                  activity.description!.trim().isNotEmpty)
              ? activity.description!.trim()
              : l10n.lbl_notSpecified,
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    final effectiveIconColor = iconColor ?? BaseColor.neutral[600];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(BaseSize.radiusSm),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: BaseSize.h4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: BaseSize.w32,
                height: BaseSize.w32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      effectiveIconColor?.withValues(alpha: 0.1) ??
                      BaseColor.neutral[100],
                  borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                ),
                child: FaIcon(
                  icon,
                  size: BaseSize.w16,
                  color: effectiveIconColor ?? BaseColor.neutral[600],
                ),
              ),
              Gap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: BaseTypography.bodySmall.copyWith(
                        color: BaseColor.neutral[500],
                      ),
                    ),
                    Gap.h4,
                    Text(
                      value,
                      style: BaseTypography.bodyMedium.copyWith(
                        color: BaseColor.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null) ...[
                Gap.w8,
                Padding(
                  padding: EdgeInsets.only(top: BaseSize.h4),
                  child: FaIcon(
                    AppIcons.openExternal,
                    size: BaseSize.w16,
                    color: BaseColor.neutral[400],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBipraInfo(BuildContext context, Activity activity) {
    final bipra = activity.bipra!;
    return Container(
      padding: EdgeInsets.all(BaseSize.w12),
      decoration: BoxDecoration(
        color: BaseColor.blue[50],
        borderRadius: BorderRadius.circular(BaseSize.radiusSm),
        border: Border.all(color: BaseColor.blue[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: BaseSize.w40,
            height: BaseSize.w40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [BaseColor.blue[400]!, BaseColor.blue[600]!],
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              bipra.abv,
              style: BaseTypography.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Gap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.lbl_targetAudience,
                  style: BaseTypography.labelSmall.copyWith(
                    color: BaseColor.blue[600],
                  ),
                ),
                Gap.h4,
                Text(
                  bipra.name,
                  style: BaseTypography.bodyMedium.copyWith(
                    color: BaseColor.blue[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection(BuildContext context, Activity activity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDateTimeCard(context, activity),
        Gap.h12,
        _buildReminderInfo(context, activity),
      ],
    );
  }

  Widget _buildDateTimeCard(BuildContext context, Activity activity) {
    return Container(
      padding: EdgeInsets.all(BaseSize.w12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [BaseColor.blue[50]!, BaseColor.primary[50]!],
        ),
        borderRadius: BorderRadius.circular(BaseSize.radiusSm),
        border: Border.all(color: BaseColor.blue[100]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDateTimeItem(
              icon: AppIcons.calendar,
              label: context.l10n.lbl_date,
              value: activity.date.ddMmmmYyyy,
              subValue: activity.date.EEEEddMMMyyyyShort.split(',').first,
              color: BaseColor.blue,
            ),
          ),
          Container(
            width: 1,
            height: BaseSize.h48,
            color: BaseColor.neutral[200],
          ),
          Expanded(
            child: _buildDateTimeItem(
              icon: AppIcons.time,
              label: context.l10n.lbl_time,
              value: activity.date.HHmm,
              subValue: _getTimePeriod(context, activity.date),
              color: BaseColor.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeItem({
    required IconData icon,
    required String label,
    required String value,
    required String subValue,
    required MaterialColor color,
  }) {
    return Column(
      children: [
        Container(
          width: BaseSize.w36,
          height: BaseSize.w36,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: color[100], shape: BoxShape.circle),
          child: Icon(icon, size: BaseSize.w18, color: color[600]),
        ),
        Gap.h8,
        Text(
          value,
          style: BaseTypography.titleMedium.copyWith(
            color: color[700],
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        Gap.h4,
        Text(
          subValue,
          style: BaseTypography.bodySmall.copyWith(color: color[500]),
        ),
      ],
    );
  }

  String _getTimePeriod(BuildContext context, DateTime date) {
    final l10n = context.l10n;
    if (date.hour < 12) return l10n.timePeriod_morning;
    if (date.hour < 17) return l10n.timePeriod_afternoon;
    return l10n.timePeriod_evening;
  }

  Widget _buildReminderInfo(BuildContext context, Activity activity) {
    final reminder = activity.reminder;
    if (reminder == null) {
      return Container(
        padding: EdgeInsets.all(BaseSize.w12),
        decoration: BoxDecoration(
          color: BaseColor.neutral[50],
          borderRadius: BorderRadius.circular(BaseSize.radiusSm),
          border: Border.all(color: BaseColor.neutral[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(BaseSize.w8),
              decoration: BoxDecoration(
                color: BaseColor.neutral[100],
                borderRadius: BorderRadius.circular(BaseSize.radiusSm),
              ),
              child: FaIcon(
                AppIcons.notificationActive,
                size: BaseSize.w20,
                color: BaseColor.neutral[600],
              ),
            ),
            Gap.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.lbl_reminder,
                    style: BaseTypography.labelSmall.copyWith(
                      color: BaseColor.neutral[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Gap.h4,
                  Text(
                    context.l10n.lbl_na,
                    style: BaseTypography.bodyMedium.copyWith(
                      color: BaseColor.neutral[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final reminderDate = _calculateReminderDate(activity, reminder);

    return Container(
      padding: EdgeInsets.all(BaseSize.w12),
      decoration: BoxDecoration(
        color: BaseColor.yellow[50],
        borderRadius: BorderRadius.circular(BaseSize.radiusSm),
        border: Border.all(color: BaseColor.yellow[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(BaseSize.w8),
            decoration: BoxDecoration(
              color: BaseColor.yellow[100],
              borderRadius: BorderRadius.circular(BaseSize.radiusSm),
            ),
            child: FaIcon(
              AppIcons.notificationActive,
              size: BaseSize.w20,
              color: BaseColor.yellow[700],
            ),
          ),
          Gap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.lbl_reminder,
                  style: BaseTypography.labelSmall.copyWith(
                    color: BaseColor.yellow[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Gap.h4,
                Text(
                  reminder.name,
                  style: BaseTypography.bodyMedium.copyWith(
                    color: BaseColor.yellow[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Gap.h4,
                Text(
                  context.l10n.msg_willBeRemindedAt(reminderDate),
                  style: BaseTypography.bodySmall.copyWith(
                    color: BaseColor.yellow[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _calculateReminderDate(Activity activity, Reminder reminder) {
    Duration offset;
    switch (reminder) {
      case Reminder.tenMinutes:
        offset = const Duration(minutes: 10);
      case Reminder.thirtyMinutes:
        offset = const Duration(minutes: 30);
      case Reminder.oneHour:
        offset = const Duration(hours: 1);
      case Reminder.twoHour:
        offset = const Duration(hours: 2);
    }
    final reminderDateTime = activity.date.subtract(offset);
    return '${reminderDateTime.ddMmmmYyyy} ${reminderDateTime.HHmm}';
  }

  Widget _buildLocationSection(BuildContext context, Activity activity) {
    final location = activity.location;
    final hasCoordinates =
        location?.latitude != null && location?.longitude != null;
    final hasName = (location?.name.trim().isNotEmpty ?? false);
    final isAvailable = location != null && (hasName || hasCoordinates);
    final displayName = hasName
        ? location!.name
        : hasCoordinates
        ? '${location!.latitude!.toStringAsFixed(5)}, ${location.longitude!.toStringAsFixed(5)}'
        : context.l10n.lbl_notSpecified;

    return GestureDetector(
      onTap: hasCoordinates
          ? () => _openGoogleMaps(location!.latitude!, location.longitude!)
          : null,
      child: Container(
        padding: EdgeInsets.all(BaseSize.w12),
        decoration: BoxDecoration(
          color: BaseColor.primary[50],
          borderRadius: BorderRadius.circular(BaseSize.radiusSm),
          border: Border.all(color: BaseColor.primary[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(BaseSize.w8),
              decoration: BoxDecoration(
                color: BaseColor.primary[100],
                borderRadius: BorderRadius.circular(BaseSize.radiusSm),
              ),
              child: FaIcon(
                AppIcons.location,
                size: BaseSize.w20,
                color: BaseColor.primary[600],
              ),
            ),
            Gap.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: isAvailable
                        ? BaseTypography.bodyMedium.copyWith(
                            color: BaseColor.primary[800],
                            fontWeight: FontWeight.w600,
                          )
                        : BaseTypography.bodyMedium.copyWith(
                            color: BaseColor.neutral[600],
                            fontStyle: FontStyle.italic,
                          ),
                  ),
                  if (hasCoordinates) ...[
                    Gap.h4,
                    Row(
                      children: [
                        FaIcon(
                          AppIcons.coordinates,
                          size: BaseSize.w12,
                          color: BaseColor.primary[500],
                        ),
                        Gap.w4,
                        Expanded(
                          child: Text(
                            '${location!.latitude!.toStringAsFixed(5)}, ${location.longitude!.toStringAsFixed(5)}',
                            style: BaseTypography.bodySmall.copyWith(
                              color: BaseColor.primary[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (hasCoordinates)
              FaIcon(
                AppIcons.openExternal,
                size: BaseSize.w18,
                color: BaseColor.primary[400],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openGoogleMaps(double latitude, double longitude) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openUrl(String urlString) async {
    final uri = Uri.tryParse(urlString);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildFinanceSection(BuildContext context, Activity activity) {
    final financeType = activity.financeType;
    if (financeType == null) {
      return Container(
        padding: EdgeInsets.all(BaseSize.w12),
        decoration: BoxDecoration(
          color: BaseColor.neutral[50],
          borderRadius: BorderRadius.circular(BaseSize.radiusMd),
          border: Border.all(color: BaseColor.neutral[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(BaseSize.w8),
              decoration: BoxDecoration(
                color: BaseColor.neutral[100],
                borderRadius: BorderRadius.circular(BaseSize.radiusSm),
              ),
              child: Icon(
                AppIcons.wallet,
                size: BaseSize.w20,
                color: BaseColor.neutral[600],
              ),
            ),
            Gap.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.section_financialRecord,
                    style: BaseTypography.labelSmall.copyWith(
                      color: BaseColor.neutral[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Gap.h4,
                  Text(
                    context.l10n.lbl_na,
                    style: BaseTypography.titleLarge.copyWith(
                      color: BaseColor.neutral[700],
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    final financeData = activity.financeData;
    final isRevenue = financeType == FinanceType.revenue;
    final color = isRevenue ? BaseColor.green : BaseColor.red;

    final amount = financeData?.amount ?? 0;
    final displayAmount = isRevenue ? amount : -amount;
    final accountNumber =
        financeData?.financialAccountNumber?.accountNumber ??
        financeData?.accountNumber ??
        '-';
    final accountDesc = financeData?.financialAccountNumber?.description;

    return Container(
      padding: EdgeInsets.all(BaseSize.w12),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        border: Border.all(color: color[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(BaseSize.w8),
                decoration: BoxDecoration(
                  color: color[100],
                  borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                ),
                child: Icon(
                  financeType.icon,
                  size: BaseSize.w20,
                  color: color[600],
                ),
              ),
              Gap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      financeType.displayName,
                      style: BaseTypography.labelSmall.copyWith(
                        color: color[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Gap.h4,
                    Text(
                      _formatCurrency(displayAmount),
                      style: BaseTypography.titleLarge.copyWith(
                        color: color[800],
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gap.h12,
          Container(
            padding: EdgeInsets.all(BaseSize.w8),
            decoration: BoxDecoration(
              color: BaseColor.white,
              borderRadius: BorderRadius.circular(BaseSize.radiusSm),
            ),
            child: Row(
              children: [
                FaIcon(
                  AppIcons.bankAccount,
                  size: BaseSize.w16,
                  color: color[600],
                ),
                Gap.w8,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.lbl_accountNumber,
                        style: BaseTypography.labelSmall.copyWith(
                          color: BaseColor.neutral[500],
                        ),
                      ),
                      Text(
                        accountNumber,
                        style: BaseTypography.bodyMedium.copyWith(
                          color: color[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (accountDesc != null && accountDesc.isNotEmpty) ...[
                        Text(
                          accountDesc,
                          style: BaseTypography.bodySmall.copyWith(
                            color: BaseColor.neutral[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final formatted = absAmount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return '${isNegative ? '-' : ''}Rp $formatted';
  }

  Widget _buildNoteSection(BuildContext context, Activity activity) {
    final note = activity.note?.trim();
    final hasNote = note != null && note.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: BaseColor.yellow[50],
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        border: Border.all(color: BaseColor.yellow[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(BaseSize.w12),
            decoration: BoxDecoration(
              color: BaseColor.yellow[100],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(BaseSize.radiusMd),
                topRight: Radius.circular(BaseSize.radiusMd),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(BaseSize.w6),
                  decoration: BoxDecoration(
                    color: BaseColor.yellow[200],
                    borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                  ),
                  child: FaIcon(
                    AppIcons.notes,
                    size: BaseSize.w16,
                    color: BaseColor.yellow[700],
                  ),
                ),
                Gap.w8,
                Text(
                  context.l10n.lbl_note,
                  style: BaseTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: BaseColor.yellow[800],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(BaseSize.w12),
            child: Text(
              hasNote ? note : context.l10n.lbl_na,
              style: hasNote
                  ? BaseTypography.bodyMedium.copyWith(
                      color: BaseColor.yellow[900],
                      height: 1.5,
                    )
                  : BaseTypography.bodyMedium.copyWith(
                      color: BaseColor.neutral[600],
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the approvers section with visual indicator for self-approval.
  /// Requirements: 8.5
  Widget _buildApproversSection(
    BuildContext context,
    Activity activity,
    ActivityDetailState state,
  ) {
    final supervisorApproverRecord = state.supervisorApproverRecord;

    if (activity.approvers.isEmpty) {
      return _buildSectionCard(
        title: context.l10n.section_approvalStatus,
        icon: AppIcons.verified,
        subtitle: context.l10n.msg_noApproversAssigned,
        iconBgColor: BaseColor.green[50],
        iconColor: BaseColor.green[600],
        children: [
          Text(
            context.l10n.msg_noApproversAssigned,
            style: BaseTypography.bodyMedium.copyWith(
              color: BaseColor.neutral[600],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return _buildSectionCard(
      title: context.l10n.section_approvalStatus,
      icon: AppIcons.verified,
      subtitle: context.l10n.msg_approverCount(activity.approvers.length),
      iconBgColor: BaseColor.green[50],
      iconColor: BaseColor.green[600],
      children: activity.approvers
          .map(
            (approver) => Padding(
              padding: EdgeInsets.only(bottom: BaseSize.h8),
              child: _buildApproverItem(
                context,
                approver,
                isSupervisorApprover:
                    supervisorApproverRecord?.id == approver.id,
              ),
            ),
          )
          .toList(),
    );
  }

  /// Builds an individual approver item with optional highlight for supervisor.
  /// Requirements: 8.5
  Widget _buildApproverItem(
    BuildContext context,
    Approver approver, {
    bool isSupervisorApprover = false,
  }) {
    final statusColor = _getApprovalStatusColor(approver.status);
    final statusIcon = _getApprovalStatusIcon(approver.status);
    final positions = approver.membership?.membershipPositions ?? [];

    // Use blue highlight for supervisor's approver record (Requirements: 8.5)
    final bgColor = isSupervisorApprover
        ? BaseColor.blue[50]!
        : statusColor.withValues(alpha: 0.05);
    final borderColor = isSupervisorApprover
        ? BaseColor.blue[300]!
        : statusColor.withValues(alpha: 0.2);

    return Container(
      padding: EdgeInsets.all(BaseSize.w12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(BaseSize.radiusSm),
        border: Border.all(
          color: borderColor,
          width: isSupervisorApprover ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        approver.membership?.account?.name ??
                            context.l10n.lbl_unknown,
                        style: BaseTypography.bodyMedium.copyWith(
                          color: BaseColor.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    // Visual indicator for supervisor's approver record (Requirements: 8.5)
                    if (isSupervisorApprover) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: BaseSize.w8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: BaseColor.blue[100],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: BaseColor.blue[300]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(
                              AppIcons.personPin,
                              size: BaseSize.w12,
                              color: BaseColor.blue[700],
                            ),
                            Gap.w4,
                            Text(
                              context.l10n.lbl_you,
                              style: BaseTypography.labelSmall.copyWith(
                                color: BaseColor.blue[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                if (positions.isNotEmpty) ...[
                  Gap.h4,
                  Wrap(
                    spacing: BaseSize.w4,
                    runSpacing: BaseSize.h4,
                    children: positions
                        .map(
                          (p) => Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: BaseSize.w6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isSupervisorApprover
                                  ? BaseColor.blue[100]
                                  : BaseColor.neutral[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              p.name,
                              style: BaseTypography.labelSmall.copyWith(
                                color: isSupervisorApprover
                                    ? BaseColor.blue[700]
                                    : BaseColor.neutral[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                Gap.h4,
                Row(
                  children: [
                    Icon(statusIcon, size: BaseSize.w14, color: statusColor),
                    Gap.w4,
                    Text(
                      _getApprovalStatusTextLocalized(context, approver.status),
                      style: BaseTypography.labelSmall.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (approver.updatedAt != null) ...[
                  Gap.h4,
                  Text(
                    '${approver.updatedAt!.ddMmmmYyyy} • ${approver.updatedAt!.HHmm}',
                    style: BaseTypography.labelSmall.copyWith(
                      color: BaseColor.neutral[500],
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

  Color _getApprovalStatusColor(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.approved:
        return BaseColor.green[600]!;
      case ApprovalStatus.rejected:
        return BaseColor.red[600]!;
      case ApprovalStatus.unconfirmed:
        return BaseColor.yellow[700]!;
    }
  }

  IconData _getApprovalStatusIcon(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.approved:
        return AppIcons.successSolid;
      case ApprovalStatus.rejected:
        return AppIcons.cancel;
      case ApprovalStatus.unconfirmed:
        return AppIcons.schedule;
    }
  }

  String _getApprovalStatusTextLocalized(
    BuildContext context,
    ApprovalStatus status,
  ) {
    final l10n = context.l10n;
    switch (status) {
      case ApprovalStatus.approved:
        return l10n.status_approved;
      case ApprovalStatus.rejected:
        return l10n.status_rejected;
      case ApprovalStatus.unconfirmed:
        return l10n.status_pending;
    }
  }
}

class _TypeConfig {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;

  _TypeConfig({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
  });
}
