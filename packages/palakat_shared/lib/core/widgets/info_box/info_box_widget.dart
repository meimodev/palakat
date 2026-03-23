import 'package:flutter/material.dart';
import 'package:palakat_shared/core/theme/theme.dart';

/// A widget for displaying informational messages in a styled box.
///
/// Uses theme-aware styling for compatibility with both palakat and palakat_admin apps.
/// Displays an info icon with a message in a blue-tinted container.
///
/// Example usage:
/// ```dart
/// InfoBoxWidget(
///   message: 'This action cannot be undone.',
/// )
/// ```
class InfoBoxWidget extends StatelessWidget {
  const InfoBoxWidget({super.key, required this.message});

  /// The message to display
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final infoColor = AppColors.primary;

    return Material(
      color: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
        side: BorderSide(color: AppColors.ghostBorder(0.08)),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
          boxShadow: SanctuaryDepth.ambient(opacity: 0.03, blur: 18),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                border: Border.all(color: AppColors.ghostBorder(0.06)),
                borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
                boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 8),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.info_outline, size: 18, color: infoColor),
            ),
            Gap.w12,
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
