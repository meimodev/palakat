import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';

enum FormSectionWidgetStyle { standard, compact }

class FormSectionWidget extends StatelessWidget {
  const FormSectionWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.subtitle,
    this.showDivider = true,
    this.style = FormSectionWidgetStyle.standard,
  });

  final String title;
  final IconData icon;
  final String? subtitle;
  final List<Widget> children;
  final bool showDivider;
  final FormSectionWidgetStyle style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompact = style == FormSectionWidgetStyle.compact;

    return Material(
      color: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
        side: BorderSide(color: AppColors.ghostBorder(0.08)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
          boxShadow: isCompact
              ? null
              : SanctuaryDepth.ambient(opacity: 0.03, blur: 20),
        ),
        child: Padding(
          padding: EdgeInsets.all(isCompact ? 14.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: isCompact ? 40.0 : 44.0,
                    height: isCompact ? 40.0 : 44.0,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      border: isCompact
                          ? Border.all(color: AppColors.ghostBorder(0.08))
                          : null,
                      borderRadius: BorderRadius.circular(
                        SanctuaryLayout.radius,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 18.0, color: AppColors.primary),
                  ),
                  Gap.w12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        if (subtitle != null) ...[
                          Gap.h4,
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodyMedium!.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (isCompact) ...[Gap.h12, Gap.h2] else Gap.h16,
              ...children,
              if (showDivider)
                if (isCompact)
                  Gap.h4
                else ...[
                  Gap.h16,
                  Container(
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(
                        SanctuaryLayout.pillRadius,
                      ),
                    ),
                  ),
                ],
            ],
          ),
        ),
      ),
    );
  }
}
