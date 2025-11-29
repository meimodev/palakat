import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/assets/assets.gen.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/extension/extension.dart';

enum _ScreenTitleVariant { primary, titleOnly, bottomSheet, titleSecondary }

class ScreenTitleWidget extends StatelessWidget {
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
       _variant = _ScreenTitleVariant.primary;

  const ScreenTitleWidget.titleOnly({super.key, required this.title})
    : subTitle = null,
      leadIcon = null,
      leadIconColor = null,
      onPressedLeadIcon = null,
      trailIcon = null,
      trailIconColor = null,
      onPressedTrailIcon = null,
      _variant = _ScreenTitleVariant.titleOnly;

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
       _variant = _ScreenTitleVariant.bottomSheet;

  /// Secondary title variant with back button, title and optional subtitle.
  /// Commonly used for form screens and detail pages.
  const ScreenTitleWidget.titleSecondary({
    super.key,
    required this.title,
    this.subTitle,
    this.onPressedLeadIcon,
  }) : leadIcon = null,
       leadIconColor = null,
       trailIcon = null,
       trailIconColor = null,
       onPressedTrailIcon = null,
       _variant = _ScreenTitleVariant.titleSecondary;

  final String title;
  final String? subTitle;

  final SvgGenImage? leadIcon;
  final Color? leadIconColor;
  final VoidCallback? onPressedLeadIcon;

  final SvgGenImage? trailIcon;
  final Color? trailIconColor;
  final VoidCallback? onPressedTrailIcon;

  final _ScreenTitleVariant _variant;

  @override
  Widget build(BuildContext context) {
    // Title secondary variant - back button with title and subtitle
    if (_variant == _ScreenTitleVariant.titleSecondary) {
      return _buildTitleSecondary(context);
    }
    final iconSize = BaseSize.w24;

    // Title only variant - simple and clean
    if (leadIcon == null && trailIcon == null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: BaseSize.h8),
        child: Text(
          title,
          style: BaseTypography.headlineLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: BaseColor.black,
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
                style: BaseTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: BaseColor.black,
                ),
              ),
              if (subTitle != null) ...[
                Gap.h4,
                Text(
                  subTitle!,
                  textAlign: TextAlign.center,
                  style: BaseTypography.titleMedium.copyWith(
                    color: BaseColor.secondaryText,
                  ),
                ),
              ],
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
  }) => IconButton(
    padding: EdgeInsets.zero,
    constraints: BoxConstraints(minHeight: iconSize, minWidth: iconSize),
    icon: icon.svg(
      width: iconSize,
      height: iconSize,
      colorFilter: iconColor.filterSrcIn,
    ),
    onPressed: onPressedIcon,
  );

  Widget _buildTitleSecondary(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + BaseSize.h8,
        left: BaseSize.w4,
        right: BaseSize.w12,
        bottom: BaseSize.h8,
      ),
      decoration: BoxDecoration(
        color: BaseColor.white,
        boxShadow: [
          BoxShadow(
            color: BaseColor.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onPressedLeadIcon ?? () => context.pop(),
            icon: Assets.icons.line.chevronBackOutline.svg(
              width: BaseSize.w24,
              height: BaseSize.h24,
              colorFilter: const ColorFilter.mode(
                BaseColor.textPrimary,
                BlendMode.srcIn,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: BaseTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: BaseColor.textPrimary,
                  ),
                ),
                if (subTitle != null) ...[
                  Gap.h4,
                  Text(
                    subTitle!,
                    style: BaseTypography.bodyMedium.copyWith(
                      color: BaseColor.neutral[600],
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
