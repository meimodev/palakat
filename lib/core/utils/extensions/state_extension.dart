import 'dart:async';
import 'package:flutter/material.dart';

extension SafeSetStateExtension on State {
  /// [INFO]
  /// [safeSetState] consider using this extension than [setState] from
  /// StatefulWidget to avoid error setState during build.
  FutureOr<void> safeSetState(FutureOr<dynamic> Function() fn) async {
    await fn();
    if (mounted) {
      // ignore: invalid_use_of_protected_member
      setState(() {});
    }
  }

  FutureOr<void> safeRebuild(Function() fn) async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fn.call();
    });
  }
}
