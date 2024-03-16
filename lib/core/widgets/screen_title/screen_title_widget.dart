import 'package:flutter/material.dart';
import 'package:palakat/core/assets/assets.gen.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/utils.dart';

class ScreenTitleWidget extends StatelessWidget {
  const ScreenTitleWidget.primary({
    super.key,
    required this.title,
    required this.leadIcon,
    required this.leadIconColor,
    required this.onPressedLeadIcon,
  })  : subTitle = null,
        trailIcon = null,
        trailIconColor = null,
        onPressedTrailIcon = null;

  const ScreenTitleWidget.titleOnly({
    super.key,
    required this.title,
  })  : subTitle = null,
        leadIcon = null,
        leadIconColor = null,
        onPressedLeadIcon = null,
        trailIcon = null,
        trailIconColor = null,
        onPressedTrailIcon = null;

  const ScreenTitleWidget.bottomSheet({
    super.key,
    required this.title,
    required this.trailIcon,
    required this.trailIconColor,
    required this.onPressedTrailIcon,
  })  : subTitle = null,
        leadIcon = null,
        leadIconColor = null,
        onPressedLeadIcon = null;

  final String title;
  final String? subTitle;

  final SvgGenImage? leadIcon;
  final Color? leadIconColor;
  final VoidCallback? onPressedLeadIcon;

  final SvgGenImage? trailIcon;
  final Color? trailIconColor;
  final VoidCallback? onPressedTrailIcon;

  @override
  Widget build(BuildContext context) {
    final iconSize = BaseSize.w24;
    if (leadIcon == null && trailIcon == null) {
      return Text(
        title,
        style: BaseTypography.headlineLarge,
        textAlign: TextAlign.start,
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildIcon(
          icon: leadIcon ?? Assets.icons.line.times,
          iconColor: leadIconColor ?? Colors.transparent,
          iconSize: iconSize,
          onPressedIcon: leadIcon != null ? onPressedLeadIcon! : null,
        ),
        Gap.w24,
        Expanded(
          child: Column(
            children: [
              Text(
                title,
                style: BaseTypography.headlineSmall,
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
        buildIcon(
          icon: trailIcon ?? Assets.icons.line.times,
          iconColor: trailIconColor ?? Colors.transparent,
          iconSize: iconSize,
          onPressedIcon: trailIcon != null ? onPressedTrailIcon! : null,
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
