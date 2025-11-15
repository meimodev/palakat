import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat_shared/core/constants/enums.dart';

/// Custom page transition builder that provides smooth and elegant transitions
class SmoothPageTransition<T> extends CustomTransitionPage<T> {
  const SmoothPageTransition({
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
    super.key,
    this.transitionType = PageTransitionType.fadeWithScale,
  }) : super(
         transitionsBuilder: _buildTransition,
         transitionDuration: const Duration(
           milliseconds: 500,
         ), // Slower for more elegant feel
         reverseTransitionDuration: const Duration(milliseconds: 100),
       );

  final PageTransitionType transitionType;

  static Widget _buildTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Use fadeWithScale as default transition type for all pages
    return _buildFadeWithScaleTransition(animation, secondaryAnimation, child);
  }

  static Widget _buildFadeWithScaleTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Use a smoother, more performant curve
    const curve = Curves.easeOutQuart;

    final fadeAnimation = CurvedAnimation(parent: animation, curve: curve);

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0.1, 0.0), // Slide from left to right
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: curve));

    // Slide + fade transition for smooth left-to-right movement
    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(position: slideAnimation, child: child),
    );
  }
}

// PageTransitionType is now centralized in core/constants/enums.dart

/// Extension to easily create smooth transitions for GoRouter
extension GoRouterSmoothTransitions on GoRoute {
  static GoRoute createWithTransition({
    required String path,
    required String name,
    required Widget Function(BuildContext, GoRouterState) builder,
    PageTransitionType transitionType = PageTransitionType.fadeWithScale,
    List<RouteBase> routes = const <RouteBase>[],
  }) {
    return GoRoute(
      path: path,
      name: name,
      routes: routes,
      pageBuilder: (context, state) => SmoothPageTransition(
        key: state.pageKey,
        name: name,
        arguments: state.extra,
        transitionType: transitionType,
        child: builder(context, state),
      ),
    );
  }
}

/// Optional lightweight page content animator - use sparingly to avoid conflicts
/// This should only be used for specific page content that needs staggered animations
/// NOT for the main page transition (which is handled by SmoothPageTransition)
class PageContentAnimator extends StatefulWidget {
  const PageContentAnimator({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    this.delay = const Duration(milliseconds: 50),
  });

  final Widget child;
  final Duration duration;
  final Duration delay;

  @override
  State<PageContentAnimator> createState() => _PageContentAnimatorState();
}

class _PageContentAnimatorState extends State<PageContentAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _fadeAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Minimal delay to avoid conflicts
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _fadeAnimation, child: widget.child);
  }
}
