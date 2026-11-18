import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../theme/palakat_tokens.dart';
import 'gerak.dart';

/// Page builder for every route (motion.md, "Screen change and page transitions").
/// Back and pop are instant everywhere.
Page<void> halaman(
  BuildContext context,
  GoRouterState state,
  Widget child, {
  Bingkai? kerangka,
  Duration lama = PalakatMotion.pindahLayar,
  Curve kurva = PalakatMotion.keluar,
}) {
  final d = PalakatMotion.atau(context, lama);
  if (kerangka == null || d == Duration.zero) {
    return NoTransitionPage<void>(key: state.pageKey, child: child);
  }
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: d,
    reverseTransitionDuration: Duration.zero,
    transitionsBuilder: (ctx, anim, _, c) =>
        AnimatedBuilder(animation: anim, builder: (ctx, _) => kerangka(ctx, anim.value, kurva, c)),
  );
}
