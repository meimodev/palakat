import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../routing/app_routing.dart';
import 'in_app_notification_service.dart';

final inAppNotificationServiceProvider = Provider<InAppNotificationService>((
  ref,
) {
  final service = InAppNotificationService(navigatorKey: navigatorKey);
  ref.onDispose(service.dispose);
  return service;
});
