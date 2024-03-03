import 'package:flutter/material.dart';
import 'package:palakat/core/assets/assets.gen.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/utils.dart';

enum ScreenTitleWidgetVariant { titleOnly }

class ScreenTitleWidget extends StatelessWidget {
  const ScreenTitleWidget({
    super.key,
    required this.title,
    this.variant,
    this.leadIcon,
    this.leadIconColor,
    this.onPressedLeadIcon,
    this.trailIcon,
    this.trailIconColor,
    this.onPressedTrailIcon,
    this.subTitle,
  });

  final String title;
  final String? subTitle;
  final ScreenTitleWidgetVariant? variant;

  final SvgGenImage? leadIcon;
  final Color? leadIconColor;
  final VoidCallback? onPressedLeadIcon;

  final SvgGenImage? trailIcon;
  final Color? trailIconColor;
  final VoidCallback? onPressedTrailIcon;

  @override
  Widget build(BuildContext context) {
    final iconSize = BaseSize.w24;
    if (variant == ScreenTitleWidgetVariant.titleOnly) {
      return Text(
        title,
        style: BaseTypography.headlineLarge,
        textAlign: TextAlign.start,
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        if (leadIcon != null)
          buildIcon(
            icon: leadIcon!,
            iconColor: leadIconColor ?? Colors.transparent,
            iconSize: iconSize,
            onPressedIcon: onPressedLeadIcon,
          ),
        Gap.w24,
        Expanded(
          child: Column(
            children: [
              Text(
                title,
                style: BaseTypography.headlineLarge,
              ),
              if (subTitle != null)
                Text(
                  subTitle!,
                  style: BaseTypography.headlineLarge,
                ),
            ],
          ),
        ),
        Gap.w24,
        if (trailIcon != null)
          buildIcon(
            icon: trailIcon!,
            iconColor: trailIconColor ?? Colors.transparent,
            iconSize: iconSize,
            onPressedIcon: onPressedTrailIcon,
          ),
      ],
    );
  }

  Widget buildIcon({
    required SvgGenImage icon,
    required Color iconColor,
    required VoidCallback? onPressedIcon,
    required double iconSize,
  }) =>
      IconButton(
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(
          minHeight: iconSize,
          minWidth: iconSize,
        ),
        icon: icon.svg(
          width: iconSize,
          height: iconSize,
          colorFilter: iconColor.filterSrcIn,
        ),
        onPressed: onPressedIcon,
      );
}
