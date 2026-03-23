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
    backgroundColor: Colors.transparent,
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
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      padding: EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: AppColors.tertiary,
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
          ),
          Gap.h16,
          // Warning icon
          Center(
            child: Container(
              width: 56.0,
              height: 56.0,
              decoration: BoxDecoration(
                color: AppColors.error.shade100,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: FaIcon(
                AppIcons.logout,
                size: 32.0,
                color: AppColors.error.shade700,
              ),
            ),
          ),
          Gap.h16,
          // Title
          Text(
            context.l10n.btn_signOutConfirm,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          Gap.h12,
          // Message
          Text(
            context.l10n.btn_signOutMessage,
            style: Theme.of(context).textTheme.bodyMedium!.toSecondary,
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
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    side: BorderSide(color: AppColors.tertiary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    context.l10n.btn_cancel,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              Gap.w12,
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.surfaceContainerLowest,
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    context.l10n.btn_signOut,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.surfaceContainerLowest,
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
