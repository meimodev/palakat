import 'package:flutter/material.dart';
import 'package:palakat_shared/core/extension/extension.dart';
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
                      ),
              ),
              const SizedBox(width: 12),
              if (icon != null)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconBackgroundColor ?? theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    icon!,
                    size: 16,
                    color: iconColor ?? theme.colorScheme.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          isLoading
              ? _shimmerBlock(height: 28, width: 60, borderRadius: 6)
              : Text(
                  value.toThousands(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
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
                  ),
          ],
        ],
      );
    }

    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isLoading
          ? LoadingShimmer(
              isLoading: true,
              child: buildContent(),
            )
          : buildContent(),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
