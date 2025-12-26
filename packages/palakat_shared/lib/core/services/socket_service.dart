import 'dart:async';
import 'dart:developer' as dev;
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:palakat_shared/core/config/app_config.dart';
import 'package:palakat_shared/core/models/auth_response.dart';
import 'package:palakat_shared/core/models/auth_tokens.dart';
import 'package:palakat_shared/core/models/result.dart';
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
    this.path = '/ws',
    this.connectTimeout = const Duration(seconds: 10),
    this.ackTimeout = const Duration(seconds: 20),
  });

  final String url;
  final String path;
  final String Function() accessTokenProvider;
  final Future<AuthTokens> Function() refreshTokens;
  final Future<void> Function() onUnauthorized;
  final Duration connectTimeout;
  final Duration ackTimeout;

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

  io.Socket _ensureSocket() {
    final existing = _socket;
    if (existing != null) return existing;

    final opts = io.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .setPath(path)
        .setAuthFn((data) {
          final token = _handshakeTokenOverride ?? accessTokenProvider();
          if (token.isNotEmpty) {
            (data as dynamic)['token'] = token;
          }
        })
        .setAckTimeout(ackTimeout.inMilliseconds)
        .enableReconnection()
        .build();

    final socket = io.io(url, opts);
    _socket = socket;

    socket.onConnect((_) {
      _connected.value = true;
      _connectionStatus.value = SocketConnectionStatus.connected;
      dev.log('connected', name: 'SocketService');
      _connectCompleter?.complete();
    });

    socket.onDisconnect((_) {
      _connected.value = false;
      _connectionStatus.value = SocketConnectionStatus.disconnected;
      dev.log('disconnected', name: 'SocketService');
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
      dev.log('connect_error: $e', name: 'SocketService');
      _connectCompleter?.completeError(Failure('connect_error: $e'));
    });

    socket.onError((e) {
      dev.log('error: $e', name: 'SocketService');
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
    socket.on(event, handler);
  }

  void off(String event, [RpcHandler? handler]) {
    final socket = _ensureSocket();
    if (handler != null) {
      socket.off(event, handler);
    } else {
      socket.off(event);
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
      throw Failure('Disconnected');
    }

    final id = (_nextId++).toString();
    final request = {
      'id': id,
      'action': action,
      'payload': payload ?? <String, dynamic>{},
    };

    final completer = Completer<JsonMap>();

    if (kDebugMode) {
      dev.log('rpc -> $action ($id)', name: 'SocketService');
    }

    socket.emitWithAck(
      'rpc',
      request,
      ack: (data) async {
        try {
          final raw = _normalizeJson(data);
          if (raw is! Map<String, dynamic>) {
            completer.completeError(Failure('Invalid rpc response'));
            return;
          }

          final ok = raw['ok'] == true;
          if (ok) {
            final d = raw['data'];
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
              completer.complete(retry);
              return;
            } catch (_) {
              await onUnauthorized();
              completer.completeError(Failure(message, 401));
              return;
            }
          }

          completer.completeError(Failure(message));
        } catch (e) {
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

  final api = Uri.parse(config.apiBaseUrl);
  final wsBase =
      '${api.scheme}://${api.host}${api.hasPort ? ':${api.port}' : ''}';

  late final SocketService service;
  service = SocketService(
    url: wsBase,
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
