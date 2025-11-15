import 'package:flutter/material.dart';

/// A shimmer loading effect widget for smooth content transitions
class LoadingShimmer extends StatefulWidget {
  const LoadingShimmer({
    super.key,
    required this.child,
    this.isLoading = true,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  @override
  State<LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(LoadingShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = widget.baseColor ??
        theme.colorScheme.primaryContainer.withValues(alpha: 0.35);
    final highlightColor = widget.highlightColor ??
        theme.colorScheme.secondaryContainer.withValues(alpha: 0.85);

    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [0.0, 0.5, 1.0],
              transform: GradientRotation(_animation.value * 3.14159),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Shimmer placeholder widgets for common UI elements
class ShimmerPlaceholders {
  static Widget text({
    double width = 100,
    double height = 16,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
    );
  }

  static Widget card({
    double? width,
    double height = 120,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text(width: double.infinity, height: 20),
          const SizedBox(height: 8),
          text(width: 200, height: 14),
          const SizedBox(height: 8),
          text(width: 150, height: 14),
          const Spacer(),
          Row(
            children: [
              text(width: 80, height: 12),
              const Spacer(),
              text(width: 60, height: 12),
            ],
          ),
        ],
      ),
    );
  }

  static Widget listTile({
    bool hasLeading = true,
    bool hasSubtitle = true,
    bool hasTrailing = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (hasLeading) ...[
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text(width: double.infinity, height: 16),
                if (hasSubtitle) ...[
                  const SizedBox(height: 4),
                  text(width: 200, height: 12),
                ],
              ],
            ),
          ),
          if (hasTrailing) ...[
            const SizedBox(width: 16),
            text(width: 60, height: 14),
          ],
        ],
      ),
    );
  }

  static Widget table({int rows = 5, int columns = 4}) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Row(
            children: List.generate(
              columns,
              (index) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index < columns - 1 ? 16 : 0),
                  child: text(width: double.infinity, height: 14),
                ),
              ),
            ),
          ),
        ),
        // Rows
        ...List.generate(
          rows,
          (rowIndex) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: List.generate(
                columns,
                (colIndex) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: colIndex < columns - 1 ? 16 : 0,
                    ),
                    child: text(width: double.infinity, height: 12),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A smooth transition widget that shows shimmer while loading and fades to content
class SmoothContentTransition extends StatefulWidget {
  const SmoothContentTransition({
    super.key,
    required this.isLoading,
    required this.loadingWidget,
    required this.contentWidget,
    this.duration = const Duration(milliseconds: 300),
  });

  final bool isLoading;
  final Widget loadingWidget;
  final Widget contentWidget;
  final Duration duration;

  @override
  State<SmoothContentTransition> createState() =>
      _SmoothContentTransitionState();
}

class _SmoothContentTransitionState extends State<SmoothContentTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (!widget.isLoading) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(SmoothContentTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Loading shimmer
            Opacity(
              opacity: 1.0 - _fadeAnimation.value,
              child: LoadingShimmer(
                isLoading: widget.isLoading,
                child: widget.loadingWidget,
              ),
            ),
            // Actual content
            Opacity(opacity: _fadeAnimation.value, child: widget.contentWidget),
          ],
        );
      },
    );
  }
}
