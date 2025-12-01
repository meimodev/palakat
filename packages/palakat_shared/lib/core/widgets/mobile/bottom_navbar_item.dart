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
    final effectiveActiveColor = activeColor ?? BaseColor.cardBackground1;
    final effectiveInactiveColor = inactiveColor ?? BaseColor.primaryText;
    final effectiveActiveBackground =
        activeBackgroundColor ?? BaseColor.primaryText;
    final effectiveInactiveBackground =
        inactiveBackgroundColor ?? BaseColor.cardBackground1;

    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(18)),
      onTap: onPressed,
      child: Container(
        height: BaseSize.customWidth(45),
        width: BaseSize.customWidth(45),
        padding: EdgeInsets.symmetric(
          horizontal: activated ? BaseSize.customWidth(14) : BaseSize.w12,
          vertical: activated ? BaseSize.customWidth(14) : BaseSize.w12,
        ),
        decoration: BoxDecoration(
          boxShadow: activated
              ? const []
              : [
                  BoxShadow(
                    color: BaseColor.black.withValues(alpha: .125),
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
