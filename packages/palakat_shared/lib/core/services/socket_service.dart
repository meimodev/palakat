import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:palakat_shared/core/config/app_config.dart';
import 'package:palakat_shared/core/models/auth_response.dart';
import 'package:palakat_shared/core/models/auth_tokens.dart';
import 'package:palakat_shared/core/models/result.dart';
import 'package:palakat_shared/core/services/app_logger.dart';
import 'package:palakat_shared/core/services/local_storage_service_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

part 'socket_service.g.dart';

typedef JsonMap = Map<String, dynamic>;

typedef RpcHandler = void Function(dynamic data);

enum SocketConnectionStatus { disconnected, connecting, connected }

class SocketService {
  SocketService({
    required this.url,
    required this.accessTokenProvider,
    required this.refreshTokens,
    required this.onUnauthorized,
    Logger? logger,
    this.path = '/ws',
    this.connectTimeout = const Duration(seconds: 10),
    this.ackTimeout = const Duration(seconds: 20),
  }) : _logger = logger ?? createAppLogger(tag: 'SocketService');

  final String url;
  final String path;
  final String Function() accessTokenProvider;
  final Future<AuthTokens> Function() refreshTokens;
  final Future<void> Function() onUnauthorized;
  final Duration connectTimeout;
  final Duration ackTimeout;

  final Logger _logger;

  io.Socket? _socket;
  bool _connecting = false;
  String? _handshakeTokenOverride;
  Completer<void>? _connectCompleter;

  final _connectionStatus = ValueNotifier<SocketConnectionStatus>(
    SocketConnectionStatus.disconnected,
  );
  ValueListenable<SocketConnectionStatus> get connectionStatusListenable =>
      _connectionStatus;
  SocketConnectionStatus get connectionStatus => _connectionStatus.value;

  final _connected = ValueNotifier<bool>(false);
  ValueListenable<bool> get connectedListenable => _connected;
  bool get isConnected => _connected.value;

  int _nextId = 1;

  final Map<String, Map<RpcHandler, List<RpcHandler>>> _wrappedHandlers = {};

  static const Set<String> _redactedKeys = {
    'token',
    'accessToken',
    'refreshToken',
    'firebaseIdToken',
    'password',
    'otp',
    'smsCode',
    'authorization',
  };

  bool _isSensitiveKey(String key) {
    final k = key.trim();
    if (k.isEmpty) return false;
    final lower = k.toLowerCase();
    if (_redactedKeys.contains(k) || _redactedKeys.contains(lower)) return true;
    if (lower.contains('token')) return true;
    return false;
  }

  dynamic _sanitizeForLog(dynamic value, {int depth = 0, String? keyHint}) {
    if (depth > 6) return '<max_depth>';

    if (value == null) return null;

    if (keyHint != null) {
      final lowerKey = keyHint.toLowerCase();
      if (lowerKey.contains('base64') && value is String) {
        return '<base64 len=${value.length}>';
      }
    }

    if (value is Uint8List) {
      return '<bytes len=${value.length}>';
    }

    if (value is Map) {
      const maxKeys = 60;
      final out = <String, dynamic>{};
      var idx = 0;
      value.forEach((k, v) {
        if (idx >= maxKeys) return;
        idx++;

        final key = k.toString();
        if (_isSensitiveKey(key)) {
          out[key] = '<redacted>';
        } else {
          out[key] = _sanitizeForLog(v, depth: depth + 1, keyHint: key);
        }
      });

      final extra = value.length - out.length;
      if (extra > 0) {
        out['__truncated_keys__'] = '<$extra more keys>';
      }

      return out;
    }

    if (value is List) {
      final limit = 20;
      final truncated = value.length > limit;
      final items = value.take(limit).toList(growable: false);
      final out = items
          .map((e) => _sanitizeForLog(e, depth: depth + 1))
          .toList(growable: true);
      if (truncated) {
        out.add('<truncated ${value.length - limit} more>');
      }
      return out;
    }

    if (value is String) {
      final s = value;
      if (s.length > 200) return '${s.substring(0, 200)}…';
      return s;
    }

    if (value is num || value is bool) return value;

    final s = value.toString();
    if (s.length > 200) return '${s.substring(0, 200)}…';
    return s;
  }

