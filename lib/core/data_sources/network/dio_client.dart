import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'dart:developer' as dev;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:curl_logger_dio_interceptor/curl_logger_dio_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat/core/constants/constants.dart';

import '../data_sources.dart';

class DioClient {
  late Dio _dio;
  late String baseUrl;
  late HiveService hiveService;

  static final int _refreshAuthTokenMaxAttempt = 3;
  static int _refreshAuthTokenAttempt = 0;

  DioClient({
    required this.baseUrl,
    required Dio dio,
    required this.hiveService,
    bool withAuth = true,
    Duration defaultConnectTimeout = const Duration(minutes: 2),
    Duration defaultReceiveTimeout = const Duration(minutes: 2),
  }) {
    _dio = dio;
    _dio
      ..options.baseUrl = baseUrl
      ..options.connectTimeout = defaultConnectTimeout
      ..options.receiveTimeout = defaultReceiveTimeout
      ..httpClientAdapter
      ..options.headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      };

    if (withAuth) {
      _dio.interceptors.add(
        QueuedInterceptorsWrapper(
          onRequest:
              (
                RequestOptions options,
                RequestInterceptorHandler handler,
              ) async {
                final auth = hiveService.getAuth();
                if (auth != null) {
                  options.headers['Authorization'] =
                      'Bearer ${auth.accessToken}';
                }

                if (options.data != null &&
                    (options.data is Map || options.data is List)) {
                  options.data = json.encode(options.data);
                }
                handler.next(options);
              },

          onError: (error, handler) async {
            if (error.response?.statusCode == 401) {
              await _refreshAuthToken();
            }
            handler.next(error);
          },
          onResponse: (response, handler) {
            if(response.data == null){
              throw Failure("response is returned null");
            }
            final body = response.data as Map<String, dynamic>;
            if (body['data'] != null) {
              throw Failure("property data is unavailable in the body response, see backend response scheme");
            }
            handler.next(response);
          },
        ),
      );
    }

    if (kDebugMode) {
      final logInterceptor = LogInterceptor(
        responseBody: true,
        error: true,
        requestHeader: true,
        responseHeader: false,
        request: false,
        requestBody: true,
        logPrint: (obj) {
          log(obj.toString());
        },
      );
      _dio.interceptors.add(logInterceptor);
      _dio.interceptors.add(CurlLoggerDioInterceptor(printOnSuccess: false));
    }
  }

  Future<void> _refreshAuthToken() async {
    _refreshAuthTokenAttempt++;
    dev.log(
      "[DIO CLIENT] refresh auth token Attempt: $_refreshAuthTokenAttempt of max $_refreshAuthTokenMaxAttempt",
    );

    if (_refreshAuthTokenAttempt >= _refreshAuthTokenMaxAttempt) {
      return;
    }

    if (hiveService.getAuth() != null) {
      await hiveService.deleteAuth();
    }

    final username = dotenv.env['x-username'];
    final password = dotenv.env['x-password'];

    final response = await get<Map<String, dynamic>>(
      Endpoint.signing,
      options: Options(
        headers: {'x-username': username, 'x-password': password},
      ),
    );


    final token = response?['data'] as String;
    final authData = AuthData(accessToken: token, refreshToken: token);
    await hiveService.saveAuth(authData);

    dev.log("[DIO CLIENT]Token successfully obtained and saved");
  }

  Future<T?> get<T>(
    String uri, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      var response = await _dio.get<T>(
        uri,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data;
    } on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }

  Future<T?> post<T>(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      var response = await _dio.post<T>(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data;
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }

  Future<T?> patch<T>(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      var response = await _dio.patch<T>(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data;
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }

  Future<T?> put<T>(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      var response = await _dio.put<T>(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data;
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }

  Future<T?> delete<T>(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      var response = await _dio.delete<T>(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data;
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }
}

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(
    dio: Dio(),
    hiveService: ref.read(hiveServiceProvider),
    baseUrl: Endpoint.baseUrl,
    // defaultConnectTimeout: const Duration(minutes: 3),
    // defaultReceiveTimeout: const Duration(minutes: 3),
  );
});
