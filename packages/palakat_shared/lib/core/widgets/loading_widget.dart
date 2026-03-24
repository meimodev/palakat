import 'package:flutter/material.dart';
import 'package:palakat_shared/core/theme/theme.dart';

import 'loading_shimmer.dart';

/// Reusable loading widget for displaying loading states consistently across the app
class AppLoadingWidget extends StatelessWidget {
  final String? message;
  final double? size;

  const AppLoadingWidget({super.key, this.message, this.size});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorSize = size ?? 48;
    final cardWidth = (indicatorSize * 5.5).clamp(220.0, 320.0).toDouble();
    final cardHeight = message == null ? 104.0 : 124.0;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingShimmer(
            isLoading: true,
            child: ShimmerPlaceholders.simpleCard(
              width: cardWidth,
              height: cardHeight,
              padding: EdgeInsets.symmetric(
                horizontal: indicatorSize * 0.42,
                vertical: indicatorSize * 0.34,
              ),
              backgroundColor: AppColors.surfaceContainerLow,
              placeholderColor: AppColors.surfaceContainerHighest.withValues(
                alpha: 0.92,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Compact loading widget for inline loading display
class CompactLoadingWidget extends StatelessWidget {
  final String? message;
  final double size;
  final Color? baseColor;
  final Color? highlightColor;

  const CompactLoadingWidget({
    super.key,
    this.message,
    this.size = 16,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBaseColor =
        baseColor ?? AppColors.surfaceContainerHighest.withValues(alpha: 0.92);
    final effectiveHighlightColor =
        highlightColor ?? AppColors.surface.withValues(alpha: 0.98);

    final indicator = LoadingShimmer(
      isLoading: true,
      baseColor: effectiveBaseColor,
      highlightColor: effectiveHighlightColor,
      child: _LoadingGlyph(size: size, color: effectiveBaseColor),
    );

    if (message == null) {
      return indicator;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        indicator,
        const SizedBox(width: 8),
        Text(
          message!,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Shimmer loading widget for skeleton loading states
class ShimmerLoadingWidget extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerLoadingWidget({
    super.key,
    required this.child,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingShimmer(isLoading: isLoading, child: child);
  }
}

class _LoadingGlyph extends StatelessWidget {
  const _LoadingGlyph({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final width = size * 1.8;

    return SizedBox(
      width: width,
      height: size,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _LoadingBar(width: size * 0.28, height: size * 0.58, color: color),
          _LoadingBar(width: size * 0.28, height: size, color: color),
          _LoadingBar(width: size * 0.28, height: size * 0.74, color: color),
        ],
      ),
    );
  }
}

class _LoadingBar extends StatelessWidget {
  const _LoadingBar({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
