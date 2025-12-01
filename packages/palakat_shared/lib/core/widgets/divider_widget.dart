import 'package:flutter/material.dart';

/// A theme-aware divider widget that supports both vertical and horizontal orientations.
///
/// Uses [Theme.of(context)] for default color styling instead of hardcoded constants,
/// making it compatible with both palakat and palakat_admin apps.
///
/// Example usage:
/// ```dart
/// // Vertical divider (default)
/// DividerWidget()
///
/// // Horizontal divider
/// DividerWidget(axis: Axis.horizontal)
///
/// // Custom color and thickness
/// DividerWidget(
///   color: Colors.red,
///   thickness: 4,
///   height: 20,
/// )
/// ```
class DividerWidget extends StatelessWidget {
  /// Creates a theme-aware divider widget.
  ///
  /// [thickness] defaults to 2.0 logical pixels.
  /// [axis] defaults to [Axis.vertical].
  /// [color] defaults to the theme's outline variant color.
  /// [height] and [width] can be used to constrain the divider size.
  const DividerWidget({
    super.key,
    this.color,
    this.thickness = 2,
    this.axis = Axis.vertical,
    this.height,
    this.width,
  });

  /// The thickness of the divider line.
  ///
  /// For vertical dividers, this is the width.
  /// For horizontal dividers, this is the height.
  final double thickness;

  /// The color of the divider.
  ///
  /// If null, defaults to [ColorScheme.outlineVariant] from the current theme.
  final Color? color;

  /// The orientation of the divider.
  ///
  /// [Axis.vertical] creates a vertical line (default).
  /// [Axis.horizontal] creates a horizontal line.
  final Axis? axis;

  /// The height of the divider container.
  ///
  /// For horizontal dividers, this defaults to [thickness].
  /// For vertical dividers, this can be used to constrain the height.
  final double? height;

  /// The width of the divider container.
  ///
  /// For vertical dividers, this defaults to [thickness].
  /// For horizontal dividers, this can be used to constrain the width.
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use outlineVariant as the default color, which maps well to secondary/muted text colors
    final effectiveColor = color ?? theme.colorScheme.outlineVariant;

    return Container(
      width: width ?? (axis == Axis.vertical ? thickness : null),
      height: height ?? (axis == Axis.horizontal ? thickness : null),
      color: effectiveColor,
    );
  }
}
