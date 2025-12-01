import 'package:flutter/material.dart';

/// A chip widget that displays a title with an optional leading icon.
///
/// Uses theme-aware styling for compatibility with both palakat and palakat_admin apps.
/// The chip has a subtle primary-colored background with a border.
///
/// Example usage:
/// ```dart
/// ChipsWidget(
///   title: 'Category',
///   icon: Assets.icons.line.tag,
/// )
/// ```
class ChipsWidget extends StatelessWidget {
  const ChipsWidget({super.key, required this.title, this.icon});

  /// The text to display in the chip
  final String title;

  /// Optional SVG icon to display before the title.
  /// Should be a flutter_gen SvgGenImage or similar that has an svg() method.
  final dynamic icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.08),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.24),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            SizedBox(
              width: 12,
              height: 12,
              child: icon.svg(
                width: 12.0,
                height: 12.0,
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.onSurfaceVariant,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
