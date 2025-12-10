import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/services/permission_manager_service_provider.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/notification/presentations/notification_settings_controller.dart';
import 'package:palakat/features/notification/presentations/widgets/notification_permission_banner.dart';
import 'package:palakat_shared/core/models/notification_settings.dart';
import 'package:palakat_shared/core/models/permission_state.dart';
import 'package:palakat_shared/widgets.dart';

/// Notification settings screen
///
/// Displays notification permission status and allows users to configure
/// notification preferences including channel toggles and sound/vibration settings.
///
/// Requirements: 6.2, 6.3, 9.5
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(notificationSettingsControllerProvider);
    final permissionStateAsync = ref.watch(permissionStateProvider);

    return ScaffoldWidget(
      loading: settingsAsync.isLoading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenTitleWidget.primary(
            title: "Notification Settings",
            leadIcon: AppIcons.back,
            leadIconColor: BaseColor.black,
            onPressedLeadIcon: () => context.pop(),
          ),
          Gap.h16,
          // Permission status banner
          const NotificationPermissionBanner(),
          Gap.h16,
          // Permission status section
          _buildPermissionStatusSection(context, ref, permissionStateAsync),
          Gap.h16,
          // Notification preferences section
          settingsAsync.when(
            data: (settings) =>
                _buildPreferencesSection(context, ref, settings),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text(
                'Error loading settings: $error',
                style: BaseTypography.bodyMedium.toSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionStatusSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<PermissionStateModel> permissionStateAsync,
  ) {
    return Material(
      color: BaseColor.cardBackground1,
      elevation: 1,
      shadowColor: BaseColor.black.withValues(alpha: 0.05),
      surfaceTintColor: BaseColor.primary[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(BaseSize.w16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: BaseSize.w32,
                  height: BaseSize.w32,
                  decoration: BoxDecoration(
                    color: BaseColor.primary[100],
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: FaIcon(
                    FontAwesomeIcons.bell,
                    size: BaseSize.w16,
                    color: BaseColor.primary[700],
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: Text(
                    "Permission Status",
                    style: BaseTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: BaseColor.black,
                    ),
                  ),
                ),
              ],
            ),
            Gap.h16,
            permissionStateAsync.when(
              data: (permissionState) {
                final isGranted =
                    permissionState.status == PermissionStatus.granted;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: BaseSize.w12,
                          height: BaseSize.w12,
                          decoration: BoxDecoration(
                            color: isGranted
                                ? BaseColor.green[500]
                                : BaseColor.red[500],
                            shape: BoxShape.circle,
                          ),
                        ),
                        Gap.w8,
                        Text(
                          isGranted ? "Enabled" : "Disabled",
                          style: BaseTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: BaseColor.black,
                          ),
                        ),
                      ],
                    ),
                    Gap.h8,
                    Text(
                      isGranted
                          ? "You will receive notifications for activities, approvals, and announcements."
                          : "Enable notifications to stay updated on activities, approvals, and important announcements.",
                      style: BaseTypography.bodySmall.toSecondary,
                    ),
                    if (!isGranted) ...[
                      Gap.h16,
                      ButtonWidget.primary(
                        text: "Enable Notifications",
                        onTap: () async {
                          final controller = ref.read(
                            permissionStateProvider.notifier,
                          );
                          await controller.requestPermissions(context);
                        },
                      ),
                    ],
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text(
                'Error loading permission status',
                style: BaseTypography.bodySmall.toSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection(
    BuildContext context,
    WidgetRef ref,
    NotificationSettingsModel settings,
  ) {
    final controller = ref.read(
      notificationSettingsControllerProvider.notifier,
    );

    return Material(
      color: BaseColor.cardBackground1,
      elevation: 1,
      shadowColor: BaseColor.black.withValues(alpha: 0.05),
      surfaceTintColor: BaseColor.primary[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(BaseSize.w16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: BaseSize.w32,
                  height: BaseSize.w32,
                  decoration: BoxDecoration(
                    color: BaseColor.primary[100],
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: FaIcon(
                    FontAwesomeIcons.sliders,
                    size: BaseSize.w16,
                    color: BaseColor.primary[700],
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: Text(
                    "Notification Preferences",
                    style: BaseTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: BaseColor.black,
                    ),
                  ),
                ),
              ],
            ),
            Gap.h16,
            Text(
              "Choose which types of notifications you want to receive",
              style: BaseTypography.bodySmall.toSecondary,
            ),
            Gap.h16,
            // Channel preferences
            _buildToggleTile(
              title: "Activity Updates",
              subtitle: "Notifications about church activities and events",
              value: settings.activityUpdatesEnabled,
              onChanged: (value) => controller.updateActivityUpdates(value),
            ),
            Gap.h12,
            _buildToggleTile(
              title: "Approval Requests",
              subtitle: "Notifications requiring your approval",
              value: settings.approvalRequestsEnabled,
              onChanged: (value) => controller.updateApprovalRequests(value),
            ),
            Gap.h12,
            _buildToggleTile(
              title: "General Announcements",
              subtitle: "General church announcements and updates",
              value: settings.generalAnnouncementsEnabled,
              onChanged: (value) =>
                  controller.updateGeneralAnnouncements(value),
            ),
            Gap.h16,
            Divider(color: BaseColor.neutral30),
            Gap.h16,
            Text(
              "Sound & Vibration",
              style: BaseTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: BaseColor.black,
              ),
            ),
            Gap.h12,
            _buildToggleTile(
              title: "Sound",
              subtitle: "Play sound when notifications arrive",
              value: settings.soundEnabled,
              onChanged: (value) => controller.updateSound(value),
            ),
            Gap.h12,
            _buildToggleTile(
              title: "Vibration",
              subtitle: "Vibrate when notifications arrive",
              value: settings.vibrationEnabled,
              onChanged: (value) => controller.updateVibration(value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Material(
      color: BaseColor.primary[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: BaseColor.primary[200] ?? BaseColor.neutral40),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(
          title,
          style: BaseTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: BaseColor.black,
          ),
        ),
        subtitle: Text(subtitle, style: BaseTypography.bodySmall.toSecondary),
        activeColor: BaseColor.primary[700],
        contentPadding: EdgeInsets.symmetric(
          horizontal: BaseSize.w16,
          vertical: BaseSize.h8,
        ),
      ),
    );
  }
}
