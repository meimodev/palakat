import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';
import 'theme/palakat_tema.dart';

void main() {
  GoRouter.optionURLReflectsImperativeAPIs = true;
  runApp(PalakatPrototipe());
}

class PalakatPrototipe extends StatelessWidget {
  PalakatPrototipe({super.key, GoRouter? router}) : router = router ?? buatRouter();
  final GoRouter router;

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Palakat · prototipe',
        debugShowCheckedModeBanner: false,
        theme: palakatTema(Brightness.light),
        darkTheme: palakatTema(Brightness.dark),
        themeMode: ThemeMode.light,
        routerConfig: router,
      );
}
