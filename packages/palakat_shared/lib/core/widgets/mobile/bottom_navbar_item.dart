import 'package:flutter/material.dart';
import 'package:palakat_shared/core/theme/theme.dart';

/// A customizable bottom navigation bar item widget.
///
/// This widget provides a circular icon button with active/inactive states
/// for use in custom bottom navigation implementations.
class BottomNavBarItem extends StatelessWidget {
  const BottomNavBarItem({
    super.key,
    required this.onPressed,
    required this.activated,
    required this.icon,
    this.activeColor,
    this.inactiveColor,
    this.activeBackgroundColor,
    this.inactiveBackgroundColor,
  });

  /// Whether this item is currently selected/activated
  final bool activated;

  /// Callback when the item is pressed
  final void Function() onPressed;

  /// The icon widget to display
  final Widget icon;

  /// Color for the icon when activated. Defaults to card background color
  final Color? activeColor;

  /// Color for the icon when not activated. Defaults to primary text color
  final Color? inactiveColor;

  /// Background color when activated. Defaults to primary text color
  final Color? activeBackgroundColor;

  /// Background color when not activated. Defaults to card background color
  final Color? inactiveBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = activeColor ?? AppColors.surfaceContainerLowest;
    final effectiveInactiveColor = inactiveColor ?? Theme.of(context).colorScheme.onSurface;
    final effectiveActiveBackground =
        activeBackgroundColor ?? Theme.of(context).colorScheme.onSurface;
    final effectiveInactiveBackground =
        inactiveBackgroundColor ?? AppColors.surfaceContainerLowest;

    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(18)),
      onTap: onPressed,
      child: Container(
        height: 45.0,
        width: 45.0,
        padding: EdgeInsets.symmetric(
          horizontal: activated ? 14.0 : 12.0,
          vertical: activated ? 14.0 : 12.0,
        ),
        decoration: BoxDecoration(
          boxShadow: activated
              ? const []
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: .125),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(10, 10),
                  ),
                ],
          color: activated
              ? effectiveActiveBackground
              : effectiveInactiveBackground,
          shape: BoxShape.circle,
        ),
        child: IconTheme(
          data: IconThemeData(
            color: activated ? effectiveActiveColor : effectiveInactiveColor,
          ),
          child: icon,
        ),
      ),
    );
  }
}
