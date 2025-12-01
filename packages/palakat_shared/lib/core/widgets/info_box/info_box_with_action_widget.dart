import 'package:flutter/material.dart';

/// A widget for displaying informational messages with an optional action button.
///
/// Uses theme-aware styling for compatibility with both palakat and palakat_admin apps.
/// Extends [InfoBoxWidget] with an optional action button.
///
/// Example usage:
/// ```dart
/// InfoBoxWithActionWidget(
///   message: 'Your session will expire soon.',
///   actionText: 'Extend Session',
///   onActionPressed: () => extendSession(),
/// )
/// ```
class InfoBoxWithActionWidget extends StatelessWidget {
  const InfoBoxWithActionWidget({
    super.key,
    required this.message,
    this.actionText,
    this.onActionPressed,
  });

  /// The message to display
  final String message;

  /// Text for the action button
  final String? actionText;

  /// Callback when the action button is pressed
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final infoColor = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: infoColor.withValues(alpha: 0.08),
        border: Border.all(color: infoColor.withValues(alpha: 0.24), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 20, color: infoColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: infoColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (actionText != null && onActionPressed != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: onActionPressed,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                backgroundColor: infoColor.withValues(alpha: 0.15),
                foregroundColor: infoColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                actionText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: infoColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
