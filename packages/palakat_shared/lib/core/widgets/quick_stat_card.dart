import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/theme/theme.dart';
import 'package:palakat_shared/core/widgets/loading_shimmer.dart';

/// Presentation density for QuickStatCard
enum QuickStatDensity {
  /// Standard comfortable spacing (default)
  comfortable,

  /// Tighter spacing for showing more cards in limited space
  compact,
}

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
    this.density = QuickStatDensity.comfortable,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final String? subtitle;
  final bool isLoading;
  final double width;
  final QuickStatDensity density;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompact = density == QuickStatDensity.compact;
    final resolvedIconBackgroundColor =
        iconBackgroundColor ?? AppColors.surfaceContainerHigh;
    final resolvedIconColor = () {
      final desiredColor = iconColor ?? theme.colorScheme.primary;
      if (desiredColor.toARGB32() != resolvedIconBackgroundColor.toARGB32()) {
        return desiredColor;
      }

      return ThemeData.estimateBrightnessForColor(
                resolvedIconBackgroundColor,
              ) ==
              Brightness.dark
          ? Colors.white
          : Colors.black87;
    }();

    final iconSize = isCompact ? 16.0 : 18.0;
    final iconPadding = isCompact ? 6.0 : 8.0;
    final cardPadding = isCompact ? 14.0 : 18.0;
    final labelValueSpacing = isCompact ? 12.0 : 16.0;
    final labelIconSpacing = isCompact ? 8.0 : 12.0;
    final subtitleSpacing = isCompact ? 2.0 : 4.0;
    final valueTextStyle = isCompact
        ? theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)
        : theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700);

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
                    ? _shimmerBlock(
                        height: isCompact ? 10 : 12,
                        width: 80,
                        borderRadius: 3,
                      )
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
              SizedBox(width: labelIconSpacing),
              if (icon != null)
                Container(
                  padding: EdgeInsets.all(iconPadding),
                  decoration: BoxDecoration(
                    color: resolvedIconBackgroundColor,
                    borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
                  ),
                  child: Icon(icon!, size: iconSize, color: resolvedIconColor),
                ),
            ],
          ),
          SizedBox(height: labelValueSpacing),
          isLoading
              ? _shimmerBlock(
                  height: isCompact ? 24 : 28,
                  width: 60,
                  borderRadius: 6,
                )
              : Text(
                  value.toThousands(),
                  style: valueTextStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
          if (subtitle != null) ...[
            SizedBox(height: subtitleSpacing),
            isLoading
                ? _shimmerBlock(
                    height: isCompact ? 8 : 10,
                    width: 120,
                    borderRadius: 3,
                  )
                : Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: isCompact ? 11 : null,
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
          padding: EdgeInsets.all(cardPadding),
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
