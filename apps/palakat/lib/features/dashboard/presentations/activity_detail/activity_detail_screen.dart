import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/dashboard/presentations/activity_detail/activity_detail_controller.dart';
import 'package:palakat/features/dashboard/presentations/activity_detail/activity_detail_state.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;
import 'package:palakat_shared/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class ActivityDetailScreen extends ConsumerWidget {
  const ActivityDetailScreen({super.key, required this.activityId});

  final int activityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activityDetailControllerProvider(activityId));

    if (state.isLoading) {
      return ScaffoldWidget(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScreenTitleWidget.primary(
                title: 'Memuat...',
                leadIcon: Assets.icons.line.chevronBackOutline,
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
                Icon(Icons.error_outline, size: 48, color: BaseColor.red),
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
                  child: const Text('Coba Lagi'),
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
            'Aktivitas tidak ditemukan',
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
    final showSelfApprovalButtons = state.isSupervisorApprovalPending;

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
              leadIcon: Assets.icons.line.chevronBackOutline,
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
                  _buildBasicInfoSection(activity),
                  if (activity.note != null && activity.note!.isNotEmpty) ...[
                    Gap.h16,
                    _buildNoteSection(activity),
                  ],
                  Gap.h16,
                  _buildScheduleSection(activity),
                  if (activity.location != null) ...[
                    Gap.h16,
                    _buildLocationSection(activity),
                  ],
                  if (activity.financeType != null) ...[
                    Gap.h16,
                    _buildFinanceSection(context, activity),
                  ],
                  if (activity.approvers.isNotEmpty) ...[
                    Gap.h16,
                    _buildApproversSection(activity, state),
                  ],
                  Gap.h16,
                  _buildSupervisorSection(activity),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        vertical: BaseSize.h12,
        horizontal: BaseSize.w12,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Self-approval indicator badge
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: BaseSize.w12,
                vertical: BaseSize.h6,
              ),
              margin: EdgeInsets.only(bottom: BaseSize.h8),
              decoration: BoxDecoration(
                color: BaseColor.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: BaseColor.blue[200]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_pin_outlined,
                    size: BaseSize.w16,
                    color: BaseColor.blue[700],
                  ),
                  Gap.w6,
                  Text(
                    'Anda juga sebagai approver',
                    style: BaseTypography.labelMedium.copyWith(
                      color: BaseColor.blue[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: _buildRejectButton(context, controller, isLoading),
                ),
                Gap.w12,
                Expanded(
                  child: _buildApproveButton(context, controller, isLoading),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the reject button for self-approval.
  Widget _buildRejectButton(
    BuildContext context,
    ActivityDetailController controller,
    bool isLoading,
  ) {
    return OutlinedButton.icon(
      onPressed: isLoading
          ? null
          : () async {
              final confirmed = await _showConfirmationDialog(
                context,
                title: 'Tolak Aktivitas?',
                message: 'Apakah Anda yakin ingin menolak aktivitas ini?',
                confirmText: 'Tolak',
                isDestructive: true,
              );
              if (confirmed == true) {
                final success = await controller.rejectSelfApproval();
                if (context.mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Aktivitas berhasil ditolak'),
                      backgroundColor: BaseColor.red[600],
                    ),
                  );
                }
              }
            },
      icon: isLoading
          ? SizedBox(
              width: BaseSize.w16,
              height: BaseSize.w16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: BaseColor.red[500],
              ),
            )
          : Icon(Icons.close, size: BaseSize.w18, color: BaseColor.red[500]),
      label: Text(
        'Tolak',
        style: BaseTypography.titleMedium.copyWith(
          color: isLoading ? BaseColor.neutral[400] : BaseColor.red[500],
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: BaseColor.red[500],
        side: BorderSide(
          color: isLoading ? BaseColor.neutral[300]! : BaseColor.red[500]!,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: BaseSize.w16,
          vertical: BaseSize.h12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Builds the approve button for self-approval.
  Widget _buildApproveButton(
    BuildContext context,
    ActivityDetailController controller,
    bool isLoading,
  ) {
    return ElevatedButton.icon(
      onPressed: isLoading
          ? null
          : () async {
              final confirmed = await _showConfirmationDialog(
                context,
                title: 'Setujui Aktivitas?',
                message: 'Apakah Anda yakin ingin menyetujui aktivitas ini?',
                confirmText: 'Setujui',
                isDestructive: false,
              );
              if (confirmed == true) {
                final success = await controller.approveSelfApproval();
                if (context.mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Aktivitas berhasil disetujui'),
                      backgroundColor: BaseColor.green[600],
                    ),
                  );
                }
              }
            },
      icon: isLoading
          ? SizedBox(
              width: BaseSize.w16,
              height: BaseSize.w16,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(Icons.check, size: BaseSize.w18, color: Colors.white),
      label: Text(
        'Setujui',
        style: BaseTypography.titleMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isLoading
            ? BaseColor.neutral[300]
            : BaseColor.green[600],
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: BaseSize.w16,
          vertical: BaseSize.h12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    );
  }

  /// Shows a confirmation dialog for approval actions.
  Future<bool?> _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    required bool isDestructive,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Batal',
              style: TextStyle(color: BaseColor.neutral[600]),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              confirmText,
              style: TextStyle(
                color: isDestructive
                    ? BaseColor.red[600]
                    : BaseColor.green[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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
          icon: Icons.church_outlined,
          label: 'Ibadah',
          backgroundColor: BaseColor.primary[50]!,
          borderColor: BaseColor.primary[200]!,
          iconColor: BaseColor.primary[700]!,
          textColor: BaseColor.primary[700]!,
        );
      case ActivityType.event:
        return _TypeConfig(
          icon: Icons.event_outlined,
          label: 'Kegiatan',
          backgroundColor: BaseColor.blue[50]!,
          borderColor: BaseColor.blue[200]!,
          iconColor: BaseColor.blue[700]!,
          textColor: BaseColor.blue[700]!,
        );
      case ActivityType.announcement:
        return _TypeConfig(
          icon: Icons.campaign_outlined,
          label: 'Pengumuman',
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

  Widget _buildSupervisorSection(Activity activity) {
    final supervisor = activity.supervisor;
    final positions = supervisor.membershipPositions;
    return _buildSectionCard(
      title: 'Penanggung Jawab',
      icon: Icons.person_outline,
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
                supervisor.account?.name ?? 'Tidak diketahui',
                style: BaseTypography.titleMedium.copyWith(
                  color: BaseColor.teal[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (supervisor.account?.phone != null) ...[
                Gap.h4,
                Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
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

  Widget _buildBasicInfoSection(Activity activity) {
    final hasBipra = activity.bipra != null;
    final hasDescription =
        activity.description != null && activity.description!.isNotEmpty;

    if (!hasBipra && !hasDescription) {
      return const SizedBox.shrink();
    }

    return _buildSectionCard(
      title: activity.title,
      icon: Icons.info_outline,
      subtitle: 'Detail kegiatan',
      children: [
        if (hasBipra) _buildBipraInfo(activity),
        if (hasBipra && hasDescription) Gap.h12,
        if (hasDescription)
          Text(
            activity.description!,
            style: BaseTypography.bodyMedium.copyWith(
              color: BaseColor.textPrimary,
              height: 1.5,
            ),
          ),
      ],
    );
  }

  Widget _buildBipraInfo(Activity activity) {
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
                  'Target Audience',
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

  Widget _buildScheduleSection(Activity activity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDateTimeCard(activity),
        if (activity.reminder != null) ...[
          Gap.h12,
          _buildReminderInfo(activity),
        ],
      ],
    );
  }

  Widget _buildDateTimeCard(Activity activity) {
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
              icon: Icons.calendar_today,
              label: 'Tanggal',
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
              icon: Icons.access_time,
              label: 'Waktu',
              value: activity.date.HHmm,
              subValue: _getTimePeriod(activity.date),
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

  String _getTimePeriod(DateTime date) {
    if (date.hour < 12) return 'Pagi';
    if (date.hour < 17) return 'Siang';
    return 'Malam';
  }

  Widget _buildReminderInfo(Activity activity) {
    final reminder = activity.reminder!;
    final reminderDate = _calculateReminderDate(activity);

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
            child: Icon(
              Icons.notifications_active_outlined,
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
                  'Pengingat',
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
                  'Akan diingatkan pada $reminderDate',
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

  String _calculateReminderDate(Activity activity) {
    final reminder = activity.reminder!;
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

  Widget _buildLocationSection(Activity activity) {
    final location = activity.location!;
    return GestureDetector(
      onTap: () => _openGoogleMaps(location.latitude, location.longitude),
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
              child: Icon(
                Icons.location_on,
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
                    location.name,
                    style: BaseTypography.bodyMedium.copyWith(
                      color: BaseColor.primary[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Gap.h4,
                  Row(
                    children: [
                      Icon(
                        Icons.my_location,
                        size: BaseSize.w12,
                        color: BaseColor.primary[500],
                      ),
                      Gap.w4,
                      Expanded(
                        child: Text(
                          '${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}',
                          style: BaseTypography.bodySmall.copyWith(
                            color: BaseColor.primary[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_new,
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

  Widget _buildFinanceSection(BuildContext context, Activity activity) {
    final financeType = activity.financeType!;
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
                Icon(
                  Icons.account_balance_outlined,
                  size: BaseSize.w16,
                  color: color[600],
                ),
                Gap.w8,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nomor Akun',
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

  Widget _buildNoteSection(Activity activity) {
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
                  child: Icon(
                    Icons.sticky_note_2_outlined,
                    size: BaseSize.w16,
                    color: BaseColor.yellow[700],
                  ),
                ),
                Gap.w8,
                Text(
                  'Catatan',
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
              activity.note!,
              style: BaseTypography.bodyMedium.copyWith(
                color: BaseColor.yellow[900],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the approvers section with visual indicator for self-approval.
  /// Requirements: 8.5
  Widget _buildApproversSection(Activity activity, ActivityDetailState state) {
    final supervisorApproverRecord = state.supervisorApproverRecord;

    return _buildSectionCard(
      title: 'Status Persetujuan',
      icon: Icons.how_to_reg_outlined,
      subtitle: '${activity.approvers.length} approver(s)',
      iconBgColor: BaseColor.green[50],
      iconColor: BaseColor.green[600],
      children: activity.approvers
          .map(
            (approver) => Padding(
              padding: EdgeInsets.only(bottom: BaseSize.h8),
              child: _buildApproverItem(
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
                        approver.membership?.account?.name ?? 'Tidak diketahui',
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
                            Icon(
                              Icons.person_pin_outlined,
                              size: BaseSize.w12,
                              color: BaseColor.blue[700],
                            ),
                            Gap.w4,
                            Text(
                              'Anda',
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
                      _getApprovalStatusText(approver.status),
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
        return Icons.check_circle;
      case ApprovalStatus.rejected:
        return Icons.cancel;
      case ApprovalStatus.unconfirmed:
        return Icons.schedule;
    }
  }

  String _getApprovalStatusText(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.approved:
        return 'Disetujui';
      case ApprovalStatus.rejected:
        return 'Ditolak';
      case ApprovalStatus.unconfirmed:
        return 'Menunggu';
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
