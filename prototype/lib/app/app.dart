import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/tema.dart';
import '../theme/palakat_tema.dart';
import 'router.dart';

/// The Palakat demo app (README 3.1): light by default, dark from the
/// "Tema gelap" switch ([temaProvider]); reduce motion is the system's
/// `MediaQuery.disableAnimations`.
class PalakatApp extends ConsumerWidget {
  const PalakatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(temaProvider);
    return MaterialApp.router(
      title: 'Palakat',
      debugShowCheckedModeBanner: false,
      theme: palakatTema(Brightness.light),
      darkTheme: palakatTema(Brightness.dark),
      themeMode: mode,
      // Every screen sits below the status bar and above the gesture bar, on
      // `kertas`, with bar icons readable in either theme. On web the insets
      // are zero.
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: mode == ThemeMode.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: ColoredBox(
          color: context.warna.kertas,
          child: SafeArea(child: child!),
        ),
      ),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
