import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/extension/extension.dart';

/// Shows a permission rationale bottom sheet explaining notification benefits
///
/// Returns `true` if the user taps "Allow Notifications", `false` if "Not Now".
Future<bool?> showPermissionRationaleBottomSheet({
  required BuildContext context,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (dialogContext) => const _PermissionRationaleContent(),
  );
}

class _PermissionRationaleContent extends StatelessWidget {
  const _PermissionRationaleContent();

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
            // Icon/Illustration
            Center(
              child: Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: FaIcon(
                  FontAwesomeIcons.bell,
                  size: 40.0,
                  color: AppColors.primary,
                ),
              ),
            ),
            Gap.h24,
            // Title
            Text(
              context.l10n.notificationPermission_rationale_title,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            Gap.h16,
            // Benefits list
            _BenefitItem(
              icon: FontAwesomeIcons.calendarCheck,
              text: context
                  .l10n
                  .notificationPermission_rationale_benefit_activities,
            ),
            Gap.h12,
            _BenefitItem(
              icon: FontAwesomeIcons.clipboardCheck,
              text: context
                  .l10n
                  .notificationPermission_rationale_benefit_approvals,
            ),
            Gap.h12,
            _BenefitItem(
              icon: FontAwesomeIcons.bullhorn,
              text: context
                  .l10n
                  .notificationPermission_rationale_benefit_announcements,
            ),
            Gap.h24,
            // Allow Notifications button (primary)
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
                context.l10n.notificationSettings_enableNotifications,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.surfaceContainerLowest,
                ),
              ),
            ),
            Gap.h12,
            // Not Now button (text)
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                context.l10n.notificationPermission_btn_notNow,
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

class _BenefitItem extends StatelessWidget {
  const _BenefitItem({required this.icon, required this.text});

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
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4.0),
          ),
          alignment: Alignment.center,
          child: FaIcon(icon, size: 20.0, color: AppColors.primary),
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
