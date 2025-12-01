import 'package:flutter/material.dart';

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
    final infoColor = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: infoColor.withValues(alpha: 0.08),
        border: Border.all(color: infoColor.withValues(alpha: 0.24), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
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
    );
  }
}
