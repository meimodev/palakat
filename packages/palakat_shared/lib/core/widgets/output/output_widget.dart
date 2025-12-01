import 'package:flutter/material.dart';

/// A widget for displaying output/read-only information with optional icons.
///
/// Uses theme-aware styling for compatibility with both palakat and palakat_admin apps.
/// Supports multiple variants for different display needs.
///
/// Example usage:
/// ```dart
/// OutputWidget.bipra(
///   title: 'Activity Name',
///   label: 'Type',
///   startText: 'PKB',
/// )
/// ```
class OutputWidget extends StatelessWidget {
  /// Creates an output widget with a text badge on the left.
  const OutputWidget.bipra({
    super.key,
    required this.title,
    this.label,
    required this.startText,
  }) : startIcon = null,
       onPressedEndIcon = null,
       endIcon = null;

  /// Creates an output widget with an icon on the left.
  const OutputWidget.startIcon({
    super.key,
    required this.title,
    this.label,
    required this.startIcon,
  }) : startText = null,
       onPressedEndIcon = null,
       endIcon = null;

  /// Creates an output widget with an icon on the right (and optionally on the left).
  const OutputWidget.endIcon({
    super.key,
    required this.title,
    this.label,
    required this.endIcon,
    this.onPressedEndIcon,
    this.startIcon,
  }) : startText = null;

  /// The main text to display
  final String title;

  /// Optional label displayed above the content
  final String? label;

  /// Text to display in the start badge (for bipra variant)
  final String? startText;

  /// Icon to display at the start.
  /// Should be a flutter_gen SvgGenImage or similar that has an svg() method.
  final dynamic startIcon;

  /// Icon to display at the end.
  /// Should be a flutter_gen SvgGenImage or similar that has an svg() method.
  final dynamic endIcon;

  /// Callback when the end icon is pressed
  final VoidCallback? onPressedEndIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null)
          Text(
            label!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        const SizedBox(height: 6),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildStartWidget(context),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [_buildEndWidget(context)],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStartWidget(BuildContext context) {
    if (startText == null && startIcon == null) {
      return const SizedBox();
    }

    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (startIcon != null)
                SizedBox(
                  width: 12,
                  height: 12,
                  child: startIcon.svg(
                    width: 12.0,
                    height: 12.0,
                    colorFilter: ColorFilter.mode(
                      theme.colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              if (startText != null)
                Text(
                  startText!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEndWidget(BuildContext context) {
    if (endIcon == null) {
      return const SizedBox();
    }

    final theme = Theme.of(context);

    return InkWell(
      onTap: onPressedEndIcon,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: SizedBox(
            width: 12,
            height: 12,
            child: endIcon.svg(
              width: 12.0,
              height: 12.0,
              colorFilter: ColorFilter.mode(
                theme.colorScheme.surface,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
