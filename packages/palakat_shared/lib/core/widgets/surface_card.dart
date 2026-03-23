import 'package:flutter/material.dart';

import '../theme/theme.dart';

class SurfaceCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;
  const SurfaceCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
        boxShadow: SanctuaryDepth.ambient(opacity: 0.035, blur: 28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || subtitle != null || trailing != null) ...[
            LayoutBuilder(
              builder: (context, constraints) {
                final titleBlock = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: theme.textTheme.titleLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                );

                if (trailing == null || constraints.maxWidth >= 560) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: titleBlock),
                      if (trailing != null) ...[
                        const SizedBox(width: 12),
                        Flexible(child: trailing!),
                      ],
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleBlock,
                    if (trailing != null) ...[
                      const SizedBox(height: 12),
                      trailing!,
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 14),
          ],
          child,
        ],
      ),
    );
  }
}
