import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/models/membership.dart';
import 'package:palakat/core/utils/extensions/extension.dart';
import 'package:palakat/core/widgets/widgets.dart';

class MembershipCardWidget extends StatelessWidget {
  const MembershipCardWidget({super.key, this.onPressedCard, this.membership});

  final Membership? membership;

  final VoidCallback? onPressedCard;

  @override
  Widget build(BuildContext context) {
    final bool signed = membership != null;

    final Color textColor = signed
        ? BaseColor.secondaryText
        : BaseColor.cardBackground1;

    final String title = signed
        ? (membership!.account?.name ?? '')
        : 'Sign-in to known whats happening in your local congregation ';

    final Color titleColor = signed
        ? BaseColor.black
        : BaseColor.cardBackground1;
    final FontWeight titleWeight = signed ? FontWeight.bold : FontWeight.normal;
    final TextAlign titleAlign = signed ? TextAlign.start : TextAlign.center;


    return Material(
      clipBehavior: Clip.hardEdge,
      color: signed ? BaseColor.teal[50] : BaseColor.primary3,
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(BaseSize.radiusLg),
        side: BorderSide(
          width: signed ? 1 : 0,
          color: signed
              ? (BaseColor.teal[100] ?? BaseColor.neutral20)
              : BaseColor.transparent,
        ),
      ),
      child: InkWell(
        onTap: onPressedCard,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: BaseSize.h12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: BaseSize.w20,
                    height: BaseSize.w20,
                    decoration: BoxDecoration(
                      color: signed
                          ? (BaseColor.teal[100] ?? BaseColor.neutral20)
                          : BaseColor.cardBackground1,
                      borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                      border: Border.all(
                        color: signed
                            ? (BaseColor.teal[100] ?? BaseColor.neutral20)
                            : BaseColor.cardBackground1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      signed ? Icons.church : Icons.login,
                      size: BaseSize.w14,
                      color: signed
                          ? (BaseColor.teal[700] ?? BaseColor.primaryText)
                          : BaseColor.primary3,
                    ),
                  ),
                  Gap.w12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: BaseTypography.titleMedium.copyWith(
                            color: titleColor,
                            fontWeight: titleWeight,
                          ),
                          textAlign: titleAlign,
                        ),
                        Text(
                          membership?.church?.name ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: BaseTypography.bodySmall.toSecondary,
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              DividerWidget(color: textColor),
              Gap.h6,
              // Footer: chips or CTA
              if (signed)
                Row(
                  children: [
                    _pillChip(
                      icon: Icons.group,
                      label: (membership?.bipra?.name ?? '').isEmpty
                          ? '-'
                          : (membership?.bipra?.name ?? ''),
                      bg: BaseColor.teal[50] ?? BaseColor.neutral20,
                      fg: BaseColor.teal[700] ?? BaseColor.primaryText,
                      border: BaseColor.teal[200] ?? BaseColor.neutral40,
                    ),
                    Gap.w6,
                    _pillChip(
                      icon: Icons.location_city,
                      label: 'Kolom ${membership?.column?.id ?? '-'}',
                      bg: BaseColor.blue[50] ?? BaseColor.neutral20,
                      fg: BaseColor.blue[700] ?? BaseColor.primaryText,
                      border: BaseColor.blue[200] ?? BaseColor.neutral40,
                    ),
                  ],
                )
              else
                Align(
                  alignment: Alignment.centerLeft,
                  child: _ctaChip(
                    icon: Icons.login,
                    label: 'Sign in',
                    fg: BaseColor.cardBackground1,
                    border: BaseColor.cardBackground1,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Local helpers (kept in this file for reuse consistency with other widgets)
Widget _pillChip({
  required IconData icon,
  required String label,
  required Color bg,
  required Color fg,
  required Color border,
}) {
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: BaseSize.w8,
      vertical: BaseSize.h4,
    ),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(BaseSize.radiusSm),
      border: Border.all(color: border),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: BaseSize.radiusSm, color: fg),
        Gap.w4,
        Text(label, style: BaseTypography.labelSmall.copyWith(color: fg)),
      ],
    ),
  );
}

Widget _ctaChip({
  required IconData icon,
  required String label,
  required Color fg,
  required Color border,
}) {
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: BaseSize.w10,
      vertical: BaseSize.h6,
    ),
    decoration: BoxDecoration(
      color: BaseColor.transparent,
      borderRadius: BorderRadius.circular(BaseSize.radiusSm),
      border: Border.all(color: border),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: BaseSize.w14, color: fg),
        Gap.w6,
        Text(
          label.toUpperCase(),
          style: BaseTypography.bodySmall.toBold.copyWith(color: fg),
        ),
      ],
    ),
  );
}
