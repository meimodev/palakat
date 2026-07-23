import 'dart:developer' as developer;

import 'package:firebase_messaging/firebase_messaging.dart';

/// Subscribes this device to FCM topics.
///
/// Phase 4 made the backend dual-emit every realtime event to an FCM topic
/// as well as the socket room (`realtime-emitter.service.ts` `emitToRoom`).
/// Until *something on the client calls `subscribeToTopic`*, that FCM half
/// publishes to nobody — this service is that something. It runs alongside
/// Pusher Beams; Beams is retired separately (migration plan §9.2), and the
/// socket half is deleted once clients subscribe here (§10.3).
///
/// Topic names come from [InterestBuilder] and are byte-identical to the
/// backend room names, so nothing is remapped.
///
/// ponytail: each op is best-effort and isolated — one topic failing must not
/// drop the rest. FCM has no "list my subscriptions" API, so the caller tracks
/// what it subscribed and passes it back to [unsubscribe].
class FcmTopicService {
  FcmTopicService({
    Future<void> Function(String topic)? subscribeTopic,
    Future<void> Function(String topic)? unsubscribeTopic,
  }) : _subscribeTopic =
           subscribeTopic ?? FirebaseMessaging.instance.subscribeToTopic,
       _unsubscribeTopic =
           unsubscribeTopic ?? FirebaseMessaging.instance.unsubscribeFromTopic;

  final Future<void> Function(String topic) _subscribeTopic;
  final Future<void> Function(String topic) _unsubscribeTopic;

  Future<void> subscribe(Iterable<String> topics) async {
    for (final topic in topics) {
      try {
        await _subscribeTopic(topic);
        _log('subscribed to $topic');
      } catch (e) {
        _log('subscribe failed for $topic: $e');
      }
    }
  }

  Future<void> unsubscribe(Iterable<String> topics) async {
    for (final topic in topics) {
      try {
        await _unsubscribeTopic(topic);
        _log('unsubscribed from $topic');
      } catch (e) {
        _log('unsubscribe failed for $topic: $e');
      }
    }
  }

  void _log(String message) =>
      developer.log('[FcmTopicService] $message', name: 'FcmTopic');
}
