import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/services/permission_manager_service_provider.dart';
import 'package:palakat_shared/core/models/permission_state.dart';

import 'permission_rationale_bottom_sheet.dart';

/// Banner widget that prompts users to enable notification permissions
///
/// Shows when permission is denied and hides when granted.
/// Provides "Enable Notifications" button and dismiss functionality.
///
/// Requirements: 6.2, 6.3
class NotificationPermissionBanner extends ConsumerStatefulWidget {
  const NotificationPermissionBanner({super.key});

  @override
  ConsumerState<NotificationPermissionBanner> createState() =>
      _NotificationPermissionBannerState();
}

class _NotificationPermissionBannerState
    extends ConsumerState<NotificationPermissionBanner> {
  bool _isDismissed = false;

  @override
  Widget build(BuildContext context) {
    final permissionStateAsync = ref.watch(permissionStateProvider);

    return permissionStateAsync.when(
      data: (permissionState) {
        // Hide banner if permission is granted or user dismissed it
        if (permissionState.status == PermissionStatus.granted ||
            _isDismissed) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: BaseSize.w16,
            vertical: BaseSize.h12,
          ),
          padding: EdgeInsets.all(BaseSize.w16),
          decoration: BoxDecoration(
            color: BaseColor.primary3.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(BaseSize.radiusMd),
            border: Border.all(
              color: BaseColor.primary3.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: BaseSize.w40,
                height: BaseSize.w40,
                decoration: BoxDecoration(
                  color: BaseColor.primary3.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                ),
                alignment: Alignment.center,
                child: FaIcon(
                  FontAwesomeIcons.bell,
                  size: BaseSize.w20,
                  color: BaseColor.primary3,
                ),
              ),
              Gap.w12,
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Enable Notifications',
                      style: BaseTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: BaseColor.primaryText,
                      ),
                    ),
                    Gap.h4,
                    Text(
                      'Stay updated with activities and approvals',
                      style: BaseTypography.bodySmall.copyWith(
                        color: BaseColor.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Gap.w12,
              // Enable button
              ElevatedButton(
                onPressed: () => _handleEnableNotifications(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BaseColor.primary3,
                  foregroundColor: BaseColor.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: BaseSize.w16,
                    vertical: BaseSize.h8,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                  ),
                ),
                child: Text(
                  'Enable',
                  style: BaseTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: BaseColor.white,
                  ),
                ),
              ),
              Gap.w8,
              // Dismiss button
              IconButton(
                onPressed: _handleDismiss,
                icon: FaIcon(
                  FontAwesomeIcons.xmark,
                  size: BaseSize.w16,
                  color: BaseColor.secondaryText,
                ),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(
                  minWidth: BaseSize.w32,
                  minHeight: BaseSize.w32,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Future<void> _handleEnableNotifications(BuildContext context) async {
    // Show permission rationale bottom sheet
    final result = await showPermissionRationaleBottomSheet(context: context);

    if (result == true && mounted) {
      // User tapped "Allow Notifications"
      await ref
          .read(permissionStateProvider.notifier)
          .requestPermissions(context);
    }
  }

  void _handleDismiss() {
    setState(() {
      _isDismissed = true;
    });
  }
}
