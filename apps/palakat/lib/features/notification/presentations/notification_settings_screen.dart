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
import 'package:palakat_shared/core/extension/extension.dart';

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
    final l10n = context.l10n;
    final settingsAsync = ref.watch(notificationSettingsControllerProvider);
    final permissionStateAsync = ref.watch(permissionStateProvider);

    return ScaffoldWidget(
      loading: settingsAsync.isLoading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenTitleWidget.primary(
            title: l10n.notificationSettings_title,
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
                l10n.notificationSettings_errorLoadingSettings(
                  error.toString(),
                ),
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
    final l10n = context.l10n;
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
                    l10n.notificationSettings_permissionStatus_title,
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
                          isGranted
                              ? l10n.notificationSettings_permissionEnabled
                              : l10n.notificationSettings_permissionDisabled,
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
                          ? l10n.notificationSettings_permissionEnabledDesc
                          : l10n.notificationSettings_permissionDisabledDesc,
                      style: BaseTypography.bodySmall.toSecondary,
                    ),
                    if (!isGranted) ...[
                      Gap.h16,
                      ButtonWidget.primary(
                        text: l10n.notificationSettings_enableNotifications,
                        onTap: () async {
                          final controller = ref.read(
                            permissionStateProvider.notifier,
                          );
                          await controller.requestPermissions();
                        },
                      ),
                    ],
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text(
                l10n.notificationSettings_errorLoadingPermissionStatus,
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
    final l10n = context.l10n;
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
                    l10n.notificationSettings_preferences_title,
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
              l10n.notificationSettings_preferences_subtitle,
              style: BaseTypography.bodySmall.toSecondary,
            ),
            Gap.h16,
            // Channel preferences
            _buildToggleTile(
              title: l10n.notificationSettings_channel_activityUpdates_title,
              subtitle:
                  l10n.notificationSettings_channel_activityUpdates_subtitle,
              value: settings.activityUpdatesEnabled,
              onChanged: (value) => controller.updateActivityUpdates(value),
            ),
            Gap.h12,
            _buildToggleTile(
              title: l10n.notificationSettings_channel_approvalRequests_title,
              subtitle:
                  l10n.notificationSettings_channel_approvalRequests_subtitle,
              value: settings.approvalRequestsEnabled,
              onChanged: (value) => controller.updateApprovalRequests(value),
            ),
            Gap.h12,
            _buildToggleTile(
              title:
                  l10n.notificationSettings_channel_generalAnnouncements_title,
              subtitle: l10n
                  .notificationSettings_channel_generalAnnouncements_subtitle,
              value: settings.generalAnnouncementsEnabled,
              onChanged: (value) =>
                  controller.updateGeneralAnnouncements(value),
            ),
            Gap.h12,
            _buildToggleTile(
              title:
                  l10n.notificationSettings_channel_birthdayNotifications_title,
              subtitle: l10n
                  .notificationSettings_channel_birthdayNotifications_subtitle,
              value: settings.birthdayNotificationsEnabled,
              onChanged: (value) =>
                  controller.updateBirthdayNotifications(value),
            ),
            Gap.h16,
            Divider(color: BaseColor.neutral30),
            Gap.h16,
            Text(
              l10n.notificationSettings_soundVibration_title,
              style: BaseTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: BaseColor.black,
              ),
            ),
            Gap.h12,
            _buildToggleTile(
              title: l10n.notificationSettings_sound_title,
              subtitle: l10n.notificationSettings_sound_subtitle,
              value: settings.soundEnabled,
              onChanged: (value) => controller.updateSound(value),
            ),
            Gap.h12,
            _buildToggleTile(
              title: l10n.notificationSettings_vibration_title,
              subtitle: l10n.notificationSettings_vibration_subtitle,
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
