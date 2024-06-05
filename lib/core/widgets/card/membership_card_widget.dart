import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/models/membership.dart';
import 'package:palakat/core/utils/extensions/extension.dart';
import 'package:palakat/core/widgets/widgets.dart';

class MembershipCardWidget extends StatelessWidget {
  const MembershipCardWidget({
    super.key,
    this.onPressedCard,
    this.membership,
  });

  final Membership? membership;

  final VoidCallback? onPressedCard;

  @override
  Widget build(BuildContext context) {
    final bool signed = membership != null;

    final Color textColor =
        signed ? BaseColor.secondaryText : BaseColor.cardBackground1;

    final title = signed
        ? membership!.account.name
        : "Sign-in to known whats happening in your local congregation ";

    return InkWell(
      onTap: onPressedCard,
      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      child: Container(
        decoration: BoxDecoration(
          color: signed ? BaseColor.cardBackground1 : BaseColor.primaryText,
          borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        ),
        height: BaseSize.customHeight(62),
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: BaseSize.h12,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              if (signed) ...[
                Text(
                  membership!.bipra.abv,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: BaseTypography.bodyMedium.bold.copyWith(
                        color: signed
                            ? BaseColor.primaryText
                            : BaseColor.cardBackground1,
                        fontWeight:
                            signed ? FontWeight.bold : FontWeight.normal,
                      ),
                      textAlign: signed ? TextAlign.start : TextAlign.center,
                    ),
                    if (signed)
                      Text(
                        membership!.church.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
              if (signed)
                Text(
                  membership!.columnNumber,
                  style: BaseTypography.headlineSmall.toSecondary,
                ),
              if (!signed)
                Text(
                  "SIGN IN",
                  style: BaseTypography.bodySmall.toBold.copyWith(
                    color: textColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
