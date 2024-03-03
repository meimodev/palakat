import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:palakat/core/assets/assets.gen.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/utils.dart';

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

  @override
  Widget build(BuildContext context) {
    Widget buildIcon({
      required SvgGenImage icon,
      required Color iconColor,
      required VoidCallback? onPressedIcon,
    }) =>
        IconButton(
          padding: EdgeInsets.zero,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          constraints: BoxConstraints(
            minHeight: _iconSize,
            minWidth: _iconSize,
          ),
          icon: icon.svg(
            width: _iconSize,
            height: _iconSize,
            colorFilter: iconColor.filterSrcIn,
          ),
          iconSize: _iconSize.r,
          splashRadius: _iconSize.r,
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
                  leadIcon != null
                      ? buildIcon(
                          icon: leadIcon!,
                          iconColor: leadIconColor ?? Colors.black,
                          onPressedIcon: onPressedLeadIcon ?? () {},
                        )
                      : const SizedBox(),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        title,
                        style: BaseTypography.headlineLarge,
                      ),

                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: BaseTypography.titleMedium,
                        ),
                    ],
                  ),
                  trailIcon != null
                      ? buildIcon(
                          icon: trailIcon!,
                          iconColor: trailIconColor ?? Colors.black,
                          onPressedIcon: onPressedTrailIcon ?? () {},
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
