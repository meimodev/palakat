import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:palakat/core/constants/constants.dart';

/// Shows a permission rationale bottom sheet explaining notification benefits
///
/// Returns `true` if the user taps "Allow Notifications", `false` if "Not Now".
Future<bool?> showPermissionRationaleBottomSheet({
  required BuildContext context,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: BaseColor.transparent,
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
        color: BaseColor.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(BaseSize.radiusLg),
          topRight: Radius.circular(BaseSize.radiusLg),
        ),
      ),
      padding: EdgeInsets.all(BaseSize.w24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
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
            // Icon/Illustration
            Center(
              child: Container(
                width: BaseSize.w80,
                height: BaseSize.w80,
                decoration: BoxDecoration(
                  color: BaseColor.primary3.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: FaIcon(
                  FontAwesomeIcons.bell,
                  size: BaseSize.w40,
                  color: BaseColor.primary3,
                ),
              ),
            ),
            Gap.h24,
            // Title
            Text(
              'Stay Updated',
              style: BaseTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: BaseColor.black,
              ),
              textAlign: TextAlign.center,
            ),
            Gap.h16,
            // Benefits list
            _BenefitItem(
              icon: FontAwesomeIcons.calendarCheck,
              text: 'Get notified about new activities and events',
            ),
            Gap.h12,
            _BenefitItem(
              icon: FontAwesomeIcons.clipboardCheck,
              text: 'Receive approval requests that need your attention',
            ),
            Gap.h12,
            _BenefitItem(
              icon: FontAwesomeIcons.bullhorn,
              text: 'Don\'t miss important church announcements',
            ),
            Gap.h24,
            // Allow Notifications button (primary)
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: BaseColor.primary3,
                foregroundColor: BaseColor.white,
                padding: EdgeInsets.symmetric(vertical: BaseSize.h16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                ),
              ),
              child: Text(
                'Allow Notifications',
                style: BaseTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: BaseColor.white,
                ),
              ),
            ),
            Gap.h12,
            // Not Now button (text)
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: BaseSize.h12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                ),
              ),
              child: Text(
                'Not Now',
                style: BaseTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: BaseColor.secondaryText,
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
          width: BaseSize.w40,
          height: BaseSize.w40,
          decoration: BoxDecoration(
            color: BaseColor.primary3.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(BaseSize.radiusSm),
          ),
          alignment: Alignment.center,
          child: FaIcon(icon, size: BaseSize.w20, color: BaseColor.primary3),
        ),
        Gap.w12,
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: BaseSize.h8),
            child: Text(
              text,
              style: BaseTypography.bodyMedium.copyWith(
                color: BaseColor.primaryText,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
