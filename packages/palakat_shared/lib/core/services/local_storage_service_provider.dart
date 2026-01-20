import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat_shared/core/services/local_storage_service.dart';

part 'local_storage_service_provider.g.dart';

@Riverpod(keepAlive: true)
LocalStorageService localStorageService(Ref ref) {
  // Ensure this provider is kept alive to avoid creating multiple AuthService instances
  // which could lead to losing the cached _auth between reads.
  // This prevents auto-disposal when not listened to.
  // ignore: deprecated_member_use
  ref.keepAlive();
  final service = LocalStorageService();
  // Load cache synchronously (Hive box is opened in main), then fire-and-forget init
  service.loadFromCacheSync();
  service.init();
  return service;
}

final authMembershipChangeSignalProvider = StreamProvider<int>((ref) async* {
  if (!Hive.isBoxOpen('auth')) {
    await Hive.openBox('auth');
  }

  final box = Hive.box('auth');

  var tick = 0;
  yield tick;

  final controller = StreamController<int>();

  void emit() {
    tick += 1;
    if (!controller.isClosed) {
      controller.add(tick);
    }
  }

  final authSub = box.watch(key: 'auth.response').listen((_) => emit());
  final membershipSub = box.watch(key: 'membership').listen((_) => emit());

  ref.onDispose(() {
    authSub.cancel();
    membershipSub.cancel();
    controller.close();
  });

  yield* controller.stream;
});
