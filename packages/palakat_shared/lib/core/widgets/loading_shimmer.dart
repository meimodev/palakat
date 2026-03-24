import 'package:flutter/material.dart';
import 'package:palakat_shared/core/theme/theme.dart';

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
      begin: -0.3,
      end: 1.3,
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
    final baseColor =
        widget.baseColor ??
        theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.92);
    final highlightColor =
        widget.highlightColor ??
        theme.colorScheme.surface.withValues(alpha: 0.98);

    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final center = _animation.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                (center - 0.28).clamp(0.0, 1.0),
                center.clamp(0.0, 1.0),
                (center + 0.28).clamp(0.0, 1.0),
              ],
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
        color: AppColors.surfaceContainerLowest,
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
        color: AppColors.surfaceContainerLowest,
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
                color: AppColors.surfaceContainerLowest,
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
            color: AppColors.surfaceContainerLowest,
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
              color: AppColors.surfaceContainerLowest,
              border: Border(
                bottom: BorderSide(color: AppColors.onSurfaceVariant, width: 1),
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

  static Widget button({
    double? width,
    double height = 48,
    BorderRadius? borderRadius,
    bool expanded = false,
  }) {
    return _surfaceBlock(
      width: expanded ? double.infinity : width ?? 132,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(14),
    );
  }

  static Widget input({
    double? width,
    double height = 48,
    bool includeLabel = false,
    double labelWidth = 96,
    BorderRadius? borderRadius,
  }) {
    final field = _surfaceBlock(
      width: width ?? double.infinity,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(14),
    );

    if (!includeLabel) {
      return field;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        text(width: labelWidth, height: 12),
        const SizedBox(height: 8),
        field,
      ],
    );
  }

  static Widget sectionHeader({
    double titleWidth = 160,
    double subtitleWidth = 96,
    bool includeTrailing = true,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              text(width: titleWidth, height: 16),
              const SizedBox(height: 8),
              text(width: subtitleWidth, height: 12),
            ],
          ),
        ),
        if (includeTrailing) ...[
          const SizedBox(width: 16),
          button(
            width: 88,
            height: 36,
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ],
    );
  }

  static Widget pageHeader({
    double titleWidth = 220,
    double subtitleWidth = 144,
    bool includeAction = true,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              text(width: titleWidth, height: 24),
              const SizedBox(height: 12),
              text(width: subtitleWidth, height: 14),
            ],
          ),
        ),
        if (includeAction) ...[
          const SizedBox(width: 16),
          button(
            width: 108,
            height: 40,
            borderRadius: BorderRadius.circular(14),
          ),
        ],
      ],
    );
  }

  static Widget buttonRow({
    int count = 2,
    double gap = 12,
    double height = 44,
  }) {
    return Row(
      children: List.generate(count * 2 - 1, (index) {
        if (index.isOdd) {
          return SizedBox(width: gap);
        }

        return Expanded(
          child: button(
            expanded: true,
            height: height,
            borderRadius: BorderRadius.circular(14),
          ),
        );
      }),
    );
  }

  static Widget detailSection({
    bool includeHeader = true,
    bool includeWideBlock = false,
    bool includeTrailing = false,
  }) {
    final children = <Widget>[
      if (includeHeader)
        sectionHeader(
          titleWidth: 180,
          subtitleWidth: 120,
          includeTrailing: includeTrailing,
        ),
      Row(
        children: [
          Expanded(child: text(width: double.infinity, height: 16)),
          const SizedBox(width: 16),
          Expanded(child: text(width: double.infinity, height: 16)),
        ],
      ),
      if (includeWideBlock) input(height: 48),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: _withGaps(children, 16),
    );
  }

  static Widget formSection({
    int fields = 2,
    bool includeHeader = true,
    bool includePrimaryButton = true,
    bool includeSecondaryButton = false,
  }) {
    final children = <Widget>[
      if (includeHeader) sectionHeader(includeTrailing: false),
      ...List.generate(fields, (index) => input(includeLabel: index == 0)),
      if (includePrimaryButton)
        includeSecondaryButton ? buttonRow() : button(expanded: true),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: _withGaps(children, 12),
    );
  }

  static Widget tableSection({
    int rows = 5,
    int columns = 4,
    bool includeSearch = false,
    bool includeFilters = false,
  }) {
    final children = <Widget>[
      if (includeSearch) input(height: 48),
      if (includeFilters) buttonRow(height: 40),
      table(rows: rows, columns: columns),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: _withGaps(children, 16),
    );
  }

  static Widget pageLayout({
    int sections = 3,
    bool includeHeader = true,
    bool includeSummaryCard = true,
    Widget? sectionPlaceholder,
  }) {
    final children = <Widget>[
      if (includeHeader) pageHeader(),
      if (includeSummaryCard) simpleCard(height: 132),
      ...List.generate(
        sections,
        (_) => sectionPlaceholder ?? simpleCard(height: 108),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: _withGaps(children, 16),
    );
  }

  static Widget listSection({int count = 3, double gap = 8}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _withGaps(List.generate(count, (_) => listItemCard()), gap),
    );
  }

  static Widget activitySection({int count = 3, double gap = 8}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _withGaps(List.generate(count, (_) => activityCard()), gap),
    );
  }

  static Widget approvalSection({int count = 3, double gap = 20}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _withGaps(List.generate(count, (_) => approvalCard()), gap),
    );
  }

  static Widget infoSection({int count = 3, double gap = 12}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _withGaps(List.generate(count, (_) => infoCard()), gap),
    );
  }

  static Widget listTileSection({int count = 3, double gap = 6}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _withGaps(List.generate(count, (_) => listTile()), gap),
    );
  }

  static Widget operationsOverview() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _withGaps([
        membershipCard(),
        listItemCard(),
        listItemCard(),
      ], 16),
    );
  }

  static Widget approvalDetailLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _withGaps([infoCard(), infoCard(), approvalCard()], 12),
    );
  }

  static Widget activityDetailLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: _withGaps([
        activityCard(),
        infoCard(),
        listItemCard(),
        infoCard(),
      ], 16),
    );
  }

  static Widget membershipCard() {
    return _surfacePanel(
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _surfaceBlock(
                width: 40,
                height: 40,
                borderRadius: BorderRadius.circular(12),
                color: _panelBlockColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _surfaceBlock(
                      width: double.infinity,
                      height: 16,
                      color: _panelBlockColor,
                    ),
                    const SizedBox(height: 8),
                    _surfaceBlock(
                      width: 120,
                      height: 12,
                      color: _panelBlockColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _surfaceBlock(
                  width: double.infinity,
                  height: 40,
                  borderRadius: BorderRadius.circular(8),
                  color: _panelBlockColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _surfaceBlock(
                  width: double.infinity,
                  height: 40,
                  borderRadius: BorderRadius.circular(8),
                  color: _panelBlockColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget activityCard({double? height}) {
    return _surfacePanel(
      height: height ?? 92,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _surfaceBlock(
                width: 32,
                height: 32,
                borderRadius: BorderRadius.circular(999),
                color: _panelBlockColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _surfaceBlock(
                      width: double.infinity,
                      height: 16,
                      color: _panelBlockColor,
                    ),
                    const SizedBox(height: 6),
                    _surfaceBlock(
                      width: 80,
                      height: 12,
                      color: _panelBlockColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          _surfaceBlock(width: 100, height: 12, color: _panelBlockColor),
        ],
      ),
    );
  }

  static Widget listItemCard() {
    return _surfacePanel(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _surfaceBlock(
            width: 32,
            height: 32,
            borderRadius: BorderRadius.circular(999),
            color: _panelBlockColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _surfaceBlock(
                  width: double.infinity,
                  height: 16,
                  color: _panelBlockColor,
                ),
                const SizedBox(height: 6),
                _surfaceBlock(width: 120, height: 12, color: _panelBlockColor),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _surfaceBlock(
            width: 20,
            height: 20,
            borderRadius: BorderRadius.circular(999),
            color: _panelBlockColor,
          ),
        ],
      ),
    );
  }

  static Widget announcementCard() {
    return _surfacePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _surfaceBlock(
                width: 40,
                height: 40,
                borderRadius: BorderRadius.circular(999),
                color: _panelBlockColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _surfaceBlock(
                      width: double.infinity,
                      height: 16,
                      color: _panelBlockColor,
                    ),
                    const SizedBox(height: 6),
                    _surfaceBlock(
                      width: 100,
                      height: 12,
                      color: _panelBlockColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _surfaceBlock(
            width: double.infinity,
            height: 12,
            color: _panelBlockColor,
          ),
          const SizedBox(height: 6),
          _surfaceBlock(width: 200, height: 12, color: _panelBlockColor),
        ],
      ),
    );
  }

  static Widget approvalCard() {
    return _surfacePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _surfaceBlock(
                width: 40,
                height: 40,
                borderRadius: BorderRadius.circular(999),
                color: _panelBlockColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _surfaceBlock(
                      width: double.infinity,
                      height: 16,
                      color: _panelBlockColor,
                    ),
                    const SizedBox(height: 8),
                    _surfaceBlock(
                      width: 150,
                      height: 12,
                      color: _panelBlockColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _surfaceBlock(
            width: double.infinity,
            height: 12,
            color: _panelBlockColor,
          ),
          const SizedBox(height: 8),
          _surfaceBlock(
            width: double.infinity,
            height: 12,
            color: _panelBlockColor,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _surfaceBlock(
                  width: double.infinity,
                  height: 24,
                  borderRadius: BorderRadius.circular(12),
                  color: _panelBlockColor,
                ),
              ),
              const SizedBox(width: 8),
              _surfaceBlock(
                width: 80,
                height: 24,
                borderRadius: BorderRadius.circular(12),
                color: _panelBlockColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget infoCard() {
    return _surfacePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _surfaceBlock(
                width: 40,
                height: 40,
                borderRadius: BorderRadius.circular(999),
                color: _panelBlockColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _surfaceBlock(
                  width: double.infinity,
                  height: 16,
                  color: _panelBlockColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(3 * 2 - 1, (index) {
            if (index.isOdd) {
              return const SizedBox(height: 12);
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _surfaceBlock(
                  width: 20,
                  height: 20,
                  borderRadius: BorderRadius.circular(999),
                  color: _panelBlockColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _surfaceBlock(
                        width: 80,
                        height: 12,
                        color: _panelBlockColor,
                      ),
                      const SizedBox(height: 6),
                      _surfaceBlock(
                        width: double.infinity,
                        height: 16,
                        color: _panelBlockColor,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// Simple card placeholder for generic use cases
  static Widget simpleCard({
    double? width,
    double height = 120,
    EdgeInsets padding = const EdgeInsets.all(16),
    Color? backgroundColor,
    Color? placeholderColor,
  }) {
    final bgColor = backgroundColor ?? AppColors.surfaceContainerLowest;
    final phColor = placeholderColor ?? AppColors.onSurfaceVariant;

    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 20,
            width: double.infinity,
            decoration: BoxDecoration(
              color: phColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 14,
            width: 200,
            decoration: BoxDecoration(
              color: phColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 14,
            width: 150,
            decoration: BoxDecoration(
              color: phColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Container(
                height: 12,
                width: 80,
                decoration: BoxDecoration(
                  color: phColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Spacer(),
              Container(
                height: 12,
                width: 60,
                decoration: BoxDecoration(
                  color: phColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _surfacePanel({
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    BorderRadius? borderRadius,
    Color? backgroundColor,
  }) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(12);
    final panel = Material(
      clipBehavior: Clip.hardEdge,
      elevation: 0,
      shadowColor: AppColors.onSurface.withValues(alpha: 0.02),
      surfaceTintColor: Colors.transparent,
      color:
          backgroundColor ??
          AppColors.surfaceContainerLow.withValues(alpha: 0.58),
      shape: RoundedRectangleBorder(
        borderRadius: effectiveBorderRadius,
        side: BorderSide(width: 1, color: AppColors.ghostBorder(0.06)),
      ),
      child: Padding(padding: padding, child: child),
    );

    if (width == null && height == null) {
      return panel;
    }

    return SizedBox(width: width, height: height, child: panel);
  }

  static Widget _surfaceBlock({
    double? width,
    required double height,
    BorderRadius? borderRadius,
    Color? color,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? _surfaceBlockColor,
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
    );
  }

  static List<Widget> _withGaps(List<Widget> children, double gap) {
    if (children.isEmpty) {
      return const <Widget>[];
    }

    return List.generate(children.length * 2 - 1, (index) {
      if (index.isOdd) {
        return SizedBox(height: gap);
      }

      return children[index ~/ 2];
    });
  }

  static Color get _surfaceBlockColor =>
      AppColors.surfaceContainerLowest.withValues(alpha: 0.98);

  static Color get _panelBlockColor => Colors.white;
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
