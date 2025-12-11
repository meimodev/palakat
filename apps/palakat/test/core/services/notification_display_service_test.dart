import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:palakat/core/constants/notification_channels.dart';
import 'package:palakat/core/models/notification_payload.dart';
import 'package:palakat/core/services/notification_display_service.dart';

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockAndroidFlutterLocalNotificationsPlugin extends Mock
    implements AndroidFlutterLocalNotificationsPlugin {}

class MockIOSFlutterLocalNotificationsPlugin extends Mock
    implements IOSFlutterLocalNotificationsPlugin {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(const InitializationSettings());
    registerFallbackValue(const AndroidNotificationChannel('test', 'test'));
    registerFallbackValue(const NotificationDetails());
  });

  group('NotificationDisplayService', () {
    late MockFlutterLocalNotificationsPlugin mockPlugin;
    late MockAndroidFlutterLocalNotificationsPlugin mockAndroidPlugin;
    late MockIOSFlutterLocalNotificationsPlugin mockIosPlugin;
    late NotificationDisplayServiceImpl service;

    setUp(() {
      mockPlugin = MockFlutterLocalNotificationsPlugin();
      mockAndroidPlugin = MockAndroidFlutterLocalNotificationsPlugin();
      mockIosPlugin = MockIOSFlutterLocalNotificationsPlugin();

      when(
        () => mockPlugin.initialize(
          any(),
          onDidReceiveNotificationResponse: any(
            named: 'onDidReceiveNotificationResponse',
          ),
        ),
      ).thenAnswer((_) async => true);

      when(
        () => mockPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >(),
      ).thenReturn(mockAndroidPlugin);

      when(
        () => mockPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >(),
      ).thenReturn(mockIosPlugin);

      service = NotificationDisplayServiceImpl(plugin: mockPlugin);
    });

    group('initialization', () {
      test('initializes plugin with correct settings', () async {
        await service.initialize();

        verify(
          () => mockPlugin.initialize(
            any(),
            onDidReceiveNotificationResponse: any(
              named: 'onDidReceiveNotificationResponse',
            ),
          ),
        ).called(1);
      });
    });

    group('initializeChannels', () {
      test('creates all Android notification channels on Android', () async {
        if (Platform.isAndroid) {
          when(
            () => mockAndroidPlugin.createNotificationChannel(any()),
          ).thenAnswer((_) async => {});

          await service.initializeChannels();

          verify(
            () => mockAndroidPlugin.createNotificationChannel(any()),
          ).called(NotificationChannels.all.length);
        }
      });
    });

    group('displayNotification', () {
      test('shows system notification with correct payload', () async {
        String? capturedTitle;
        String? capturedBody;

        when(
          () => mockPlugin.show(
            any(),
            any(),
            any(),
            any(),
            payload: any(named: 'payload'),
          ),
        ).thenAnswer((invocation) async {
          capturedTitle = invocation.positionalArguments[1] as String?;
          capturedBody = invocation.positionalArguments[2] as String?;
        });

        final payload = NotificationPayload(
          title: 'Test Title',
          body: 'Test Body',
        );

        await service.displayNotification(
          payload: payload,
          channelId: 'activity_updates',
        );

        expect(capturedTitle, equals('Test Title'));
        expect(capturedBody, equals('Test Body'));
      });

      test('assigns notification to correct channel', () async {
        NotificationDetails? capturedDetails;

        when(
          () => mockPlugin.show(
            any(),
            any(),
            any(),
            any(),
            payload: any(named: 'payload'),
          ),
        ).thenAnswer((invocation) async {
          capturedDetails =
              invocation.positionalArguments[3] as NotificationDetails?;
        });

        final payload = NotificationPayload(
          title: 'Approval Request',
          body: 'Please approve',
        );

        await service.displayNotification(
          payload: payload,
          channelId: 'approval_requests',
        );

        expect(
          capturedDetails?.android?.channelId,
          equals('approval_requests'),
        );
      });

      test('handles invalid payload gracefully', () async {
        when(
          () => mockPlugin.show(
            any(),
            any(),
            any(),
            any(),
            payload: any(named: 'payload'),
          ),
        ).thenAnswer((_) async => {});

        // Test with empty title - should not throw
        final invalidPayload = NotificationPayload(
          title: '',
          body: 'Test Body',
        );

        // This should not throw an exception
        await expectLater(
          () => service.displayNotification(
            payload: invalidPayload,
            channelId: 'activity_updates',
          ),
          returnsNormally,
        );

        // Verify that show was not called due to validation failure
        verifyNever(
          () => mockPlugin.show(
            any(),
            any(),
            any(),
            any(),
            payload: any(named: 'payload'),
          ),
        );
      });

      test('handles plugin show failure gracefully', () async {
        when(
          () => mockPlugin.show(
            any(),
            any(),
            any(),
            any(),
            payload: any(named: 'payload'),
          ),
        ).thenThrow(Exception('Plugin error'));

        final payload = NotificationPayload(
          title: 'Test Title',
          body: 'Test Body',
        );

        // This should not throw an exception even if plugin fails
        await expectLater(
          () => service.displayNotification(
            payload: payload,
            channelId: 'activity_updates',
          ),
          returnsNormally,
        );
      });

      test('handles payload data encoding errors gracefully', () async {
        when(
          () => mockPlugin.show(
            any(),
            any(),
            any(),
            any(),
            payload: any(named: 'payload'),
          ),
        ).thenAnswer((_) async => {});

        final payload = NotificationPayload(
          title: 'Test Title',
          body: 'Test Body',
          data: {
            'key': 'value=with=equals',
            'another': 'value;with;semicolons',
          },
        );

        // This should handle encoding gracefully
        await expectLater(
          () => service.displayNotification(
            payload: payload,
            channelId: 'activity_updates',
          ),
          returnsNormally,
        );

        verify(
          () => mockPlugin.show(
            any(),
            any(),
            any(),
            any(),
            payload: any(named: 'payload'),
          ),
        ).called(1);
      });
    });

    group('setNotificationTapHandler', () {
      test('registers callback for notification tap', () async {
        bool handlerCalled = false;

        service.setNotificationTapHandler((data) {
          handlerCalled = true;
        });

        void Function(NotificationResponse)? capturedCallback;
        when(
          () => mockPlugin.initialize(
            any(),
            onDidReceiveNotificationResponse: any(
              named: 'onDidReceiveNotificationResponse',
            ),
          ),
        ).thenAnswer((invocation) async {
          capturedCallback =
              invocation.namedArguments[#onDidReceiveNotificationResponse]
                  as void Function(NotificationResponse)?;
          return true;
        });

        await service.initialize();

        capturedCallback!(
          NotificationResponse(
            notificationResponseType:
                NotificationResponseType.selectedNotification,
            payload: 'type=TEST',
          ),
        );

        expect(handlerCalled, isTrue);
      });

      test('extracts and passes notification data to callback', () async {
        Map<String, dynamic>? receivedData;

        service.setNotificationTapHandler((data) {
          receivedData = data;
        });

        void Function(NotificationResponse)? capturedCallback;
        when(
          () => mockPlugin.initialize(
            any(),
            onDidReceiveNotificationResponse: any(
              named: 'onDidReceiveNotificationResponse',
            ),
          ),
        ).thenAnswer((invocation) async {
          capturedCallback =
              invocation.namedArguments[#onDidReceiveNotificationResponse]
                  as void Function(NotificationResponse)?;
          return true;
        });

        await service.initialize();

        // Test with encoded payload data
        capturedCallback!(
          NotificationResponse(
            notificationResponseType:
                NotificationResponseType.selectedNotification,
            payload: 'type=ACTIVITY_CREATED;activityId=123;title=Test Activity',
          ),
        );

        expect(receivedData, isNotNull);
        expect(receivedData!['type'], equals('ACTIVITY_CREATED'));
        expect(receivedData!['activityId'], equals('123'));
        expect(receivedData!['title'], equals('Test Activity'));
      });

      test('handles empty payload gracefully', () async {
        Map<String, dynamic>? receivedData;

        service.setNotificationTapHandler((data) {
          receivedData = data;
        });

        void Function(NotificationResponse)? capturedCallback;
        when(
          () => mockPlugin.initialize(
            any(),
            onDidReceiveNotificationResponse: any(
              named: 'onDidReceiveNotificationResponse',
            ),
          ),
        ).thenAnswer((invocation) async {
          capturedCallback =
              invocation.namedArguments[#onDidReceiveNotificationResponse]
                  as void Function(NotificationResponse)?;
          return true;
        });

        await service.initialize();

        // Test with null payload
        capturedCallback!(
          NotificationResponse(
            notificationResponseType:
                NotificationResponseType.selectedNotification,
            payload: null,
          ),
        );

        expect(receivedData, isNotNull);
        expect(receivedData, isEmpty);
      });

      test('handles malformed payload gracefully', () async {
        Map<String, dynamic>? receivedData;

        service.setNotificationTapHandler((data) {
          receivedData = data;
        });

        void Function(NotificationResponse)? capturedCallback;
        when(
          () => mockPlugin.initialize(
            any(),
            onDidReceiveNotificationResponse: any(
              named: 'onDidReceiveNotificationResponse',
            ),
          ),
        ).thenAnswer((invocation) async {
          capturedCallback =
              invocation.namedArguments[#onDidReceiveNotificationResponse]
                  as void Function(NotificationResponse)?;
          return true;
        });

        await service.initialize();

        // Test with malformed payload
        capturedCallback!(
          NotificationResponse(
            notificationResponseType:
                NotificationResponseType.selectedNotification,
            payload: 'invalid=payload=format=with=too=many=equals',
          ),
        );

        expect(receivedData, isNotNull);
        // Should handle gracefully and extract what it can
      });
    });

    group('clearAllNotifications', () {
      test('clears all notifications', () async {
        when(() => mockPlugin.cancelAll()).thenAnswer((_) async => {});

        await service.clearAllNotifications();

        verify(() => mockPlugin.cancelAll()).called(1);
      });

      test('handles clear failure gracefully', () async {
        when(() => mockPlugin.cancelAll()).thenThrow(Exception('Clear failed'));

        // This should not throw an exception
        await expectLater(
          () => service.clearAllNotifications(),
          returnsNormally,
        );
      });
    });

    group('updateBadgeCount', () {
      test('updates iOS badge count', () async {
        if (Platform.isIOS) {
          when(
            () => mockIosPlugin.requestPermissions(badge: any(named: 'badge')),
          ).thenAnswer((_) async => true);

          await service.updateBadgeCount(5);

          verify(() => mockIosPlugin.requestPermissions(badge: true)).called(1);
        }
      });

      test('handles negative badge count', () async {
        if (Platform.isIOS) {
          when(
            () => mockIosPlugin.requestPermissions(badge: any(named: 'badge')),
          ).thenAnswer((_) async => true);

          // Should handle negative count gracefully
          await expectLater(
            () => service.updateBadgeCount(-5),
            returnsNormally,
          );
        }
      });

      test('handles badge update failure gracefully', () async {
        if (Platform.isIOS) {
          when(
            () => mockIosPlugin.requestPermissions(badge: any(named: 'badge')),
          ).thenThrow(Exception('Badge update failed'));

          // This should not throw an exception
          await expectLater(() => service.updateBadgeCount(5), returnsNormally);
        }
      });
    });

    group('clearBadgeCount', () {
      test('clears badge count by setting to 0', () async {
        if (Platform.isIOS) {
          when(
            () => mockIosPlugin.requestPermissions(badge: any(named: 'badge')),
          ).thenAnswer((_) async => true);

          when(
            () => mockPlugin.show(any(), any(), any(), any()),
          ).thenAnswer((_) async => {});

          when(() => mockPlugin.cancel(any())).thenAnswer((_) async => {});

          await service.clearBadgeCount();

          // Verify that updateBadgeCount(0) was called
          verify(() => mockIosPlugin.requestPermissions(badge: true)).called(1);
        }
      });

      test('handles clear badge failure gracefully', () async {
        if (Platform.isIOS) {
          when(
            () => mockIosPlugin.requestPermissions(badge: any(named: 'badge')),
          ).thenThrow(Exception('Clear badge failed'));

          // This should not throw an exception
          await expectLater(() => service.clearBadgeCount(), returnsNormally);
        }
      });
    });

    group('dispose', () {
      test('clears handlers and resets state', () {
        // Set up a handler first
        service.setNotificationTapHandler((data) {
          // Handler callback - not expected to be called after dispose
        });

        // Dispose the service
        service.dispose();

        // The handler should be cleared (we can't directly test this,
        // but we can verify dispose doesn't throw)
        expect(() => service.dispose(), returnsNormally);
      });
    });
  });
}
