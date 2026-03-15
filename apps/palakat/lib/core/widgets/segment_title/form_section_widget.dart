import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';

class FormSectionWidget extends StatelessWidget {
  const FormSectionWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.subtitle,
    this.showDivider = true,
  });

  final String title;
  final IconData icon;
  final String? subtitle;
  final List<Widget> children;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(BaseSize.w6),
              decoration: BoxDecoration(
                color: BaseColor.primary[50],
                borderRadius: BorderRadius.circular(BaseSize.radiusSm),
              ),
              child: Icon(
                icon,
                size: BaseSize.w16,
                color: BaseColor.primary[600],
              ),
            ),
            Gap.w8,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: BaseTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: BaseColor.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    Gap.h2,
                    Text(
                      subtitle!,
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
        Gap.h12,
        ...children,
        if (showDivider) ...[
          Gap.h8,
          Divider(color: BaseColor.neutral[200]),
          Gap.h8,
        ],
      ],
    );
  }
}
