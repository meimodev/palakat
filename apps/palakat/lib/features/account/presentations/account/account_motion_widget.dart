import 'dart:async';

import 'package:flutter/material.dart';

class AccountReveal extends StatefulWidget {
  const AccountReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 340),
    this.offset = const Offset(0, 0.04),
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;

  @override
  State<AccountReveal> createState() => _AccountRevealState();
}

class _AccountRevealState extends State<AccountReveal> {
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

class AccountAnimatedPresence extends StatelessWidget {
  const AccountAnimatedPresence({
    super.key,
    required this.visible,
    required this.child,
    this.duration = const Duration(milliseconds: 260),
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
      reverseDuration: reduceMotion ? Duration.zero : duration,
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
