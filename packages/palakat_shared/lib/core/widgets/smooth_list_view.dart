import 'package:flutter/material.dart';
import 'loading_shimmer.dart';

/// A smooth animated ListView that shows shimmer while loading
class SmoothListView extends StatelessWidget {
  const SmoothListView({
    super.key,
    required this.isLoading,
    required this.itemCount,
    required this.itemBuilder,
    this.shimmerItemBuilder,
    this.shimmerItemCount = 5,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.separator,
  });

  final bool isLoading;
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final Widget Function(BuildContext context, int index)? shimmerItemBuilder;
  final int shimmerItemCount;
  final Axis scrollDirection;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final Widget? separator;

  @override
  Widget build(BuildContext context) {
    return SmoothContentTransition(
      isLoading: isLoading,
      loadingWidget: _buildShimmerList(context),
      contentWidget: _buildActualList(context),
    );
  }

  Widget _buildShimmerList(BuildContext context) {
    final shimmerBuilder =
        shimmerItemBuilder ??
        (context, index) => ShimmerPlaceholders.listTile();

    if (separator != null) {
      return ListView.separated(
        scrollDirection: scrollDirection,
        padding: padding,
        physics: physics,
        shrinkWrap: shrinkWrap,
        itemCount: shimmerItemCount,
        itemBuilder: shimmerBuilder,
        separatorBuilder: (context, index) => separator!,
      );
    }

    return ListView.builder(
      scrollDirection: scrollDirection,
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemCount: shimmerItemCount,
      itemBuilder: shimmerBuilder,
    );
  }

  Widget _buildActualList(BuildContext context) {
    if (separator != null) {
      return ListView.separated(
        scrollDirection: scrollDirection,
        padding: padding,
        physics: physics,
        shrinkWrap: shrinkWrap,
        itemCount: itemCount,
        itemBuilder: itemBuilder,
        separatorBuilder: (context, index) => separator!,
      );
    }

    return ListView.builder(
      scrollDirection: scrollDirection,
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}

/// A smooth animated GridView that shows shimmer while loading
class SmoothGridView extends StatelessWidget {
  const SmoothGridView({
    super.key,
    required this.isLoading,
    required this.itemCount,
    required this.itemBuilder,
    required this.gridDelegate,
    this.shimmerItemBuilder,
    this.shimmerItemCount = 8,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  });

  final bool isLoading;
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final SliverGridDelegate gridDelegate;
  final Widget Function(BuildContext context, int index)? shimmerItemBuilder;
  final int shimmerItemCount;
  final Axis scrollDirection;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return SmoothContentTransition(
      isLoading: isLoading,
      loadingWidget: _buildShimmerGrid(context),
      contentWidget: _buildActualGrid(context),
    );
  }

  Widget _buildShimmerGrid(BuildContext context) {
    final shimmerBuilder =
        shimmerItemBuilder ?? (context, index) => ShimmerPlaceholders.card();

    return GridView.builder(
      gridDelegate: gridDelegate,
      scrollDirection: scrollDirection,
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemCount: shimmerItemCount,
      itemBuilder: shimmerBuilder,
    );
  }

  Widget _buildActualGrid(BuildContext context) {
    return GridView.builder(
      gridDelegate: gridDelegate,
      scrollDirection: scrollDirection,
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}

/// A smooth animated widget that provides staggered entrance animations
class StaggeredAnimationWrapper extends StatefulWidget {
  const StaggeredAnimationWrapper({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 100),
    this.animationDuration = const Duration(milliseconds: 600),
  });

  final List<Widget> children;
  final Duration staggerDelay;
  final Duration animationDuration;

  @override
  State<StaggeredAnimationWrapper> createState() =>
      _StaggeredAnimationWrapperState();
}

class _StaggeredAnimationWrapperState extends State<StaggeredAnimationWrapper>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.children.length,
      (index) =>
          AnimationController(duration: widget.animationDuration, vsync: this),
    );

    _fadeAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutQuart),
      );
    }).toList();

    _slideAnimations = _controllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(0.0, 0.1),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutQuart),
      );
    }).toList();

    _startAnimations();
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(widget.staggerDelay * i, () {
        if (mounted) {
          _controllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;

        return FadeTransition(
          opacity: _fadeAnimations[index],
          child: SlideTransition(
            position: _slideAnimations[index],
            child: child,
          ),
        );
      }).toList(),
    );
  }
}
