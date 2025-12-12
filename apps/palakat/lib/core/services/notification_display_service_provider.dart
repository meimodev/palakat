import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'notification_display_service.dart';

part 'notification_display_service_provider.g.dart';

/// Singleton instance of NotificationDisplayService.
///
/// This instance is initialized in main.dart and shared across the app.
/// Do not create new instances - use this provider instead.
NotificationDisplayServiceImpl? _sharedInstance;

/// Sets the shared notification display service instance.
///
/// This should be called once in main.dart after initialization.
void setSharedNotificationDisplayService(
  NotificationDisplayServiceImpl service,
) {
  _sharedInstance = service;
}

/// Provider for the shared NotificationDisplayService.
///
/// Returns the singleton instance that was initialized in main.dart.
/// If not initialized, creates and initializes a new instance.
@riverpod
Future<NotificationDisplayService> notificationDisplayService(Ref ref) async {
  if (_sharedInstance != null) {
    return _sharedInstance!;
  }

  // Fallback: create and initialize a new instance if not set
  final service = NotificationDisplayServiceImpl();
  await service.initialize();
  await service.initializeChannels();
  _sharedInstance = service;
  return service;
}

/// Synchronous provider that returns the service if already initialized.
///
/// Use this when you need synchronous access and are sure the service is ready.
/// Using keepAlive since this is used by keepAlive providers.
@Riverpod(keepAlive: true)
NotificationDisplayService? notificationDisplayServiceSync(Ref ref) {
  return _sharedInstance;
}
