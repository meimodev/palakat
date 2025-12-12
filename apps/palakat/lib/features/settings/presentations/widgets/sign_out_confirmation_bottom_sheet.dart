import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/features/settings/presentations/settings_controller.dart';
import 'package:palakat_shared/core/extension/build_context_extension.dart';

/// Shows a sign out confirmation bottom sheet.
///
/// Displays a warning icon, title, message, and cancel/confirm buttons.
/// On confirmation, calls the settings controller's signOut method and navigates to home.
///
/// Requirements: 5.2, 5.4
void showSignOutConfirmationBottomSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet<bool>(
    context: context,
    backgroundColor: BaseColor.transparent,
    builder: (dialogContext) => _SignOutConfirmationContent(
      onCancel: () => Navigator.of(dialogContext).pop(),
      onConfirm: () async {
        Navigator.of(dialogContext).pop();
        await ref.read(settingsControllerProvider.notifier).signOut();

        // Navigate to home screen only on successful sign out - Requirements: 5.4
        if (context.mounted) {
          final state = ref.read(settingsControllerProvider);
          if (state.errorMessage == null) {
            context.goNamed(AppRoute.home);
          }
          // If there's an error, stay on settings screen to show error message
        }
      },
    ),
  );
}

/// Content widget for the sign out confirmation bottom sheet.
///
/// Contains warning icon, title, message, and action buttons.
class _SignOutConfirmationContent extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _SignOutConfirmationContent({
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BaseColor.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(BaseSize.radiusLg),
          topRight: Radius.circular(BaseSize.radiusLg),
        ),
      ),
      padding: EdgeInsets.all(BaseSize.w24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: BaseSize.w40,
              height: BaseSize.h4,
              decoration: BoxDecoration(
                color: BaseColor.neutral30,
                borderRadius: BorderRadius.circular(BaseSize.radiusSm),
              ),
            ),
          ),
          Gap.h16,
          // Warning icon
          Center(
            child: Container(
              width: BaseSize.w56,
              height: BaseSize.w56,
              decoration: BoxDecoration(
                color: BaseColor.red[50],
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: FaIcon(
                AppIcons.logout,
                size: BaseSize.w32,
                color: BaseColor.red[700],
              ),
            ),
          ),
          Gap.h16,
          // Title
          Text(
            context.l10n.btn_signOutConfirm,
            style: BaseTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: BaseColor.black,
            ),
            textAlign: TextAlign.center,
          ),
          Gap.h12,
          // Message
          Text(
            context.l10n.btn_signOutMessage,
            style: BaseTypography.bodyMedium.toSecondary,
            textAlign: TextAlign.center,
          ),
          Gap.h24,
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: BaseSize.h12),
                    side: BorderSide(color: BaseColor.neutral40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                    ),
                  ),
                  child: Text(
                    context.l10n.btn_cancel,
                    style: BaseTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: BaseColor.secondaryText,
                    ),
                  ),
                ),
              ),
              Gap.w12,
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BaseColor.red[600],
                    foregroundColor: BaseColor.white,
                    padding: EdgeInsets.symmetric(vertical: BaseSize.h12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                    ),
                  ),
                  child: Text(
                    context.l10n.btn_signOut,
                    style: BaseTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: BaseColor.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Gap.h8,
        ],
      ),
    );
  }
}
