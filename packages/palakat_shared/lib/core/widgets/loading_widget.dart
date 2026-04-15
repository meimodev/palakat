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
    final cardHeight = message == null ? 124.0 : 144.0;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingShimmer(
            isLoading: true,
            child: ShimmerPlaceholders.blockingCard(
              width: cardWidth,
              height: cardHeight,
            ),
          ),
          if (message != null) ...[
            Gap.h16,
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
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;

  const CompactLoadingWidget({
    super.key,
    this.message,
    this.size = 16,
    this.baseColor,
    this.highlightColor,
    this.backgroundColor,
    this.borderColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBaseColor =
        baseColor ?? theme.colorScheme.primary.withValues(alpha: 0.28);
    final effectiveHighlightColor =
        highlightColor ?? theme.colorScheme.primary.withValues(alpha: 0.96);
    final effectiveBackgroundColor =
        backgroundColor ??
        theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.78);
    final effectiveBorderColor =
        borderColor ?? theme.colorScheme.outlineVariant.withValues(alpha: 0.42);
    final indicatorStrokeWidth = (size * 0.14).clamp(1.6, 2.6).toDouble();

    final indicator = SizedBox.square(
      dimension: size,
      child: CircularProgressIndicator(
        strokeWidth: indicatorStrokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(effectiveHighlightColor),
        backgroundColor: effectiveBaseColor,
      ),
    );

    final shell = Container(
      constraints: BoxConstraints(minWidth: size * 2.5, minHeight: size * 2.25),
      padding:
          padding ??
          EdgeInsets.symmetric(horizontal: size * 0.42, vertical: size * 0.34),
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(size * 0.95),
        border: Border.all(color: effectiveBorderColor),
      ),
      child: Center(child: indicator),
    );

    if (message == null) {
      return shell;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [shell, Gap.w6, Text(message!)],
    );
  }
}

class LoadingActionContent extends StatelessWidget {
  const LoadingActionContent({
    super.key,
    required this.isLoading,
    required this.child,
    this.loaderSize = 18,
    this.loaderBaseColor,
    this.loaderHighlightColor,
    this.loaderBackgroundColor,
    this.loaderBorderColor,
    this.duration = const Duration(milliseconds: 180),
  });

  final bool isLoading;
  final Widget child;
  final double loaderSize;
  final Color? loaderBaseColor;
  final Color? loaderHighlightColor;
  final Color? loaderBackgroundColor;
  final Color? loaderBorderColor;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IgnorePointer(
          ignoring: isLoading,
          child: AnimatedOpacity(
            opacity: isLoading ? 0 : 1,
            duration: duration,
            child: child,
          ),
        ),
        if (isLoading)
          CompactLoadingWidget(
            size: loaderSize,
            baseColor: loaderBaseColor,
            highlightColor: loaderHighlightColor,
            backgroundColor: loaderBackgroundColor,
            borderColor: loaderBorderColor,
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
