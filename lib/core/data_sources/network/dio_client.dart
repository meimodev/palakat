import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat/core/constants/constants.dart';

import '../data_sources.dart';


class DioClient {
  late Dio _dio;
  late String baseUrl;
  late HiveService hiveService;


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
      };

    // _tokenDio = Dio();
    // _tokenDio.options = _dio.options;

    if (withAuth) {
      _dio.interceptors.add(
        QueuedInterceptorsWrapper(
          onRequest: (
              RequestOptions options,
              RequestInterceptorHandler handler,
              ) async {
            final auth = hiveService.getAuth();
            if (auth != null) {
              options.headers['Authorization'] = 'Bearer ${auth.accessToken}';
            }


            if (options.data != null &&
                (options.data is Map || options.data is List)) {
              options.data = json.encode(options.data);
            }

            handler.next(options);
          },
          onError: (e, handler) => {
            //print log the error in here
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
        logPrint: (obj) {
          log(obj.toString());
        },
        requestBody: true,
      );
      _dio.interceptors.add(logInterceptor);
      // _tokenDio.interceptors.add(logInterceptor);

      // _dio.interceptors.add(
      //   CurlLoggerDioInterceptor(printOnSuccess: true),
      // );
      // _tokenDio.interceptors.add(
      //   CurlLoggerDioInterceptor(printOnSuccess: true),
      // );
    }


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
    defaultConnectTimeout: const Duration(minutes: 3),
    defaultReceiveTimeout: const Duration(minutes: 3),

  );
});