  String _stringifyForLog(dynamic value) {
    final sanitized = _sanitizeForLog(_normalizeJson(value));
    try {
      final s = jsonEncode(sanitized);
      const maxLen = 4000;
      if (s.length > maxLen) {
        return '${s.substring(0, maxLen)}…<truncated len=${s.length}>';
      }
      return s;
    } catch (_) {
      final s = sanitized.toString();
      const maxLen = 4000;
      if (s.length > maxLen) {
        return '${s.substring(0, maxLen)}…<truncated len=${s.length}>';
      }
      return s;
    }
  }

  void _logWsDebug(String message) {
    _logger.d(message);
  }

  io.Socket _ensureSocket() {
    final existing = _socket;
    if (existing != null) return existing;

    _logger.i('Creating socket with url=$url, path=$path');

    final transports = const ['websocket'];
    final opts = io.OptionBuilder()
        .setTransports(transports)
        .disableAutoConnect()
        .setPath(path)
        .setAuth(<String, dynamic>{})
        .setAuthFn((dynamic auth) {
          try {
            final token = _handshakeTokenOverride ?? accessTokenProvider();
            if (token.isEmpty) {
              if (auth is Map) {
                auth.remove('token');
              } else if (auth is Function) {
                auth(<dynamic, dynamic>{});
              }
              return;
            }

            if (auth is Map) {
              auth['token'] = token;
            } else if (auth is Function) {
              auth(<dynamic, dynamic>{'token': token});
            }
          } catch (e, st) {
            _logger.e('authFn error: $e', error: e, stackTrace: st);
            if (auth is Function) {
              auth(<dynamic, dynamic>{});
            }
          }
        })
        .setAckTimeout(ackTimeout.inMilliseconds)
        .enableReconnection()
        .build();

    final socket = io.io(url, opts);
    _socket = socket;

    socket.io.on('open', (_) {
      _logger.d('manager open');
    });
    socket.io.on('close', (e) {
      _logger.w('manager close: $e');
    });
    socket.io.on('error', (e) {
      _logger.e('manager error: $e');
    });
    socket.io.on('reconnect_attempt', (e) {
      _logger.d('manager reconnect_attempt: $e');
    });
    socket.io.on('reconnect_error', (e) {
      _logger.w('manager reconnect_error: $e');
    });
    socket.io.on('reconnect_failed', (e) {
      _logger.e('manager reconnect_failed: $e');
    });

    socket.onConnect((_) {
      _connected.value = true;
      _connectionStatus.value = SocketConnectionStatus.connected;
      _logger.i('connected');
      final completer = _connectCompleter;
      if (completer != null && !completer.isCompleted) {
        completer.complete();
      }
    });

    socket.onDisconnect((_) {
      _connected.value = false;
      _connectionStatus.value = SocketConnectionStatus.disconnected;
      _logger.w('disconnected');
      final completer = _connectCompleter;
      if (completer != null && !completer.isCompleted) {
        completer.completeError(Failure('disconnected'));
      }
    });

    socket.on('reconnect_attempt', (_) {
      if (_connectionStatus.value != SocketConnectionStatus.connected) {
        _connectionStatus.value = SocketConnectionStatus.connecting;
      }
    });

    socket.on('reconnect', (_) {
      _connected.value = true;
      _connectionStatus.value = SocketConnectionStatus.connected;
    });

    socket.on('reconnect_error', (_) {
      _connected.value = false;
      _connectionStatus.value = SocketConnectionStatus.disconnected;
    });

    socket.on('reconnect_failed', (_) {
      _connected.value = false;
      _connectionStatus.value = SocketConnectionStatus.disconnected;
    });

    socket.onConnectError((e) {
      _connected.value = false;
      _connectionStatus.value = SocketConnectionStatus.disconnected;
      _logger.e('connect_error: $e');
      final completer = _connectCompleter;
      if (completer != null && !completer.isCompleted) {
        completer.completeError(Failure('connect_error: $e'));
      }
    });

    socket.onError((e) {
      _logger.e('error: $e');
    });

    return socket;
  }

