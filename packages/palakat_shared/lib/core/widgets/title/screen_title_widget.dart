import 'package:flutter/material.dart';

enum _ScreenTitleVariant { primary, titleOnly, bottomSheet, titleSecondary }

/// A widget for displaying screen titles with various layouts.
///
/// Uses theme-aware styling for compatibility with both palakat and palakat_admin apps.
/// Supports multiple variants for different screen types.
///
/// Example usage:
/// ```dart
/// ScreenTitleWidget.primary(
///   title: 'Dashboard',
///   leadIcon: Assets.icons.line.menu,
///   leadIconColor: Colors.black,
///   onPressedLeadIcon: () => openDrawer(),
/// )
/// ```
class ScreenTitleWidget extends StatelessWidget {
  /// Creates a primary screen title with lead icon, title, optional subtitle, and optional trail icon.
  const ScreenTitleWidget.primary({
    super.key,
    required this.title,
    required this.leadIcon,
    required this.leadIconColor,
    required this.onPressedLeadIcon,
    this.subTitle,
  }) : trailIcon = null,
       trailIconColor = null,
       onPressedTrailIcon = null,
       onBack = null,
       _variant = _ScreenTitleVariant.primary;

  /// Creates a simple title-only variant.
  const ScreenTitleWidget.titleOnly({super.key, required this.title})
    : subTitle = null,
      leadIcon = null,
      leadIconColor = null,
      onPressedLeadIcon = null,
      trailIcon = null,
      trailIconColor = null,
      onPressedTrailIcon = null,
      onBack = null,
      _variant = _ScreenTitleVariant.titleOnly;

  /// Creates a bottom sheet title with a close button on the right.
  const ScreenTitleWidget.bottomSheet({
    super.key,
    required this.title,
    required this.trailIcon,
    required this.trailIconColor,
    required this.onPressedTrailIcon,
  }) : subTitle = null,
       leadIcon = null,
       leadIconColor = null,
       onPressedLeadIcon = null,
       onBack = null,
       _variant = _ScreenTitleVariant.bottomSheet;

  /// Secondary title variant with back button, title and optional subtitle.
  /// Commonly used for form screens and detail pages.
  const ScreenTitleWidget.titleSecondary({
    super.key,
    required this.title,
    this.subTitle,
    this.onBack,
  }) : leadIcon = null,
       leadIconColor = null,
       onPressedLeadIcon = null,
       trailIcon = null,
       trailIconColor = null,
       onPressedTrailIcon = null,
       _variant = _ScreenTitleVariant.titleSecondary;

  /// The main title text
  final String title;

  /// Optional subtitle text
  final String? subTitle;

  /// Icon to display on the left.
  /// Should be a flutter_gen SvgGenImage or similar that has an svg() method.
  final dynamic leadIcon;

  /// Color for the lead icon
  final Color? leadIconColor;

  /// Callback when the lead icon is pressed
  final VoidCallback? onPressedLeadIcon;

  /// Icon to display on the right.
  /// Should be a flutter_gen SvgGenImage or similar that has an svg() method.
  final dynamic trailIcon;

  /// Color for the trail icon
  final Color? trailIconColor;

  /// Callback when the trail icon is pressed
  final VoidCallback? onPressedTrailIcon;

  /// Callback for back navigation (used in titleSecondary variant)
  final VoidCallback? onBack;

  final _ScreenTitleVariant _variant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Title secondary variant - back button with title and subtitle
    if (_variant == _ScreenTitleVariant.titleSecondary) {
      return _buildTitleSecondary(context, theme);
    }

    const iconSize = 24.0;

    // Title only variant - simple and clean
    if (leadIcon == null && trailIcon == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          title,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.start,
        ),
      );
    }

    // Primary and bottom sheet variants
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIcon(
          context: context,
          icon: leadIcon,
          iconColor: leadIconColor ?? Colors.transparent,
          iconSize: iconSize,
          onPressedIcon: leadIcon != null ? onPressedLeadIcon! : null,
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            children: [
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (subTitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subTitle!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 24),
        _buildIcon(
          context: context,
          icon: trailIcon,
          iconColor: trailIconColor ?? Colors.transparent,
          iconSize: iconSize,
          onPressedIcon: trailIcon != null ? onPressedTrailIcon! : null,
        ),
      ],
    );
  }

  Widget _buildIcon({
    required BuildContext context,
    required dynamic icon,
    required Color iconColor,
    required VoidCallback? onPressedIcon,
    required double iconSize,
  }) {
    if (icon == null) {
      return SizedBox(width: iconSize, height: iconSize);
    }

    return IconButton(
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(minHeight: iconSize, minWidth: iconSize),
      icon: SizedBox(
        width: iconSize,
        height: iconSize,
        child: icon.svg(
          width: iconSize,
          height: iconSize,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        ),
      ),
      onPressed: onPressedIcon,
    );
  }

  Widget _buildTitleSecondary(BuildContext context, ThemeData theme) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 4,
        right: 12,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack ?? () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.chevron_left,
              size: 24,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (subTitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subTitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
