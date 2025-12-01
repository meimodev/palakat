import 'package:flutter/material.dart';
import 'package:palakat/core/assets/assets.gen.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/widgets/mobile/appbar_widget.dart'
    as shared;

/// App-specific AppBar widget that wraps the shared AppBarWidget
/// and provides convenience methods for using SvgGenImage icons.
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

  final String title;
  final String? subtitle;
  final double? height;

  final SvgGenImage? leadIcon;
  final Color? leadIconColor;
  final VoidCallback? onPressedLeadIcon;

  final SvgGenImage? trailIcon;
  final Color? trailIconColor;
  final VoidCallback? onPressedTrailIcon;

  @override
  Size get preferredSize => Size.fromHeight(height ?? BaseSize.h56);

  static double get _iconSize => BaseSize.w24;

  Widget? _buildSvgIcon(SvgGenImage? icon, Color? color) {
    if (icon == null) return null;
    return icon.svg(
      width: _iconSize,
      height: _iconSize,
      colorFilter: (color ?? Colors.black).filterSrcIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return shared.AppBarWidget(
      title: title,
      subtitle: subtitle,
      height: height,
      leadIcon: _buildSvgIcon(leadIcon, leadIconColor),
      onPressedLeadIcon: onPressedLeadIcon,
      trailIcon: _buildSvgIcon(trailIcon, trailIconColor),
      onPressedTrailIcon: onPressedTrailIcon,
    );
  }
}
