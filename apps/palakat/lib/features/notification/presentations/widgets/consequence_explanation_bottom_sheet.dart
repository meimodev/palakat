import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/extension/extension.dart';

/// Shows a consequence explanation bottom sheet when user denies permissions
///
/// Returns `true` if the user taps "Enable in Settings", `false` if "Continue Without Notifications".
Future<bool?> showConsequenceExplanationBottomSheet({
  required BuildContext context,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (dialogContext) => const _ConsequenceExplanationContent(),
  );
}

class _ConsequenceExplanationContent extends StatelessWidget {
  const _ConsequenceExplanationContent();

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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
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
            // Warning/Info icon
            Center(
              child: Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: FaIcon(
                  FontAwesomeIcons.circleExclamation,
                  size: 40.0,
                  color: AppColors.warning,
                ),
              ),
            ),
            Gap.h24,
            // Title
            Text(
              context.l10n.notificationPermission_consequence_title,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            Gap.h16,
            // Consequences list
            _ConsequenceItem(
              icon: FontAwesomeIcons.calendarXmark,
              text: context
                  .l10n
                  .notificationPermission_consequence_item_activities,
            ),
            Gap.h12,
            _ConsequenceItem(
              icon: FontAwesomeIcons.clipboardQuestion,
              text: context
                  .l10n
                  .notificationPermission_consequence_item_approvals,
            ),
            Gap.h12,
            _ConsequenceItem(
              icon: FontAwesomeIcons.bellSlash,
              text: context
                  .l10n
                  .notificationPermission_consequence_item_announcements,
            ),
            Gap.h24,
            // Enable in Settings button (primary)
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surfaceContainerLowest,
                padding: EdgeInsets.symmetric(vertical: 16.0),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                context.l10n.notificationPermission_btn_enableInSettings,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.surfaceContainerLowest,
                ),
              ),
            ),
            Gap.h12,
            // Continue Without Notifications button (text)
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                context
                    .l10n
                    .notificationPermission_btn_continueWithoutNotifications,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            Gap.h8,
          ],
        ),
      ),
    );
  }
}

class _ConsequenceItem extends StatelessWidget {
  const _ConsequenceItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4.0),
          ),
          alignment: Alignment.center,
          child: FaIcon(icon, size: 20.0, color: AppColors.warning),
        ),
        Gap.w12,
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: AppColors.onSurface,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
