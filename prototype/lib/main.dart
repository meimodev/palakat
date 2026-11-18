import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';
import 'shell/bingkai_perangkat.dart';
import 'shell/prototipe_state.dart';
import 'theme/palakat_tema.dart';

void main() {
  // A push shows its own URL and adds a browser history entry (navigation.md 5.4).
  GoRouter.optionURLReflectsImperativeAPIs = true;
  runApp(PalakatPrototipe());
}

class PalakatPrototipe extends StatefulWidget {
  PalakatPrototipe({super.key, GoRouter? router})
    : router = router ?? buatRouter();
  final GoRouter router;

  @override
  State<PalakatPrototipe> createState() => _PalakatPrototipeState();
}

class _PalakatPrototipeState extends State<PalakatPrototipe> {
  final _keadaan = PrototypeState();

  @override
  void dispose() {
    _keadaan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PrototipeLingkup(
    keadaan: _keadaan,
    child: ListenableBuilder(
      listenable: _keadaan,
      builder: (context, _) => MaterialApp.router(
        title: 'Palakat · prototipe',
        debugShowCheckedModeBanner: false,
        theme: palakatTema(Brightness.light),
        darkTheme: palakatTema(Brightness.dark),
        themeMode: _keadaan.tema,
        themeAnimationDuration: _keadaan.kurangiGerak
            ? Duration.zero
            : kThemeAnimationDuration,
        routerConfig: widget.router,
        builder: (context, child) {
          final mq = MediaQuery.of(context);
          // Reduce motion from the panel, applied once at the root (components.md 1.5).
          return MediaQuery(
            data: mq.copyWith(
              disableAnimations: mq.disableAnimations || _keadaan.kurangiGerak,
            ),
            // The panel's links run outside the router's own subtree.
            child: InheritedGoRouter(
              goRouter: widget.router,
              child: BingkaiPerangkat(router: widget.router, child: child!),
            ),
          );
        },
      ),
    ),
  );
}
