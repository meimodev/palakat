import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';

class ListItemPatientJourneyContentWidget extends StatelessWidget {
  const ListItemPatientJourneyContentWidget({
    super.key,
    required this.title,
    this.titleColor,
    this.titleIcon,
    this.titleIconColor,
    this.subtitle = "",
    this.subtitleColor,
    this.subTitleIcon,
    this.subTitleIconColor,
    this.backgroundColor,
    this.removeTitleIcon = false,
    this.removeSubTitleIcon = false,
    this.children,
  });

  final Color? backgroundColor;

  final String title;
  final Color? titleColor;
  final SvgGenImage? titleIcon;
  final Color? titleIconColor;
  final bool removeTitleIcon;

  final String subtitle;
  final Color? subtitleColor;
  final SvgGenImage? subTitleIcon;
  final Color? subTitleIconColor;
  final bool removeSubTitleIcon;

  final List<Widget>? children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? BaseColor.neutral.shade10,
        borderRadius: BorderRadius.circular(
          BaseSize.radiusLg,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.customWidth(10),
        vertical: BaseSize.customHeight(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              removeTitleIcon
                  ? const SizedBox()
                  : (titleIcon ?? Assets.icons.fill.clock).svg(
                colorFilter:
                (titleIconColor ?? BaseColor.primary3).filterSrcIn,
                height: BaseSize.h20,
                width: BaseSize.h20,
              ),
              removeTitleIcon ? const SizedBox() : Gap.w4,
              Expanded(
                child: Text(
                  title,
                  style: TypographyTheme.textXSSemiBold.copyWith(
                    color: titleColor ?? BaseColor.primary3,
                  ),
                ),
              ),
            ],
          ),
          subtitle.isNotEmpty ? Gap.customGapHeight(6) : const SizedBox(),
          subtitle.isNotEmpty
              ? Row(
            children: [
              removeSubTitleIcon
                  ? const SizedBox()
                  : (subTitleIcon ?? Assets.icons.fill.account).svg(
                colorFilter:
                (subTitleIconColor ?? BaseColor.primary3)
                    .filterSrcIn,
                height: BaseSize.h20,
                width: BaseSize.h20,
              ),
              removeSubTitleIcon ? const SizedBox() : Gap.w4,
              Expanded(
                child: Text(
                  subtitle,
                  style: TypographyTheme.textXSSemiBold.copyWith(
                    color: subtitleColor ?? BaseColor.primary3,
                  ),
                ),
              ),
            ],
          )
              : const SizedBox(),
          children != null ? Gap.h16 : const SizedBox(),
          ...children ?? [],
        ],
      ),
    );
  }
}
