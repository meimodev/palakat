import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'socket_service.dart';

class RealtimeEvent {
  const RealtimeEvent({required this.name, required this.payload});

  final String name;
  final Map<String, dynamic> payload;
}

class RealtimeEventsService {
  RealtimeEventsService(this._socket) {
    _init();
  }

  final SocketService _socket;

  final _eventsController = StreamController<RealtimeEvent>.broadcast();
  Stream<RealtimeEvent> get events => _eventsController.stream;

  bool _initialized = false;
  final Map<String, RpcHandler> _handlers = {};

  void _init() {
    if (_initialized) return;
    _initialized = true;

    // Phase 5 §10.1 step 3 / §9.4: change signals invalidate — they do not
    // refetch. The data controllers (operations, approval, approval detail) are
    // autoDispose, so a change to church-scoped data is re-read when the screen
    // is next viewed, not on the push. That means the church data-change signals
    // (activity.*, finance.*, approval.*, reportJob.*, report.ready,
    // permissions.updated) no longer need to reach the app as payloads at all —
    // forwarding them here only tempted an eager refetch. Two paths remain:
    //   - notification.* → the OS/in-app notification path (content on tap),
    //   - songDb.updated → the global song database staleness flag.
    _listen('notification.created');
    _listen('notification.updated');
    _listen('notification.deleted');

    _listen('songDb.updated');
  }

  void _listen(String eventName) {
    if (_handlers.containsKey(eventName)) return;

    void handler(dynamic data) {
      final payload = _asJsonMap(data);
      if (_eventsController.isClosed) return;
      _eventsController.add(RealtimeEvent(name: eventName, payload: payload));
    }

    _handlers[eventName] = handler;
    _socket.on(eventName, handler);
  }

  Map<String, dynamic> _asJsonMap(dynamic value) {
    final normalized = _normalizeJson(value);
    if (normalized is Map<String, dynamic>) return normalized;
    return <String, dynamic>{'data': normalized};
  }

  dynamic _normalizeJson(dynamic value) {
    if (value is Map) {
      final out = <String, dynamic>{};
      value.forEach((k, v) {
        out[k.toString()] = _normalizeJson(v);
      });
      return out;
    }

    if (value is List) {
      return value.map(_normalizeJson).toList(growable: false);
    }

    return value;
  }

  void dispose() {
    for (final entry in _handlers.entries) {
      _socket.off(entry.key, entry.value);
    }
    _handlers.clear();
    _eventsController.close();
  }
}

final realtimeEventsServiceProvider = Provider<RealtimeEventsService>((ref) {
  final socket = ref.watch(socketServiceProvider);
  final service = RealtimeEventsService(socket);
  ref.onDispose(service.dispose);
  return service;
});

final realtimeEventProvider = StreamProvider<RealtimeEvent>((ref) {
  final service = ref.watch(realtimeEventsServiceProvider);
  return service.events;
});
