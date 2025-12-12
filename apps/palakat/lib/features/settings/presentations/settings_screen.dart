import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/settings/presentations/settings_controller.dart';
import 'package:palakat/features/settings/presentations/widgets/widgets.dart';
import 'package:palakat_shared/widgets.dart';

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
    final state = ref.watch(settingsControllerProvider);
    final hasMembership = state.membership != null;

    return ScaffoldWidget(
      loading: state.isSigningOut,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenTitleWidget.primary(
            title: "Settings",
            leadIcon: AppIcons.back,
            leadIconColor: BaseColor.black,
            onPressedLeadIcon: () => context.pop(),
          ),
          Gap.h16,
          // Error message display - Requirements: 5.3
          if (state.errorMessage != null) ...[
            Container(
              margin: EdgeInsets.symmetric(horizontal: BaseSize.w16),
              padding: EdgeInsets.all(BaseSize.w12),
              decoration: BoxDecoration(
                color: BaseColor.red[50],
                borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                border: Border.all(color: BaseColor.red[200]!),
              ),
              child: Row(
                children: [
                  FaIcon(
                    AppIcons.warning,
                    size: BaseSize.w16,
                    color: BaseColor.red[700],
                  ),
                  Gap.w8,
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                      style: BaseTypography.bodySmall.copyWith(
                        color: BaseColor.red[700],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => ref
                        .read(settingsControllerProvider.notifier)
                        .clearError(),
                    child: FaIcon(
                      AppIcons.close,
                      size: BaseSize.w16,
                      color: BaseColor.red[700],
                    ),
                  ),
                ],
              ),
            ),
            Gap.h16,
          ],
          // Account Settings - Requirements: 2.1, 2.2, 2.3
          _SettingsMenuItem(
            icon: AppIcons.person,
            iconBackgroundColor: BaseColor.primary[100]!,
            iconColor: BaseColor.primary[700]!,
            title: "Account Settings",
            onTap: () {
              // Navigate to AccountScreen with accountId - Requirements: 2.2, 2.3
              final accountId = state.account?.id;
              if (accountId != null) {
                context.pushNamed(
                  AppRoute.account,
                  extra: {'accountId': accountId},
                );
              }
            },
          ),
          Gap.h12,
          // Membership Settings - Requirements: 3.1, 3.2, 3.3
          _SettingsMenuItem(
            icon: AppIcons.group,
            iconBackgroundColor: hasMembership
                ? BaseColor.primary[100]!
                : BaseColor.neutral20,
            iconColor: hasMembership
                ? BaseColor.primary[700]!
                : BaseColor.neutral50,
            title: "Membership Settings",
            subtitle: hasMembership ? null : "No membership found",
            enabled: hasMembership,
            onTap: hasMembership
                ? () {
                    // Navigate to MembershipScreen with membershipId - Requirements: 3.2
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
          Gap.h12,
          // Language Settings - Requirements: 4.1
          _SettingsCard(
            icon: FontAwesomeIcons.language,
            iconBackgroundColor: BaseColor.primary[100]!,
            iconColor: BaseColor.primary[700]!,
            title: "Language",
            child: const LanguageSelector(),
          ),
          Gap.h32,
          // Sign Out Button - Requirements: 5.1
          ButtonWidget.primary(
            text: "Sign Out",
            color: BaseColor.red[600] ?? BaseColor.red,
            onTap: () => showSignOutConfirmationBottomSheet(context, ref),
          ),
          Gap.h16,
          // Version Info - Requirements: 6.1, 6.2
          Center(
            child: Text(
              _formatVersion(state.appVersion, state.buildNumber),
              style: BaseTypography.bodySmall.toSecondary,
            ),
          ),
          Gap.h24,
        ],
      ),
    );
  }

  /// Formats version string as "Version X.Y.Z (Build N)"
  /// Requirements: 6.2
  String _formatVersion(String version, String buildNumber) {
    if (version.isEmpty && buildNumber.isEmpty) {
      return "Version unknown";
    }
    if (buildNumber.isEmpty) {
      return "Version $version";
    }
    return "Version $version (Build $buildNumber)";
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
  final VoidCallback? onTap;

  const _SettingsMenuItem({
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? BaseColor.cardBackground1 : BaseColor.neutral10,
      elevation: enabled ? 1 : 0,
      shadowColor: BaseColor.black.withValues(alpha: 0.05),
      surfaceTintColor: BaseColor.primary[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w16),
          child: Row(
            children: [
              Container(
                width: BaseSize.w40,
                height: BaseSize.w40,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: FaIcon(icon, size: BaseSize.w18, color: iconColor),
              ),
              Gap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: BaseTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: enabled ? BaseColor.black : BaseColor.neutral50,
                      ),
                    ),
                    if (subtitle != null) ...[
                      Gap.h4,
                      Text(
                        subtitle!,
                        style: BaseTypography.bodySmall.copyWith(
                          color: BaseColor.neutral50,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (enabled)
                FaIcon(
                  AppIcons.arrowForward,
                  size: BaseSize.w16,
                  color: BaseColor.neutral50,
                ),
            ],
          ),
        ),
      ),
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
                  width: BaseSize.w40,
                  height: BaseSize.w40,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: FaIcon(icon, size: BaseSize.w18, color: iconColor),
                ),
                Gap.w12,
                Expanded(
                  child: Text(
                    title,
                    style: BaseTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: BaseColor.black,
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
