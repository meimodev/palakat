import 'package:freezed_annotation/freezed_annotation.dart';
import 'app_error.dart';

part 'async_state.freezed.dart';
part 'async_state.g.dart';

/// Generic async state wrapper for handling loading, success, and error states
/// This provides consistent state management across all async operations
@Freezed(genericArgumentFactories: true)
sealed class AsyncState<T> with _$AsyncState<T> {
  /// Loading state - operation in progress
  const factory AsyncState.loading() = AsyncLoading<T>;
  
  /// Success state - operation completed successfully
  const factory AsyncState.success(T data) = AsyncSuccess<T>;
  
  /// Error state - operation failed
  const factory AsyncState.error(AppError error) = AsyncError<T>;

  factory AsyncState.fromJson(Map<String, dynamic> json, T Function(Object?) fromJsonT) =>
      _$AsyncStateFromJson(json, fromJsonT);
}

/// Extension methods for AsyncState to make it easier to work with
/// Note: Renamed to avoid conflicts with Freezed's generated methods
extension AsyncStateHelpers<T> on AsyncState<T> {
  /// Check if the state is loading
  bool get isLoading => this is AsyncLoading<T>;
  
  /// Check if the state has data
  bool get hasData => this is AsyncSuccess<T>;
  
  /// Check if the state has an error
  bool get hasError => this is AsyncError<T>;
  
  /// Get the data if available, null otherwise
  T? get dataOrNull => switch (this) {
    AsyncSuccess<T> success => success.data,
    _ => null,
  };
  
  /// Get the error if available, null otherwise
  AppError? get errorOrNull => switch (this) {
    AsyncError<T> error => error.error,
    _ => null,
  };
  
  /// Transform the data if in success state
  AsyncState<R> mapData<R>(R Function(T data) transform) {
    return switch (this) {
      AsyncSuccess<T> success => AsyncState.success(transform(success.data)),
      AsyncLoading<T> _ => AsyncState.loading(),
      AsyncError<T> error => AsyncState.error(error.error),
    };
  }
}
