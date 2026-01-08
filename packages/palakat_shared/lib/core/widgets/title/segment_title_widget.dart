import 'package:flutter/material.dart';

/// A widget for displaying segment/section titles with count and optional "View All" action.
///
/// Uses theme-aware styling for compatibility with both palakat and palakat_admin apps.
/// Shows an empty state when count is 0.
///
/// Example usage:
/// ```dart
/// SegmentTitleWidget(
///   title: 'Recent Activities',
///   count: 5,
///   onPressedViewAll: () => navigateToAll(),
///   leadingIcon: Icons.event,
/// )
/// ```
class SegmentTitleWidget extends StatelessWidget {
  const SegmentTitleWidget({
    super.key,
    this.onPressedViewAll,
    required this.count,
    required this.title,
    this.titleStyle,
    this.leadingIcon,
    this.leadingBg,
    this.leadingFg,
  });

  /// Callback when "View All" is pressed
  final VoidCallback? onPressedViewAll;

  /// The count to display in the badge
  final int count;

  /// The title text
  final String title;

  final TextStyle? titleStyle;

  /// Optional icon to display before the title
  final IconData? leadingIcon;

  /// Background color for the leading icon container
  final Color? leadingBg;

  /// Foreground color for the leading icon
  final Color? leadingFg;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    if (count == 0) {
      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 32,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              "No $title available",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    final effectiveLeadingBg = leadingBg ?? primaryColor.withValues(alpha: 0.1);
    final effectiveLeadingFg = leadingFg ?? primaryColor;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              if (leadingIcon != null)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: effectiveLeadingBg,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: effectiveLeadingBg.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(leadingIcon, size: 20, color: effectiveLeadingFg),
                ),
              if (leadingIcon != null) const SizedBox(width: 12),
              Flexible(
                child: Text(
                  title,
                  style:
                      titleStyle ??
                      theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  count.toString(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: onPressedViewAll,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "View All",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 16, color: primaryColor),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
