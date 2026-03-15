import 'dart:async';

import 'package:flutter/material.dart';

class DashboardReveal extends StatefulWidget {
  const DashboardReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 360),
    this.offset = const Offset(0, 0.04),
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;

  @override
  State<DashboardReveal> createState() => _DashboardRevealState();
}

class _DashboardRevealState extends State<DashboardReveal> {
  Timer? _timer;
  var _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.delay == Duration.zero) {
        setState(() => _visible = true);
        return;
      }
      _timer = Timer(widget.delay, () {
        if (!mounted) return;
        setState(() => _visible = true);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    final reduceMotion =
        (mediaQuery?.disableAnimations ?? false) ||
        (mediaQuery?.accessibleNavigation ?? false);

    if (reduceMotion) {
      return widget.child;
    }

    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : widget.offset,
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class DashboardAnimatedPresence extends StatelessWidget {
  const DashboardAnimatedPresence({
    super.key,
    required this.visible,
    required this.child,
    this.duration = const Duration(milliseconds: 280),
    this.offset = const Offset(0, 0.03),
  });

  final bool visible;
  final Widget child;
  final Duration duration;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    final reduceMotion =
        (mediaQuery?.disableAnimations ?? false) ||
        (mediaQuery?.accessibleNavigation ?? false);

    return AnimatedSwitcher(
      duration: reduceMotion ? Duration.zero : duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeOutCubic,
      transitionBuilder: (child, animation) {
        if (reduceMotion) {
          return child;
        }

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(begin: offset, end: Offset.zero).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
      child: visible
          ? KeyedSubtree(key: const ValueKey('visible'), child: child)
          : const SizedBox.shrink(key: ValueKey('hidden')),
    );
  }
}
