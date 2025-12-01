import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palakat_shared/core/theme/theme.dart';

/// A customizable app bar widget for mobile applications.
///
/// This widget provides a consistent app bar design with optional
/// leading and trailing icons, title, and subtitle support.
class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.height,
    this.leadIcon,
    this.leadIconColor,
    this.onPressedLeadIcon,
    this.trailIcon,
    this.trailIconColor,
    this.onPressedTrailIcon,
  });

  /// The main title text displayed in the app bar
  final String title;

  /// Optional subtitle text displayed below the title
  final String? subtitle;

  /// Custom height for the app bar. Defaults to 56.0
  final double? height;

  /// Leading icon widget (typically a back button or menu icon)
  final Widget? leadIcon;

  /// Color for the leading icon
  final Color? leadIconColor;

  /// Callback when the leading icon is pressed
  final VoidCallback? onPressedLeadIcon;

  /// Trailing icon widget (typically an action button)
  final Widget? trailIcon;

  /// Color for the trailing icon
  final Color? trailIconColor;

  /// Callback when the trailing icon is pressed
  final VoidCallback? onPressedTrailIcon;

  @override
  Size get preferredSize => Size.fromHeight(height ?? BaseSize.h56);

  static double get _iconSize => BaseSize.w24;

  @override
  Widget build(BuildContext context) {
    Widget buildIconButton({
      required Widget icon,
      required VoidCallback? onPressedIcon,
    }) => IconButton(
      padding: EdgeInsets.zero,
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      constraints: BoxConstraints(minHeight: _iconSize, minWidth: _iconSize),
      icon: icon,
      iconSize: _iconSize,
      splashRadius: _iconSize,
      onPressed: onPressedIcon,
    );

    return AppBar(
      systemOverlayStyle: const SystemUiOverlayStyle(
        systemNavigationBarColor: BaseColor.transparent,
        statusBarBrightness: Brightness.light,
        statusBarColor: BaseColor.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: preferredSize,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: horizontalScreenPadding,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (leadIcon != null)
                    buildIconButton(
                      icon: leadIcon!,
                      onPressedIcon: onPressedLeadIcon ?? () {},
                    )
                  else
                    const SizedBox(),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(title, style: BaseTypography.headlineLarge),
                      if (subtitle != null)
                        Text(subtitle!, style: BaseTypography.titleMedium),
                    ],
                  ),
                  if (trailIcon != null)
                    buildIconButton(
                      icon: trailIcon!,
                      onPressedIcon: onPressedTrailIcon ?? () {},
                    )
                  else
                    const SizedBox(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