  Future<void> _waitUntilConnected({
    required bool allowRetryWithoutToken,
  }) async {
    final socket = _ensureSocket();
    if (socket.connected) return;

    if (_connectionStatus.value != SocketConnectionStatus.connected) {
      _connectionStatus.value = SocketConnectionStatus.connecting;
    }

    _connectCompleter ??= Completer<void>();

    socket.connect();

    try {
      await _connectCompleter!.future.timeout(connectTimeout);
    } catch (e) {
      _connectionStatus.value = SocketConnectionStatus.disconnected;
      _connectCompleter = null;
      if (!allowRetryWithoutToken) rethrow;

      final token = accessTokenProvider();
      if (token.isEmpty) rethrow;

      _handshakeTokenOverride = '';
      final retryCompleter = Completer<void>();
      _connectCompleter = retryCompleter;
      socket.io
        ..disconnect()
        ..connect();
      await retryCompleter.future.timeout(connectTimeout);
    } finally {
      _connectCompleter = null;
    }
  }

  Future<void> connect() async {
    if (_connecting) return;
    _connecting = true;
    try {
      await _waitUntilConnected(allowRetryWithoutToken: true);
    } catch (e) {
      _connected.value = false;
      _connectionStatus.value = SocketConnectionStatus.disconnected;
      _logger.e('connect() failed: $e');
    } finally {
      _connecting = false;
    }
  }

  Future<void> disconnect() async {
    final socket = _socket;
    if (socket == null) return;
    socket.disconnect();
  }

  void on(String event, RpcHandler handler) {
    final socket = _ensureSocket();
    final wrapped = (dynamic data) {
      if (kDebugMode) {
        _logWsDebug('event <- $event payload=${_stringifyForLog(data)}');
      }
      handler(data);
    };

    final byHandler = _wrappedHandlers.putIfAbsent(
      event,
      () => <RpcHandler, List<RpcHandler>>{},
    );
    (byHandler[handler] ??= <RpcHandler>[]).add(wrapped);
    socket.on(event, wrapped);
  }

  void off(String event, [RpcHandler? handler]) {
    final socket = _ensureSocket();
    if (handler != null) {
      final byHandler = _wrappedHandlers[event];
      final wrappers = byHandler?[handler];
      if (wrappers != null && wrappers.isNotEmpty) {
        for (final w in List<RpcHandler>.from(wrappers)) {
          socket.off(event, w);
        }
        byHandler?.remove(handler);
        if (byHandler != null && byHandler.isEmpty) {
          _wrappedHandlers.remove(event);
        }
        return;
      }
      socket.off(event, handler);
    } else {
      socket.off(event);
      _wrappedHandlers.remove(event);
    }
  }

  Future<JsonMap> rpc(String action, [JsonMap? payload]) async {
    return _rpc(action, payload, allowAutoRefresh: true);
  }

