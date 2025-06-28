import 'dart:developer' as dev;

import 'package:dio/dio.dart';

class NetworkExceptions {
  String? message;
  dynamic stackTrace;
  dynamic error;


  /// [INFO]
  /// This function called in the catch in try...catch, and then get the error
  /// and stacktrace, then in this function, will detect,
  /// and convert to NetworkExceptions error so later can be handled on one place
   NetworkExceptions.fromDioException(dynamic error, dynamic stackTrace) {

    if (error is! Exception) {
      message = "Unknown error, Exception not defined";
    }

    try {
      if (error is! DioException) {
        message = "Unknown Dio error, Dio Exception not defined";
      }

      switch (error.type) {
        case DioExceptionType.cancel:
          message =  "canceled by user";
        case DioExceptionType.receiveTimeout:
          message =  "receiver timeout";
        case DioExceptionType.sendTimeout:
          message =  "sender timeout";
        case DioExceptionType.connectionTimeout:
          message =  "request timeout";
        case DioExceptionType.connectionError:
          message =  "connection timeout";

        /// [INFO]
        /// for catch the error response status code
        case DioExceptionType.badResponse:
          switch (error.response?.statusCode) {
            case 400:
              message = "Bad request";
            case 401:
              message = "Invalid Credential";
            case 403:
              message = "Unauthorized request";
            case 404:
              message = "Not Found";
            case 422:
              message = "Unprocessable Entity";
            case 500:
              message = "Internal Server Error";
            case 503:
              message = "Service Unavailable";
            default:
              message = "Unknown Dio error, Dio Exception not defined, with status code ${error.response?.statusCode}";
          }
      }
    } catch (e) {
      message = "Unknown Exception error, while try-catch error.type";
    }

    dev.log(
      error.toString(),
      stackTrace: stackTrace,
      error: error,
      name: 'DIO NETWORK EXCEPTION',
    );

   }
}
