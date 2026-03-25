import 'package:flutter/material.dart';
import 'package:palakat_shared/core/theme/theme.dart';

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
///   leadIconColor: AppColors.onSurface,
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

    if (_variant == _ScreenTitleVariant.bottomSheet) {
      return _buildBottomSheet(context, theme);
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
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
          boxShadow: SanctuaryDepth.ambient(opacity: 0.03, blur: 18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              _buildIcon(
                context: context,
                icon: leadIcon,
                iconColor: leadIconColor ?? Colors.transparent,
                iconSize: iconSize,
                onPressedIcon: leadIcon != null ? onPressedLeadIcon! : null,
                useSanctuaryShell: true,
              ),
              Gap.w16,
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    if (subTitle != null) ...[
                      Gap.h4,
                      Text(
                        subTitle!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Gap.w12,
              _buildIcon(
                context: context,
                icon: trailIcon,
                iconColor: trailIconColor ?? Colors.transparent,
                iconSize: iconSize,
                onPressedIcon: trailIcon != null ? onPressedTrailIcon! : null,
                useSanctuaryShell: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon({
    required BuildContext context,
    required dynamic icon,
    required Color iconColor,
    required VoidCallback? onPressedIcon,
    required double iconSize,
    bool useSanctuaryShell = false,
  }) {
    if (icon == null) {
      return SizedBox(width: iconSize, height: iconSize);
    }

    // Support both IconData and SVG assets
    Widget iconWidget;
    if (icon is IconData) {
      iconWidget = Icon(icon, size: iconSize, color: iconColor);
    } else {
      // Assume it's an SVG asset with .svg() method
      iconWidget = SizedBox(
        width: iconSize,
        height: iconSize,
        child: icon.svg(
          width: iconSize,
          height: iconSize,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        ),
      );
    }

    if (!useSanctuaryShell) {
      return IconButton(
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(minHeight: iconSize, minWidth: iconSize),
        icon: iconWidget,
        onPressed: onPressedIcon,
      );
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 44, height: 44),
        icon: iconWidget,
        onPressed: onPressedIcon,
      ),
    );
  }

  Widget _buildTitleSecondary(BuildContext context, ThemeData theme) {
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
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
          boxShadow: SanctuaryDepth.ambient(opacity: 0.03, blur: 18),
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 44,
                    height: 44,
                  ),
                  onPressed: onBack ?? () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.chevron_left,
                    size: 22,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              Gap.w12,
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      if (subTitle != null) ...[
                        Gap.h4,
                        Text(
                          subTitle!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context, ThemeData theme) {
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
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
          boxShadow: SanctuaryDepth.ambient(opacity: 0.03, blur: 18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const SizedBox(width: 44, height: 44),
              Gap.w12,
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              Gap.w12,
              _buildIcon(
                context: context,
                icon: trailIcon,
                iconColor: trailIconColor ?? AppColors.onSurface,
                iconSize: 24,
                onPressedIcon: onPressedTrailIcon,
                useSanctuaryShell: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