  Future<JsonMap> _rpc(
    String action,
    JsonMap? payload, {
    required bool allowAutoRefresh,
  }) async {
    final socket = _ensureSocket();
    if (!socket.connected) {
      unawaited(connect());
      if (kDebugMode) {
        _logWsDebug('rpc <- $action (not_connected)');
      }
      throw Failure('Disconnected');
    }

    final id = (_nextId++).toString();
    final request = {
      'id': id,
      'action': action,
      'payload': payload ?? <String, dynamic>{},
    };

    final completer = Completer<JsonMap>();

    final sw = Stopwatch()..start();

    if (kDebugMode) {
      _logWsDebug(
        'rpc -> $action ($id) payload=${_stringifyForLog(request['payload'])}',
      );
    }

    socket.emitWithAck(
      'rpc',
      request,
      ack: (a, [b]) async {
        try {
          dynamic data;
          if (b == null) {
            data = a;
          } else {
            if (a == null) {
              data = b;
            } else if (a is Map && a['ok'] != null) {
              data = a;
            } else {
              sw.stop();
              if (kDebugMode) {
                _logWsDebug(
                  'rpc <- $action ($id) ok=false ms=${sw.elapsedMilliseconds} ack_error=${_stringifyForLog(a)}',
                );
              }
              completer.completeError(Failure('rpc ack error: $a'));
              return;
            }
          }

          final raw = _normalizeJson(data);
          if (raw is! Map<String, dynamic>) {
            sw.stop();
            if (kDebugMode) {
              _logWsDebug(
                'rpc <- $action ($id) ok=false ms=${sw.elapsedMilliseconds} invalid_response=${_stringifyForLog(raw)}',
              );
            }
            completer.completeError(Failure('Invalid rpc response'));
            return;
          }

          final ok = raw['ok'] == true;
          if (ok) {
            sw.stop();
            final d = raw['data'];
            if (kDebugMode) {
              _logWsDebug(
                'rpc <- $action ($id) ok=true ms=${sw.elapsedMilliseconds} data=${_stringifyForLog(d)}',
              );
            }
            if (d is Map<String, dynamic>) {
              completer.complete(d);
            } else {
              completer.complete({'data': d});
            }
            return;
          }

          final err = raw['error'];
          final code = err is Map ? err['code']?.toString() : null;
          final message = err is Map
              ? err['message']?.toString() ?? 'Request failed'
              : 'Request failed';

          int? statusCode;
          if (code == 'UNAUTHENTICATED') {
            statusCode = 401;
          } else if (code == 'FORBIDDEN') {
            statusCode = 403;
          } else if (code == 'NOT_FOUND') {
            statusCode = 404;
          } else if (code == 'CONFLICT') {
            statusCode = 409;
          } else if (code == 'VALIDATION_ERROR') {
            statusCode = 400;
          } else if (code == 'INTERNAL') {
            statusCode = 500;
          }

          if (code == 'UNAUTHENTICATED' && allowAutoRefresh) {
            try {
              _handshakeTokenOverride = '';
              socket.io
                ..disconnect()
                ..connect();
              await _waitUntilConnected(allowRetryWithoutToken: false);

              final tokens = await refreshTokens();

              _handshakeTokenOverride = tokens.accessToken;
              socket.io
                ..disconnect()
                ..connect();
              await _waitUntilConnected(allowRetryWithoutToken: false);

              final retry = await _rpc(
                action,
                payload,
                allowAutoRefresh: false,
              );
              sw.stop();
              if (kDebugMode) {
                _logWsDebug(
                  'rpc <- $action ($id) ok=true ms=${sw.elapsedMilliseconds} (after_refresh)',
                );
              }
              completer.complete(retry);
              return;
            } catch (_) {
              sw.stop();
              if (kDebugMode) {
                _logWsDebug(
                  'rpc <- $action ($id) ok=false ms=${sw.elapsedMilliseconds} code=$code status=401 message=$message',
                );
              }
              await onUnauthorized();
              completer.completeError(Failure(message, 401));
              return;
            }
          }

          sw.stop();
          if (kDebugMode) {
            _logWsDebug(
              'rpc <- $action ($id) ok=false ms=${sw.elapsedMilliseconds} code=$code status=$statusCode message=$message error=${_stringifyForLog(err)}',
            );
          }
          completer.completeError(Failure(message, statusCode));
        } catch (e) {
          sw.stop();
          if (kDebugMode) {
            _logWsDebug(
              'rpc <- $action ($id) ok=false ms=${sw.elapsedMilliseconds} exception=${_stringifyForLog(e.toString())}',
            );
          }
          completer.completeError(Failure.fromException(e));
        }
      },
    );

    return completer.future;
  }

  Future<AuthResponse> signIn({
    required String identifier,
    required String password,
  }) async {
    final res = await rpc('auth.signIn', {
      'identifier': identifier,
      'password': password,
    });

    final data = res['data'];
    if (data is! Map<String, dynamic>) {
      throw Failure('Invalid auth response');
    }
    return AuthResponse.fromJson(data);
  }

  Future<AuthTokens> refresh({required String refreshToken}) async {
    final res = await _rpc('auth.refresh', {
      'refreshToken': refreshToken,
    }, allowAutoRefresh: false);

    final data = res['data'];
    if (data is! Map<String, dynamic>) {
      throw Failure('Invalid refresh response');
    }

    return AuthTokens.fromJson({
      'accessToken': data['accessToken'],
      'refreshToken': data['refreshToken'],
    });
  }

