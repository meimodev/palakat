import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/theme/theme.dart';
import 'package:palakat_shared/core/widgets/loading_shimmer.dart';

/// Reusable quick statistic card with built-in shimmer loading
class QuickStatCard extends StatelessWidget {
  const QuickStatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    this.subtitle,
    this.isLoading = false,
    this.width = 200,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final String? subtitle;
  final bool isLoading;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedIconBackgroundColor =
        iconBackgroundColor ?? AppColors.surfaceContainerHigh;
    final resolvedIconColor = () {
      final desiredColor = iconColor ?? theme.colorScheme.primary;
      if (desiredColor.value != resolvedIconBackgroundColor.value) {
        return desiredColor;
      }

      return ThemeData.estimateBrightnessForColor(
                resolvedIconBackgroundColor,
              ) ==
              Brightness.dark
          ? Colors.white
          : Colors.black87;
    }();

    Widget buildContent() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: isLoading
                    ? _shimmerBlock(height: 12, width: 80, borderRadius: 3)
                    : Text(
                        label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
              const SizedBox(width: 12),
              if (icon != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: resolvedIconBackgroundColor,
                    borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
                  ),
                  child: Icon(icon!, size: 18, color: resolvedIconColor),
                ),
            ],
          ),
          const SizedBox(height: 16),
          isLoading
              ? _shimmerBlock(height: 28, width: 60, borderRadius: 6)
              : Text(
                  value.toThousands(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            isLoading
                ? _shimmerBlock(height: 10, width: 120, borderRadius: 3)
                : Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : width;
        final resolvedWidth = math.min(width, availableWidth);

        return Container(
          width: resolvedWidth,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
            boxShadow: SanctuaryDepth.ambient(opacity: 0.032, blur: 24),
          ),
          child: isLoading
              ? LoadingShimmer(isLoading: true, child: buildContent())
              : buildContent(),
        );
      },
    );
  }

  Widget _shimmerBlock({
    required double height,
    required double width,
    double borderRadius = 4,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
