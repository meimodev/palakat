import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:developer';
import 'dart:io';

import 'package:curl_logger_dio_interceptor/curl_logger_dio_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat/core/constants/constants.dart';

import '../data_sources.dart';

class DioClient {
  final Dio _dio;
  final HiveService _hiveService;
  late String baseUrl;
  static final int _refreshAuthTokenMaxAttempt = 3;
  static int _refreshAuthTokenAttempt = 0;

  DioClient({
    required this.baseUrl,
    required Dio dio,
    required HiveService hiveService,
    bool withAuth = true,
    Duration defaultConnectTimeout = const Duration(minutes: 2),
    Duration defaultReceiveTimeout = const Duration(minutes: 2),
  })  : _dio = dio,
        _hiveService = hiveService{
    _dio
      ..options.baseUrl = baseUrl
      ..options.connectTimeout = defaultConnectTimeout
      ..options.receiveTimeout = defaultReceiveTimeout
      ..options.responseType = ResponseType.json
      ..options.validateStatus = (status) {
        // Consider status codes less than 500 except 401 as success
        return status! < 500 && status != 401;
      }
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
              try {
                _refreshAuthTokenAttempt++;
                dev.log(
                  "[DIO CLIENT] refresh auth token Attempt: $_refreshAuthTokenAttempt of max $_refreshAuthTokenMaxAttempt",
                );
                if (_refreshAuthTokenAttempt < _refreshAuthTokenMaxAttempt) {
                  await _refreshToken();
                  final options = error.response!.requestOptions;

                  try {
                    final response = await _dio.fetch(options);

                    if (response.statusCode != null && response.statusCode! >= 400) {
                      return handler.reject(DioException(
                        requestOptions: options,
                        response: response,
                        error: response.statusMessage,
                        type: DioExceptionType.badResponse,
                      ));
                    }
                    return handler.resolve(response);
                  } catch (retryError) {
                    dev.log("[DIO CLIENT] catch retry error $retryError");
                    return handler.next(retryError is DioException ? retryError : DioException(
                      requestOptions: options,
                      error: retryError.toString(),
                    ));
                  }
                }
              } catch (e) {
                dev.log("[DIO CLIENT] catch refresh token $e");
                return handler.next(e is DioException ? e : DioException(
                  requestOptions: error.requestOptions,
                  error: e.toString(),
                ));
              }
            }
            return handler.next(error);
          },
          onResponse: (response, handler) {
            if (response.data == null) {
             return handler.reject(DioException(
              requestOptions: response.requestOptions,
              response: response,
              error: "response is returned null",
              type: DioExceptionType.badResponse,
             ));
            }
            final body = response.data as Map<String, dynamic>;
            if (body['data'] == null) {
              return handler.reject(DioException(
                requestOptions: response.requestOptions,
                response: response,
                error: "property data is unavailable in the body response, see backend response scheme",
                type: DioExceptionType.badResponse,
              ));
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

  Future<void> _refreshToken() async {
    if (_hiveService.getAuth() != null) {
      await _hiveService.deleteAuth();
    }

    final username = dotenv.env['X_USERNAME'];
    final password = dotenv.env['X_PASSWORD'];

    final response = await _dio.get<Map<String, dynamic>>(
      Endpoint.signing,
      options: Options(
        headers: {'x-username': username, 'x-password': password},
      ),
    );

    final token = response.data?['data'] as String;
    final authData = AuthData(accessToken: token, refreshToken: token);
    await _hiveService.saveAuth(authData);

    dev.log("[DIO CLIENT] Token successfully obtained and saved");
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
  );
});