  Future<Map<String, dynamic>> uploadFileBytes({
    required int churchId,
    required Uint8List bytes,
    required String originalName,
    String? contentType,
    String? bucket,
    void Function(int sentBytes, int totalBytes)? onProgress,
  }) async {
    final init = await rpc('file.upload.init', {
      'churchId': churchId,
      'sizeBytes': bytes.length,
      'contentType': contentType,
      'originalName': originalName,
      if (bucket != null) 'bucket': bucket,
    });

    final initData = init['data'];
    if (initData is! Map) {
      throw Failure('Invalid upload init response');
    }
    final uploadId = initData['uploadId'];
    final chunkSize = initData['chunkSize'];
    if (uploadId is! String || uploadId.isEmpty) {
      throw Failure('Invalid uploadId');
    }
    final cs = chunkSize is int ? chunkSize : (256 * 1024);

    int sent = 0;
    try {
      while (sent < bytes.length) {
        final end = (sent + cs) > bytes.length ? bytes.length : (sent + cs);
        final chunk = bytes.sublist(sent, end);
        final b64 = base64Encode(chunk);
        final ack = await rpc('file.upload.chunk', {
          'uploadId': uploadId,
          'dataBase64': b64,
        });

        sent = end;
        onProgress?.call(sent, bytes.length);

        final _ = ack;
      }

      final done = await rpc('file.upload.complete', {'uploadId': uploadId});
      return done;
    } catch (e) {
      try {
        await rpc('file.upload.abort', {'uploadId': uploadId});
      } catch (_) {}
      rethrow;
    }
  }

  Future<({Uint8List bytes, String? contentType, String? originalName})>
  downloadFileBytes({
    required int fileId,
    void Function(int receivedBytes, int totalBytes)? onProgress,
  }) async {
    final init = await rpc('file.download.init', {'fileId': fileId});

    final data = init['data'];
    if (data is! Map) {
      throw Failure('Invalid download init response');
    }
    final downloadId = data['downloadId'];
    final sizeBytes = data['sizeBytes'];
    final contentType = data['contentType'];
    final originalName = data['originalName'];
    if (downloadId is! String || downloadId.isEmpty) {
      throw Failure('Invalid downloadId');
    }
    final total = sizeBytes is int ? sizeBytes : 0;

    final builder = BytesBuilder(copy: false);
    int received = 0;
    try {
      while (true) {
        final res = await rpc('file.download.chunk', {
          'downloadId': downloadId,
        });
        final d = res['data'];
        if (d is! Map) {
          throw Failure('Invalid download chunk response');
        }
        final done = d['done'] == true;
        if (done) break;
        final b64 = d['dataBase64'];
        if (b64 is! String || b64.isEmpty) {
          throw Failure('Invalid chunk payload');
        }
        final chunk = base64Decode(b64);
        builder.add(chunk);
        received += chunk.length;
        onProgress?.call(received, total);
      }
    } finally {
      try {
        await rpc('file.download.complete', {'downloadId': downloadId});
      } catch (_) {}
    }

    return (
      bytes: builder.takeBytes(),
      contentType: contentType is String ? contentType : null,
      originalName: originalName is String ? originalName : null,
    );
  }

  dynamic _normalizeJson(dynamic value) {
    if (value is Map) {
      final result = <String, dynamic>{};
      value.forEach((k, v) {
        result[k.toString()] = _normalizeJson(v);
      });
      return result;
    } else if (value is List) {
      return value.map(_normalizeJson).toList();
    }
    return value;
  }
}

@riverpod
SocketService socketService(Ref ref) {
  ref.keepAlive();
  final config = ref.watch(appConfigProvider);
  final localStorage = ref.watch(localStorageServiceProvider);
  final logger = ref.watch(namedLoggerProvider('SocketService'));

  final api = Uri.parse(config.apiBaseUrl);
  final wsBase =
      '${api.scheme}://${api.host}${api.hasPort ? ':${api.port}' : ''}';

  logger.i('apiBaseUrl=${config.apiBaseUrl}');
  logger.i('wsBase=$wsBase');

  late final SocketService service;
  service = SocketService(
    url: wsBase,
    logger: logger,
    accessTokenProvider: () => localStorage.accessToken ?? '',
    refreshTokens: () async {
      final refreshToken = localStorage.refreshToken;
      if (refreshToken == null || refreshToken.isEmpty) {
        throw Failure('No refresh token available');
      }
      final tokens = await service.refresh(refreshToken: refreshToken);
      await localStorage.saveTokens(tokens);
      return tokens;
    },
    onUnauthorized: () async {
      await localStorage.clear();
    },
  );

  return service;
}
