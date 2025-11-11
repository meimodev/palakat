import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:palakat_admin/core/models/app_error.dart';

/// Centralized error mapping utilities with comprehensive logging
class ErrorMapper {
  /// Map DioException to AppError with a contextual message
  static AppError fromDio(DioException error, String message, [StackTrace? st]) {
    // Comprehensive logging with structured information
    _logDioError(error, message, st);
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppError.network('$message: Request timeout', details: error.message);
      case DioExceptionType.badResponse:
        return AppError.serverError(
          '$message: Server error',
          statusCode: error.response?.statusCode,
          details: 'Status: ${error.response?.statusCode}, Data: ${error.response?.data}',
        );
      case DioExceptionType.cancel:
        return AppError.network('$message: Request cancelled', details: error.message);
      case DioExceptionType.connectionError:
        return AppError.network('$message: Connection error', details: 'Please check your internet connection');
      case DioExceptionType.badCertificate:
        return AppError.network('$message: SSL certificate error', details: error.message);
      case DioExceptionType.unknown:
        return AppError.network('$message: Unknown error', details: error.message);
    }
  }

  /// Wrap an unknown error with AppError.unknown and context message
  static AppError unknown(String message, Object error, StackTrace st) {
    // Comprehensive logging with full error details
    _logUnknownError(message, error, st);
    return AppError.unknown('$message: $error', details: error.toString());
  }

  /// Comprehensive logging for DioException with stacktrace
  static void _logDioError(DioException error, String context, StackTrace? st) {
    final buffer = StringBuffer();
    buffer.writeln('══════════════════════════════════════════════════════════════');
    buffer.writeln('DIO ERROR: $context');
    buffer.writeln('══════════════════════════════════════════════════════════════');
    buffer.writeln('Type: ${error.type}');
    buffer.writeln('Message: ${error.message}');
    
    // Stacktrace
    if (st != null) {
      buffer.writeln('──────────────────────────────────────────────────────────────');
      buffer.writeln('STACKTRACE:');
      final stackLines = st.toString().split('\n').take(15);
      for (final line in stackLines) {
        buffer.writeln('  $line');
      }
      if (st.toString().split('\n').length > 15) {
        buffer.writeln('  ... (truncated)');
      }
    }
    
    buffer.writeln('══════════════════════════════════════════════════════════════');
    
    dev.log(
      buffer.toString(),
      name: 'ErrorMapper',
      error: error,
      stackTrace: st,
      level: 1000, // Error level
    );
  }

  /// Comprehensive logging for unknown errors
  static void _logUnknownError(String context, Object error, StackTrace? st) {
    final buffer = StringBuffer();
    buffer.writeln('══════════════════════════════════════════════════════════════');
    buffer.writeln('UNKNOWN ERROR: $context');
    buffer.writeln('══════════════════════════════════════════════════════════════');
    buffer.writeln('Error Type: ${error.runtimeType}');
    buffer.writeln('Error: $error');
    
    if (st != null) {
      buffer.writeln('──────────────────────────────────────────────────────────────');
      buffer.writeln('STACKTRACE:');
      final stackLines = st.toString().split('\n').take(20);
      for (final line in stackLines) {
        buffer.writeln('  $line');
      }
      if (st.toString().split('\n').length > 20) {
        buffer.writeln('  ... (truncated)');
      }
    }
    
    buffer.writeln('══════════════════════════════════════════════════════════════');
    
    dev.log(
      buffer.toString(),
      name: 'ErrorMapper',
      error: error,
      stackTrace: st,
      level: 1000, // Error level
    );
  }

}
