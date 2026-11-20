import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app/app.dart';

void main() {
  // A push shows its own URL and adds a browser history entry (navigation.md 5.4).
  GoRouter.optionURLReflectsImperativeAPIs = true;
  runApp(const ProviderScope(child: PalakatApp()));
}
