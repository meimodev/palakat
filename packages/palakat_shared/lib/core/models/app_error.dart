import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_admin/core/constants/enums.dart';

part 'app_error.freezed.dart';
part 'app_error.g.dart';

@freezed
abstract class AppError with _$AppError {
  const AppError._();

  const factory AppError({
    required ErrorType type,
    required String message,
    String? details,
    int? statusCode,
    @Default(null) DateTime? timestamp,
  }) = _AppError;

  factory AppError.network(String message, {String? details}) {
    return AppError(
      type: ErrorType.network,
      message: message,
      details: details,
      timestamp: DateTime.now(),
    );
  }

  factory AppError.validation(String message, {String? details}) {
    return AppError(
      type: ErrorType.validation,
      message: message,
      details: details,
      timestamp: DateTime.now(),
    );
  }

  factory AppError.serverError(String message, {int? statusCode, String? details}) {
    return AppError(
      type: ErrorType.serverError,
      message: message,
      statusCode: statusCode,
      details: details,
      timestamp: DateTime.now(),
    );
  }

  factory AppError.unknown(String message, {String? details}) {
    return AppError(
      type: ErrorType.unknown,
      message: message,
      details: details,
      timestamp: DateTime.now(),

    );
  }

  factory AppError.fromJson(Map<String, dynamic> json) => _$AppErrorFromJson(json);

  /// Get user-friendly error message
  String get userMessage {
    switch (type) {
      case ErrorType.network:
        return 'Network connection error. Please check your internet connection.';
      case ErrorType.validation:
        return message;
      case ErrorType.authentication:
        return 'Authentication required. Please log in again.';
      case ErrorType.authorization:
        return 'You do not have permission to perform this action.';
      case ErrorType.notFound:
        return 'The requested resource was not found.';
      case ErrorType.serverError:
        return 'Server error occurred. Please try again later.';
      case ErrorType.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
