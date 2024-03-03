import 'package:flutter/material.dart';
import 'package:palakat/core/assets/assets.gen.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/utils.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({
    super.key,
    this.icon,
    this.title,
    this.titleStyle,
    required this.content,
    this.withBorder = true,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
    this.postFixWidget,
    this.padding,
  }) : assert(postFixWidget == null || title != null,
            "if postfix not null then title cannot be null either");

  final SvgGenImage? icon;
  final String? title;
  final List<Widget> content;
  final bool withBorder;
  final Color? backgroundColor;
  final Color? borderColor;
  final void Function()? onTap;
  final TextStyle? titleStyle;
  final Widget? postFixWidget;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius:  BorderRadius.circular(BaseSize.radiusLg),
      child: Container(
        padding: padding ?? EdgeInsets.all(BaseSize.w20),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: withBorder
              ? Border.all(
                  width: 1,
                  color: borderColor ?? BaseColor.neutral.shade20,
                )
              : null,
          borderRadius: BorderRadius.circular(BaseSize.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[
              Container(
                padding: EdgeInsets.only(bottom: BaseSize.h20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 1,
                      color: BaseColor.neutral.shade20,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    icon?.svg(
                            width: BaseSize.customWidth(24),
                            height: BaseSize.customWidth(24),
                            colorFilter: BaseColor.primary3.filterSrcIn) ??
                        const SizedBox(),
                    Gap.customGapWidth(icon != null ? 10 : 0),
                    Expanded(
                      child: Text(
                        title ?? '',
                        style: titleStyle ??
                            BaseTypography.titleMedium.toNeutral80,
                      ),
                    ),
                    postFixWidget ?? const SizedBox(),
                  ],
                ),
              ),
              Gap.h20,
            ],
            ...content
          ],
        ),
      ),
    );
  }
}
