import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'in_app_notification_service_provider.dart';
import 'notification_navigation_service.dart';
import '../routing/app_routing.dart';
import '../widgets/in_app_notification/in_app_notification_banner.dart';

import 'package:palakat_shared/services.dart';

class RealtimeNotificationListener {
  const RealtimeNotificationListener();
}

final realtimeNotificationListenerProvider =
    Provider<RealtimeNotificationListener>((ref) {
      final inApp = ref.read(inAppNotificationServiceProvider);
      final router = ref.read(goRouterProvider);
      final navigation = NotificationNavigationService(router);

      inApp.setOnNotificationTapped((notification) {
        navigation.handleNotificationTap(notification.data ?? const {});
      });

      ref.listen(realtimeEventProvider, (_, next) {
        final event = next.asData?.value;
        if (event == null) return;

        if (event.name != 'notification.created') return;

        final raw = event.payload['data'];
        if (raw is! Map) return;

        final title = raw['title']?.toString() ?? 'Notification';
        final body = raw['body']?.toString() ?? '';
        final type = raw['type']?.toString();

        final data = <String, dynamic>{};
        if (type != null && type.isNotEmpty) data['type'] = type;

        final activityId = raw['activityId'];
        if (activityId != null) data['activityId'] = activityId;

        inApp.show(
          notification: InAppNotificationData(
            title: title,
            body: body,
            type: type,
            data: data.isEmpty ? null : data,
          ),
        );
      });

      return const RealtimeNotificationListener();
    });
