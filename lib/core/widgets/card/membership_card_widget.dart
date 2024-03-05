import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/extensions/extension.dart';
import 'package:palakat/core/widgets/widgets.dart';

enum MembershipCardWidgetVariant { signed, unsigned }

class MembershipCardWidget extends StatelessWidget {
  const MembershipCardWidget({
    super.key,
    required this.variant,
    required this.title,
    required this.subTitle,
    required this.bipra,
    this.onPressedCard,
    required this.columnNumber,
  });

  final MembershipCardWidgetVariant variant;

  final String title;
  final String subTitle;
  final String bipra;
  final String columnNumber;

  final VoidCallback? onPressedCard;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressedCard,
      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      child: Container(
        decoration: BoxDecoration(
          color: variant == MembershipCardWidgetVariant.signed
              ? BaseColor.cardBackground1
              : BaseColor.primaryText,
          borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        ),
        height: BaseSize.customHeight(62),
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: BaseSize.h12,
        ),
        child: _buildRowLayout(
          title: title,
          subTitle: subTitle,
          bipra: bipra,
          number: columnNumber,
          textColor: variant == MembershipCardWidgetVariant.signed
              ? BaseColor.primaryText
              : BaseColor.cardBackground1,
        ),
      ),
    );
  }

  _buildRowLayout({
    required String title,
    String? subTitle,
    String? bipra,
    String? number,
    required Color textColor,
  }) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          if (variant == MembershipCardWidgetVariant.signed) ...[
            Text(
              bipra ?? "AAA",
              style: BaseTypography.headlineSmall.toSecondary,
            ),
            Gap.w12,
            DividerWidget(
              color: textColor,
            ),
            Gap.w12,
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: BaseTypography.bodyMedium.bold.copyWith(
                    color: textColor,
                    fontWeight: variant == MembershipCardWidgetVariant.signed
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  textAlign: variant == MembershipCardWidgetVariant.signed
                      ? TextAlign.start
                      : TextAlign.center,
                ),
                if (variant == MembershipCardWidgetVariant.signed)
                  Text(
                    subTitle ?? "",
                    style: BaseTypography.bodyMedium,
                    textAlign: TextAlign.start,
                  ),
              ],
            ),
          ),
          Gap.w12,
          DividerWidget(
            color: textColor,
          ),
          Gap.w12,
          if (variant == MembershipCardWidgetVariant.signed)
            Text(
              number ?? "1",
              style: BaseTypography.headlineSmall.toSecondary,
            ),
          if (variant == MembershipCardWidgetVariant.unsigned)
            Text(
              "SIGN IN",
              style: BaseTypography.bodySmall.toBold.copyWith(
                color: textColor,
              ),
            ),
        ],
      );
}
