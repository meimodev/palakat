import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:palakat_shared/theme.dart';

/// Helper widget for rendering Font Awesome icons with consistent styling.
///
/// This widget wraps [FaIcon] and provides factory constructors for
/// standard sizes based on the app's design system ([BaseSize]).
///
/// Example usage:
/// ```dart
/// AppIconWidget.small(AppIcons.back)
/// AppIconWidget.medium(AppIcons.search, color: Colors.blue)
/// AppIconWidget.large(AppIcons.approve)
/// AppIconWidget.xl(AppIcons.error, color: Colors.red)
/// ```
class AppIconWidget extends StatelessWidget {
  /// The icon to display.
  final IconData icon;

  /// The size of the icon. Defaults to [BaseSize.w20] (medium).
  final double? size;

  /// The color of the icon. If null, uses the default icon theme color.
  final Color? color;

  /// Creates an [AppIconWidget] with the given [icon], [size], and [color].
  const AppIconWidget(this.icon, {super.key, this.size, this.color});

  /// Creates a small icon (16px).
  factory AppIconWidget.small(IconData icon, {Key? key, Color? color}) {
    return AppIconWidget(icon, key: key, size: BaseSize.w16, color: color);
  }

  /// Creates a medium icon (20px) - the default size.
  factory AppIconWidget.medium(IconData icon, {Key? key, Color? color}) {
    return AppIconWidget(icon, key: key, size: BaseSize.w20, color: color);
  }

  /// Creates a large icon (24px).
  factory AppIconWidget.large(IconData icon, {Key? key, Color? color}) {
    return AppIconWidget(icon, key: key, size: BaseSize.w24, color: color);
  }

  /// Creates an extra large icon (32px).
  factory AppIconWidget.xl(IconData icon, {Key? key, Color? color}) {
    return AppIconWidget(icon, key: key, size: BaseSize.w32, color: color);
  }

  @override
  Widget build(BuildContext context) {
    return FaIcon(icon, size: size ?? BaseSize.w20, color: color);
  }
}
