import 'dart:async';
import 'package:flutter/material.dart';

/// A utility class for debouncing function calls.
///
/// Debouncing delays the execution of a function until after a specified
/// duration has elapsed since the last time it was invoked.
///
/// This is useful for scenarios like search fields where you want to wait
/// for the user to stop typing before making an API call.
///
/// Example usage:
/// ```dart
/// final debouncer = Debouncer(milliseconds: 500);
///
/// TextField(
///   onChanged: (value) {
///     debouncer.run(() {
///       // This will only execute 500ms after the user stops typing
///       searchApi(value);
///     });
///   },
/// )
///
/// // Or use the call operator (backward compatible):
/// debouncer(() => searchApi(value));
///
/// // Don't forget to dispose when done
/// @override
/// void dispose() {
///   debouncer.dispose();
///   super.dispose();
/// }
/// ```
class Debouncer {
  /// Creates a debouncer with the specified delay.
  ///
  /// Either [milliseconds] or [delay] must be provided.
  /// [milliseconds] takes precedence if both are provided.
  Debouncer({
    int? milliseconds,
    Duration? delay,
  })  : assert(
          milliseconds != null || delay != null,
          'Either milliseconds or delay must be provided',
        ),
        milliseconds = milliseconds ?? delay!.inMilliseconds;

  /// The delay duration in milliseconds.
  final int milliseconds;

  Timer? _timer;

  /// Runs the provided action after the debounce delay.
  ///
  /// If called again before the delay expires, the previous timer is cancelled
  /// and a new one is started.
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  /// Call operator for backward compatibility.
  ///
  /// Allows using the debouncer as a function: `debouncer(() => action())`
  void call(VoidCallback action) => run(action);

  /// Cancels any pending debounced action.
  void cancel() {
    _timer?.cancel();
  }

  /// Disposes the debouncer and cancels any pending actions.
  ///
  /// Should be called when the debouncer is no longer needed (e.g., in dispose()).
  void dispose() {
    _timer?.cancel();
  }
}
