import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/palakat_tema.dart';
import 'router.dart';

/// The Palakat demo app (README 3.1): light and dark follow the system, and
/// reduce motion is the system's `MediaQuery.disableAnimations`.
class PalakatApp extends ConsumerWidget {
  const PalakatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: 'Palakat',
    debugShowCheckedModeBanner: false,
    theme: palakatTema(Brightness.light),
    darkTheme: palakatTema(Brightness.dark),
    routerConfig: ref.watch(routerProvider),
  );
}
