import 'dart:io';

import 'package:flutter/services.dart';

class ExactAlarmPermissionService {
  static const MethodChannel _channel = MethodChannel('palakat/exact_alarm');

  Future<bool> canScheduleExactAlarms() async {
    if (!Platform.isAndroid) return true;

    final result = await _channel.invokeMethod<bool>('canScheduleExactAlarms');
    return result ?? true;
  }

  Future<void> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod<void>('requestExactAlarmPermission');
  }

  Future<bool> canUseFullScreenIntent() async {
    if (!Platform.isAndroid) return true;

    try {
      final result = await _channel.invokeMethod<bool>(
        'canUseFullScreenIntent',
      );
      return result ?? true;
    } on MissingPluginException {
      return true;
    } on PlatformException {
      return true;
    }
  }

  Future<void> requestFullScreenIntentPermission() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('requestFullScreenIntentPermission');
    } on MissingPluginException {
      return;
    } on PlatformException {
      return;
    }
  }
}
