import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:palakat/core/constants/constants.dart';

/// Shows a consequence explanation bottom sheet when user denies permissions
///
/// Returns `true` if the user taps "Enable in Settings", `false` if "Continue Without Notifications".
Future<bool?> showConsequenceExplanationBottomSheet({
  required BuildContext context,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: BaseColor.transparent,
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
            // Warning/Info icon
            Center(
              child: Container(
                width: BaseSize.w80,
                height: BaseSize.w80,
                decoration: BoxDecoration(
                  color: BaseColor.warning.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: FaIcon(
                  FontAwesomeIcons.circleExclamation,
                  size: BaseSize.w40,
                  color: BaseColor.warning,
                ),
              ),
            ),
            Gap.h24,
            // Title
            Text(
              'You\'ll Miss Out On',
              style: BaseTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: BaseColor.black,
              ),
              textAlign: TextAlign.center,
            ),
            Gap.h16,
            // Consequences list
            _ConsequenceItem(
              icon: FontAwesomeIcons.calendarXmark,
              text: 'Activity notifications and event updates',
            ),
            Gap.h12,
            _ConsequenceItem(
              icon: FontAwesomeIcons.clipboardQuestion,
              text: 'Approval requests that need your action',
            ),
            Gap.h12,
            _ConsequenceItem(
              icon: FontAwesomeIcons.bellSlash,
              text: 'Important church announcements and updates',
            ),
            Gap.h24,
            // Enable in Settings button (primary)
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
                'Enable in Settings',
                style: BaseTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: BaseColor.white,
                ),
              ),
            ),
            Gap.h12,
            // Continue Without Notifications button (text)
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: BaseSize.h12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                ),
              ),
              child: Text(
                'Continue Without Notifications',
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
          width: BaseSize.w40,
          height: BaseSize.w40,
          decoration: BoxDecoration(
            color: BaseColor.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(BaseSize.radiusSm),
          ),
          alignment: Alignment.center,
          child: FaIcon(icon, size: BaseSize.w20, color: BaseColor.warning),
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
