import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/settings/presentations/settings_controller.dart';
import 'package:palakat/features/settings/presentations/settings_motion_widget.dart';
import 'package:palakat/features/settings/presentations/widgets/widgets.dart';
import 'package:palakat_shared/widgets.dart';
import 'package:palakat_shared/core/extension/extension.dart';

/// Settings screen displaying configurable app settings and user preferences.
///
/// This screen provides access to:
/// - Account settings
/// - Membership settings
/// - Language settings
/// - Sign out functionality
/// - App version information
///
/// Requirements: 7.1, 7.3
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(settingsControllerProvider);
    final hasMembership = state.membership != null;

    return ScaffoldWidget(
      loading: state.isSigningOut,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsReveal(
            child: ScreenTitleWidget.primary(
              title: l10n.settings_title,
              leadIcon: AppIcons.back,
              leadIconColor: AppColors.onSurface,
              onPressedLeadIcon: () => context.pop(),
            ),
          ),
          Gap.h16,
          SettingsAnimatedPresence(
            visible: state.errorMessage != null,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.0),
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: AppColors.error.shade50,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: AppColors.error.shade200),
                  ),
                  child: Row(
                    children: [
                      FaIcon(
                        AppIcons.warning,
                        size: 16.0,
                        color: AppColors.error.shade700,
                      ),
                      Gap.w8,
                      Expanded(
                        child: Text(
                          state.errorMessage ?? '',
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: AppColors.error.shade700,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => ref
                            .read(settingsControllerProvider.notifier)
                            .clearError(),
                        child: FaIcon(
                          AppIcons.close,
                          size: 16.0,
                          color: AppColors.error.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Gap.h16,
              ],
            ),
          ),
          SettingsReveal(
            delay: const Duration(milliseconds: 40),
            child: Material(
              color: AppColors.surfaceContainerLowest,
              elevation: 1,
              shadowColor: AppColors.primary.withValues(alpha: 0.05),
              surfaceTintColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                children: [
                  SettingsReveal(
                    delay: const Duration(milliseconds: 80),
                    child: _SettingsMenuItem(
                      icon: AppIcons.person,
                      iconBackgroundColor: AppColors.primary.shade100,
                      iconColor: AppColors.primary.shade700,
                      title: l10n.settings_accountSettings,
                      grouped: true,
                      onTap: () {
                        final accountId = state.account?.id;
                        if (accountId != null) {
                          context.pushNamed(
                            AppRoute.account,
                            extra: {'accountId': accountId},
                          );
                        }
                      },
                    ),
                  ),
                  Divider(height: 1, color: AppColors.neutral),
                  SettingsReveal(
                    delay: const Duration(milliseconds: 120),
                    child: _SettingsMenuItem(
                      icon: AppIcons.group,
                      iconBackgroundColor: hasMembership
                          ? AppColors.primary.shade100
                          : AppColors.surfaceContainerHigh,
                      iconColor: hasMembership
                          ? AppColors.primary.shade700
                          : AppColors.onSurfaceVariant,
                      title: l10n.settings_membershipSettings,
                      subtitle: hasMembership
                          ? null
                          : l10n.settings_noMembership,
                      enabled: hasMembership,
                      grouped: true,
                      onTap: hasMembership
                          ? () {
                              final membershipId = state.membership?.id;
                              if (membershipId != null) {
                                context.pushNamed(
                                  AppRoute.membership,
                                  extra: {'membershipId': membershipId},
                                );
                              }
                            }
                          : null,
                    ),
                  ),
                  Divider(height: 1, color: AppColors.neutral),
                  SettingsReveal(
                    delay: const Duration(milliseconds: 160),
                    child: _SettingsMenuItem(
                      icon: AppIcons.notificationActive,
                      iconBackgroundColor: hasMembership
                          ? AppColors.warning.shade100
                          : AppColors.surfaceContainerHigh,
                      iconColor: hasMembership
                          ? AppColors.warning.shade700
                          : AppColors.onSurfaceVariant,
                      title: l10n.dashboard_alarmSettings_tooltip,
                      subtitle: hasMembership
                          ? null
                          : l10n.settings_noMembership,
                      enabled: hasMembership,
                      grouped: true,
                      onTap: hasMembership
                          ? () {
                              context.pushNamed(AppRoute.alarmSettings);
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Gap.h12,
          SettingsReveal(
            delay: const Duration(milliseconds: 100),
            child: _SettingsCard(
              icon: FontAwesomeIcons.language,
              iconBackgroundColor: AppColors.primary.shade100,
              iconColor: AppColors.primary.shade700,
              title: l10n.card_languageSettings_title,
              child: const LanguageSelector(),
            ),
          ),
          Gap.h16,
          SettingsReveal(
            delay: const Duration(milliseconds: 140),
            child: ButtonWidget.outlined(
              text: l10n.btn_signOut,
              textColor: AppColors.error,
              outlineColor: AppColors.error,
              focusColor: AppColors.error,
              overlayColor: AppColors.error,
              onTap: () => showSignOutConfirmationBottomSheet(context, ref),
            ),
          ),
          Gap.h12,
          SettingsReveal(
            delay: const Duration(milliseconds: 180),
            child: Center(
              child: Text(
                _formatVersion(context, state.appVersion, state.buildNumber),
                style: Theme.of(context).textTheme.bodyMedium!.toSecondary,
              ),
            ),
          ),
          Gap.h24,
        ],
      ),
    );
  }

  /// Formats version string as "Version X.Y.Z (Build N)"
  /// Requirements: 6.2
  String _formatVersion(
    BuildContext context,
    String version,
    String buildNumber,
  ) {
    final l10n = context.l10n;
    if (version.isEmpty && buildNumber.isEmpty) {
      return l10n.settings_versionUnknown;
    }
    if (buildNumber.isEmpty) {
      return l10n.settings_version(version);
    }
    return l10n.settings_versionWithBuild(version, buildNumber);
  }
}

/// A menu item card for settings options.
///
/// Displays an icon, title, optional subtitle, and forward arrow.
class _SettingsMenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool enabled;
  final bool grouped;
  final VoidCallback? onTap;

  const _SettingsMenuItem({
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.enabled = true,
    this.grouped = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: FaIcon(icon, size: 18.0, color: iconColor),
            ),
            Gap.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: enabled ? AppColors.primary : AppColors.tertiary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    Gap.h4,
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColors.tertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (enabled)
              FaIcon(
                AppIcons.arrowForward,
                size: 16.0,
                color: AppColors.tertiary,
              ),
          ],
        ),
      ),
    );

    if (grouped) {
      return content;
    }

    return Material(
      color: enabled ? AppColors.surfaceContainerLowest : AppColors.tertiary,
      elevation: enabled ? 1 : 0,
      shadowColor: AppColors.primary.withValues(alpha: 0.05),
      surfaceTintColor: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: content,
    );
  }
}

/// A card for settings sections with custom content.
///
/// Used for sections like Language that have custom widgets.
class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final String title;
  final Widget child;

  const _SettingsCard({
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      elevation: 1,
      shadowColor: AppColors.primary.withValues(alpha: 0.05),
      surfaceTintColor: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: FaIcon(icon, size: 18.0, color: iconColor),
                ),
                Gap.w12,
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            Gap.h16,
            child,
          ],
        ),
      ),
    );
  }
}
