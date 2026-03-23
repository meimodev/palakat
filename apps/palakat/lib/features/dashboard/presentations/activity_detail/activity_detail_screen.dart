import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/activity_alarm/presentations/activity_alarm_motion_widget.dart';
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
              ActivityAlarmReveal(
                child: ScreenTitleWidget.primary(
                  title: l10n.loading_activities,
                  leadIcon: AppIcons.back,
                  leadIconColor: AppColors.onSurface,
                  onPressedLeadIcon: context.pop,
                ),
              ),
              Gap.h16,
              ActivityAlarmReveal(
                delay: const Duration(milliseconds: 40),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
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
              ),
            ],
          ),
        ),
      );
    }

    if (state.errorMessage != null) {
      return ScaffoldWidget(
        child: ActivityAlarmAnimatedPresence(
          visible: true,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(AppIcons.error, size: 48, color: AppColors.error),
                  Gap.h16,
                  Text(
                    state.errorMessage!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium!,
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
        ),
      );
    }

    final activity = state.activity;
    if (activity == null) {
      return ScaffoldWidget(
        child: ActivityAlarmAnimatedPresence(
          visible: true,
          child: Center(
            child: Text(
              l10n.msg_activityNotFound,
              style: Theme.of(context).textTheme.bodyMedium!,
            ),
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
          ? ActivityAlarmReveal(
              delay: const Duration(milliseconds: 140),
              child: _buildSelfApprovalButtons(context, ref, state),
            )
          : null,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ActivityAlarmReveal(
              child: ScreenTitleWidget.primary(
                title: activity.activityType.displayName,
                subTitle: activity.title,
                leadIcon: AppIcons.back,
                leadIconColor: AppColors.onSurface,
                onPressedLeadIcon: context.pop,
              ),
            ),
            Gap.h16,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ActivityAlarmReveal(
                    delay: const Duration(milliseconds: 40),
                    child: _buildActivityTypeIndicator(activity, context),
                  ),
                  Gap.h12,
                  ActivityAlarmReveal(
                    delay: const Duration(milliseconds: 60),
                    child: _buildBasicInfoSection(context, ref, activity),
                  ),
                  Gap.h16,
                  ActivityAlarmReveal(
                    delay: const Duration(milliseconds: 80),
                    child: _buildNoteSection(context, activity),
                  ),
                  Gap.h16,
                  ActivityAlarmReveal(
                    delay: const Duration(milliseconds: 100),
                    child: _buildScheduleSection(context, activity),
                  ),
                  Gap.h16,
                  ActivityAlarmReveal(
                    delay: const Duration(milliseconds: 120),
                    child: _buildLocationSection(context, activity),
                  ),
                  Gap.h16,
                  ActivityAlarmReveal(
                    delay: const Duration(milliseconds: 140),
                    child: _buildFinanceSection(context, activity),
                  ),
                  Gap.h16,
                  ActivityAlarmReveal(
                    delay: const Duration(milliseconds: 160),
                    child: _buildApproversSection(context, activity, state),
                  ),
                  Gap.h16,
                  ActivityAlarmReveal(
                    delay: const Duration(milliseconds: 180),
                    child: _buildSupervisorSection(context, activity),
                  ),
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
        color: AppColors.surfaceContainerLowest,
        border: Border(
          top: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
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
      context: context,
      text: context.l10n.btn_reject,
      icon: AppIcons.close,
      color: AppColors.error.shade500,
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
              backgroundColor: AppColors.error,
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
      color: AppColors.success.shade600,
      isLoading: isLoading,
      context: context,
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
              backgroundColor: AppColors.success,
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
    required BuildContext context,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(8.0),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: isLoading ? null : onTap,
        overlayColor: WidgetStateProperty.all(color.withValues(alpha: 0.12)),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          decoration: BoxDecoration(
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: isLoading
              ? Center(
                  child: CompactLoadingWidget(
                    size: 18.0,
                    baseColor: color.withValues(alpha: 0.24),
                    highlightColor: AppColors.surface,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(icon, size: 18.0, color: color),
                    Gap.w8,
                    Text(
                      text,
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
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

  Widget _buildActivityTypeIndicator(Activity activity, BuildContext context) {
    final typeConfig = _getTypeConfig(activity);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: typeConfig.backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: typeConfig.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(typeConfig.icon, size: 18.0, color: typeConfig.iconColor),
          Gap.w8,
          Text(
            typeConfig.label,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
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
          backgroundColor: AppColors.primary.shade100,
          borderColor: AppColors.primary.shade200,
          iconColor: AppColors.primary.shade700,
          textColor: AppColors.primary.shade700,
        );
      case ActivityType.event:
        return _TypeConfig(
          icon: AppIcons.event,
          label: activity.activityType.displayName,
          backgroundColor: AppColors.primary.shade100,
          borderColor: AppColors.primary.shade200,
          iconColor: AppColors.primary.shade700,
          textColor: AppColors.primary.shade700,
        );
      case ActivityType.announcement:
        return _TypeConfig(
          icon: AppIcons.announcement,
          label: activity.activityType.displayName,
          backgroundColor: AppColors.warning.shade100,
          borderColor: AppColors.warning.shade200,
          iconColor: AppColors.warning.shade700,
          textColor: AppColors.warning.shade700,
        );
    }
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required BuildContext context,
    String? subtitle,
    Color? iconBgColor,
    Color? iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: iconBgColor ?? AppColors.primary,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Icon(
                    icon,
                    size: 16.0,
                    color: iconColor ?? AppColors.onPrimary,
                  ),
                ),
                Gap.w8,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      if (subtitle != null) ...[
                        Gap.h4,
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.0),
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
      context: context,
      icon: AppIcons.person,
      iconBgColor: AppColors.secondaryContainer,
      iconColor: AppColors.onSecondaryContainer,
      children: [
        Container(
          padding: EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer,
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(
              color: AppColors.onSecondaryContainer.withValues(alpha: 0.14),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                supervisor.account?.name ?? context.l10n.lbl_unknown,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: AppColors.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (supervisor.account?.phone != null) ...[
                Gap.h4,
                Row(
                  children: [
                    FaIcon(
                      AppIcons.phone,
                      size: 12.0,
                      color: AppColors.onSecondaryContainer,
                    ),
                    Gap.w4,
                    Text(
                      supervisor.account?.phone ?? '',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColors.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ],
              if (positions.isNotEmpty) ...[
                Gap.h8,
                Wrap(
                  spacing: 6.0,
                  runSpacing: 4.0,
                  children: positions
                      .map(
                        (p) => Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppColors.onSecondaryContainer.withValues(
                                alpha: 0.12,
                              ),
                            ),
                          ),
                          child: Text(
                            p.name,
                            style: Theme.of(context).textTheme.labelMedium!
                                .copyWith(
                                  color: AppColors.onSecondaryContainer,
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
      context: context,
      icon: AppIcons.info,
      subtitle: activity.title,
      children: [
        _buildInfoRow(
          context: context,
          icon: AppIcons.info,
          iconColor: AppColors.primary,
          label: l10n.lbl_activityId,
          value: activityIdText,
        ),
        Gap.h12,
        _buildInfoRow(
          context: context,
          icon: AppIcons.createdAt,
          iconColor: AppColors.neutral,
          label: l10n.lbl_createdAt,
          value: createdAtText,
        ),
        Gap.h12,
        _buildInfoRow(
          context: context,
          icon: AppIcons.schedule,
          iconColor: AppColors.neutral,
          label: l10n.lbl_updatedAt,
          value: updatedAtText,
        ),
        Gap.h12,
        _buildInfoRow(
          context: context,
          icon: AppIcons.document,
          iconColor: AppColors.primary,
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
            context: context,
            icon: AppIcons.info,
            iconColor: AppColors.primary,
            label: l10n.lbl_targetAudience,
            value: l10n.lbl_notSpecified,
          ),
        Gap.h12,
        _buildInfoRow(
          context: context,
          icon: AppIcons.description,
          iconColor: AppColors.secondary,
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
    required BuildContext context,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    final effectiveIconColor = iconColor ?? AppColors.neutral;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(4.0),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32.0,
                height: 32.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: effectiveIconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: FaIcon(icon, size: 16.0, color: effectiveIconColor),
              ),
              Gap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Gap.h4,
                    Text(
                      value,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null) ...[
                Gap.w8,
                Padding(
                  padding: EdgeInsets.only(top: 4.0),
                  child: FaIcon(
                    AppIcons.openExternal,
                    size: 16.0,
                    color: AppColors.onSurfaceVariant,
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
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColors.primary.shade50,
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: AppColors.primary.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.shade700,
                  AppColors.primary.shade800,
                ],
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              bipra.abv,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: AppColors.surfaceContainerLowest,
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
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: AppColors.primary.shade700,
                  ),
                ),
                Gap.h4,
                Text(
                  bipra.name,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.primary.shade700,
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
        ActivityAlarmReveal(child: _buildDateTimeCard(context, activity)),
        Gap.h12,
        ActivityAlarmReveal(
          delay: const Duration(milliseconds: 50),
          child: _buildReminderInfo(context, activity),
        ),
      ],
    );
  }

  Widget _buildDateTimeCard(BuildContext context, Activity activity) {
    return Container(
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary.shade50, AppColors.primary.shade100],
        ),
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: AppColors.primary.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDateTimeItem(
              context: context,
              icon: AppIcons.calendar,
              label: context.l10n.lbl_date,
              value: activity.date.ddMmmmYyyy,
              subValue: activity.date.EEEEddMMMyyyyShort.split(',').first,
              color: AppColors.primary,
            ),
          ),
          Container(width: 1, height: 48.0, color: AppColors.outlineVariant),
          Expanded(
            child: _buildDateTimeItem(
              context: context,
              icon: AppIcons.time,
              label: context.l10n.lbl_time,
              value: activity.date.HHmm,
              subValue: _getTimePeriod(context, activity.date),
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required String subValue,
    required MaterialColor color,
  }) {
    return Column(
      children: [
        Container(
          width: 36.0,
          height: 36.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: color[100], shape: BoxShape.circle),
          child: Icon(icon, size: 18.0, color: color[600]),
        ),
        Gap.h8,
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: color[700],
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        Gap.h4,
        Text(
          subValue,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(color: color[500]),
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
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: FaIcon(
                AppIcons.notificationActive,
                size: 20.0,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Gap.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.lbl_reminder,
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Gap.h4,
                  Text(
                    context.l10n.lbl_na,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColors.onSurfaceVariant,
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
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColors.warning.shade50,
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: AppColors.warning.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: AppColors.warning.shade100,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: FaIcon(
              AppIcons.notificationActive,
              size: 20.0,
              color: AppColors.warning.shade700,
            ),
          ),
          Gap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.lbl_reminder,
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: AppColors.warning.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Gap.h4,
                Text(
                  reminder.name,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.warning.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Gap.h4,
                Text(
                  context.l10n.msg_willBeRemindedAt(reminderDate),
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.warning.shade700,
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
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: AppColors.primary.shade50,
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(color: AppColors.primary.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: AppColors.primary.shade100,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: FaIcon(
                AppIcons.location,
                size: 20.0,
                color: AppColors.primary.shade700,
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
                        ? Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: AppColors.primary.shade700,
                            fontWeight: FontWeight.w600,
                          )
                        : Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                  ),
                  if (hasCoordinates) ...[
                    Gap.h4,
                    Row(
                      children: [
                        FaIcon(
                          AppIcons.coordinates,
                          size: 12.0,
                          color: AppColors.primary.shade700,
                        ),
                        Gap.w4,
                        Expanded(
                          child: Text(
                            '${location!.latitude!.toStringAsFixed(5)}, ${location.longitude!.toStringAsFixed(5)}',
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(color: AppColors.onSurfaceVariant),
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
                size: 18.0,
                color: AppColors.primary.shade700,
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
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Icon(
                AppIcons.wallet,
                size: 20.0,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Gap.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.section_financialRecord,
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Gap.h4,
                  Text(
                    context.l10n.lbl_na,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: AppColors.onSurfaceVariant,
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
    final color = isRevenue ? AppColors.success : AppColors.error;

    final amount = financeData?.amount ?? 0;
    final displayAmount = isRevenue ? amount : -amount;
    final accountNumber =
        financeData?.financialAccountNumber?.accountNumber ??
        financeData?.accountNumber ??
        '-';
    final accountDesc = financeData?.financialAccountNumber?.description;

    return Container(
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: color[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: color[100],
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Icon(financeType.icon, size: 20.0, color: color[600]),
              ),
              Gap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      financeType.displayName,
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: color[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Gap.h4,
                    Text(
                      _formatCurrency(displayAmount),
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
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
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Row(
              children: [
                FaIcon(AppIcons.bankAccount, size: 16.0, color: color[600]),
                Gap.w8,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.lbl_accountNumber,
                        style: Theme.of(context).textTheme.labelMedium!
                            .copyWith(color: AppColors.onSurfaceVariant),
                      ),
                      Text(
                        accountNumber,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: color[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (accountDesc != null && accountDesc.isNotEmpty) ...[
                        Text(
                          accountDesc,
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(color: AppColors.onSurfaceVariant),
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
    final digits = absAmount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return '${isNegative ? '-' : ''}Rp $formatted';
  }

  Widget _buildNoteSection(BuildContext context, Activity activity) {
    final note = activity.note?.trim();
    final hasNote = note != null && note.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.warning.shade50,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: AppColors.warning.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: AppColors.warning.shade100,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: AppColors.warning.shade200,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: FaIcon(
                    AppIcons.notes,
                    size: 16.0,
                    color: AppColors.warning.shade700,
                  ),
                ),
                Gap.w8,
                Text(
                  context.l10n.lbl_note,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.warning.shade700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              hasNote ? note : context.l10n.lbl_na,
              style: hasNote
                  ? Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColors.onSurface,
                      height: 1.5,
                    )
                  : Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColors.onSurfaceVariant,
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
        context: context,
        title: context.l10n.section_approvalStatus,
        icon: AppIcons.verified,
        subtitle: context.l10n.msg_noApproversAssigned,
        iconBgColor: AppColors.success.shade100,
        iconColor: AppColors.success.shade700,
        children: [
          Text(
            context.l10n.msg_noApproversAssigned,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: AppColors.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return _buildSectionCard(
      context: context,
      title: context.l10n.section_approvalStatus,
      icon: AppIcons.verified,
      subtitle: context.l10n.msg_approverCount(activity.approvers.length),
      iconBgColor: AppColors.success.shade100,
      iconColor: AppColors.success.shade700,
      children: activity.approvers
          .map(
            (approver) => Padding(
              padding: EdgeInsets.only(bottom: 8.0),
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
        ? AppColors.primary.shade50
        : statusColor.withValues(alpha: 0.05);
    final borderColor = isSupervisorApprover
        ? AppColors.primary.shade200
        : statusColor.withValues(alpha: 0.2);

    return Container(
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4.0),
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
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: isSupervisorApprover
                              ? AppColors.primary.shade700
                              : AppColors.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    // Visual indicator for supervisor's approver record (Requirements: 8.5)
                    if (isSupervisorApprover) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.shade100,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.primary.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(
                              AppIcons.personPin,
                              size: 12.0,
                              color: AppColors.primary.shade700,
                            ),
                            Gap.w4,
                            Text(
                              context.l10n.lbl_you,
                              style: Theme.of(context).textTheme.labelMedium!
                                  .copyWith(
                                    color: AppColors.primary.shade700,
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
                    spacing: 4.0,
                    runSpacing: 4.0,
                    children: positions
                        .map(
                          (p) => Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.0,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isSupervisorApprover
                                  ? AppColors.primary.shade100
                                  : AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isSupervisorApprover
                                    ? AppColors.primary.shade200
                                    : AppColors.outlineVariant,
                              ),
                            ),
                            child: Text(
                              p.name,
                              style: Theme.of(context).textTheme.labelMedium!
                                  .copyWith(
                                    color: isSupervisorApprover
                                        ? AppColors.primary.shade700
                                        : AppColors.onSurfaceVariant,
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
                    Icon(statusIcon, size: 14.0, color: statusColor),
                    Gap.w4,
                    Text(
                      _getApprovalStatusTextLocalized(context, approver.status),
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
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
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColors.onSurfaceVariant,
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
        return AppColors.success;
      case ApprovalStatus.rejected:
        return AppColors.error;
      case ApprovalStatus.unconfirmed:
        return AppColors.warning;
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
