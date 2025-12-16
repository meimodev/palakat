import 'dart:async';
import 'dart:developer' as dev;

// import removed: no longer needed
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:palakat_shared/core/config/app_config.dart';
// import 'package:palakat_shared/features/auth/application/auth_controller.dart';
import 'package:palakat_shared/core/config/endpoint.dart';
import 'package:palakat_shared/core/models/auth_tokens.dart';
import 'package:palakat_shared/core/services/local_storage_service_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talker_dio_logger/talker_dio_logger_interceptor.dart';
import 'package:talker_dio_logger/talker_dio_logger_settings.dart';

part 'http_service.g.dart';

/// HTTP service configuration with Dio and logging interceptor
class HttpService {
  late final Dio _dio;
  final String Function()? _accessTokenProvider;
  final Future<void> Function()? _refreshTokens;
  final Future<void> Function()? _onUnauthorized;
  bool _isRefreshing = false;
  final List<void Function()> _refreshWaiters = [];

  HttpService({
    String? baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    Map<String, String>? extraHeaders,
    String Function()? accessTokenProvider,
    Future<void> Function()? refreshTokens,
    Future<void> Function()? onUnauthorized,
  }) : _accessTokenProvider = accessTokenProvider,
       _refreshTokens = refreshTokens,
       _onUnauthorized = onUnauthorized {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? '', // Replace with your API base URL
        connectTimeout: connectTimeout ?? const Duration(seconds: 30),
        receiveTimeout: receiveTimeout ?? const Duration(seconds: 30),
        sendTimeout: sendTimeout ?? const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (extraHeaders != null) ...extraHeaders,
        },
      ),
    );

    _setupInterceptors();
  }

  /// Setup interceptors for logging and error handling
  void _setupInterceptors() {
    // Pretty logger interceptor for debugging
    if (kDebugMode) {
      // _dio.interceptors.add(
      //   PrettyDioLogger(
      //     requestHeader: true,
      //     requestBody: true,
      //     responseBody: true,
      //     responseHeader: false,
      //     error: true,
      //     compact: true,
      //     maxWidth: 55,
      //     enabled: true, // Set to false in production
      //   ),
      // );
      _dio.interceptors.add(
        TalkerDioLogger(
          settings: const TalkerDioLoggerSettings(
            printRequestHeaders: true,
            printResponseHeaders: false,
            printResponseMessage: true,
          ),
        ),
      );
    }

    // Custom error interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          // 401 handling with refresh
          final status = error.response?.statusCode ?? 0;
          final isUnauthorized = status == 401;
          final alreadyRetried =
              error.requestOptions.extra['__retried__'] == true;
          // Determine if the failing request is the sign-in route; if so, do NOT attempt refresh
          final requestPath = error.requestOptions.path;
          final isSignInRoute = requestPath.endsWith(Endpoints.signIn);
          if (isUnauthorized &&
              !alreadyRetried &&
              _refreshTokens != null &&
              !isSignInRoute) {
            try {
              // Queue while a refresh is in progress
              if (_isRefreshing) {
                final completer = Completer<void>();
                _refreshWaiters.add(() => completer.complete());
                await completer.future;
              } else {
                _isRefreshing = true;
                await _refreshTokens.call();
                // notify all waiters
                for (final notify in List<void Function()>.from(
                  _refreshWaiters,
                )) {
                  notify();
                }
                _refreshWaiters.clear();
              }
              _isRefreshing = false;
              // retry original request with new token
              final req = error.requestOptions;
              req.extra['__retried__'] = true;
              final token = _accessTokenProvider?.call();
              if (token != null && token.isNotEmpty) {
                req.headers['Authorization'] = 'Bearer $token';
              } else {
                req.headers.remove('Authorization');
              }
              final response = await _dio.fetch(req);
              handler.resolve(response);
              return;
            } catch (e, st) {
              dev.log(
                'Token refresh failed: $e',
                name: 'HttpService',
                level: 1000,
                error: e,
                stackTrace: st,
              );
              _isRefreshing = false;
              _refreshWaiters.clear();
              await _onUnauthorized?.call();
            }
          }
          // Continue with the error
          handler.next(error);
        },
        onRequest: (options, handler) {
          // Add authentication headers if needed
          if (!options.headers.containsKey('Authorization')) {
            final token = _accessTokenProvider?.call();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
      ),
    );
  }

  /// Get configured Dio instance
  Dio get dio => _dio;

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      rethrow;
    }
  }
}

/// Riverpod provider for HttpService
@riverpod
HttpService httpService(Ref ref) {
  final config = ref.watch(appConfigProvider);
  final localStorage = ref.watch(localStorageServiceProvider);
  final headers = <String, String>{};

  return HttpService(
    baseUrl: config.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
    sendTimeout: const Duration(seconds: 20),
    extraHeaders: headers.isEmpty ? null : headers,
    accessTokenProvider: () => localStorage.accessToken ?? '',
    refreshTokens: () async {
      // Perform refresh without going through dioInstance/httpService to avoid cycles
      final refreshToken = localStorage.refreshToken;
      if (refreshToken == null || refreshToken.isEmpty) {
        throw StateError('No refresh token available');
      }
      final dio = Dio(
        BaseOptions(
          baseUrl: config.apiBaseUrl,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (headers.isNotEmpty) ...headers,
          },
        ),
      );
      final res = await dio.post<Map<String, dynamic>>(
        Endpoints.refresh,
        data: {'refresh_token': refreshToken},
      );
      final data = res.data ?? const {};
      final tokens = AuthTokens.fromJson(data['data']);
      await localStorage.saveTokens(tokens);
    },
    onUnauthorized: () async {
      // Ensure controller state resets so router guard reacts
      // TODO: Implement auth controller in consuming app
      // await ref.read(authControllerProvider.notifier).forceSignOut();
      await localStorage.clear();
    },
  );
}

/// Provider for Dio instance
@riverpod
Dio dioInstance(Ref ref) {
  final httpService = ref.watch(httpServiceProvider);
  return httpService.dio;
}
