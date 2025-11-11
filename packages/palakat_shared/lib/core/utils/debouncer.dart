import 'dart:async';

/// Utility class for debouncing function calls
/// Prevents excessive API calls or computations during rapid user input
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  /// Execute the callback after the specified delay
  /// If called again before the delay expires, the previous call is cancelled
  void call(VoidCallback callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  /// Cancel any pending callback
  void cancel() {
    _timer?.cancel();
  }

  /// Dispose of the debouncer and cancel any pending callbacks
  void dispose() {
    _timer?.cancel();
  }
}

/// Typedef for void callback functions
typedef VoidCallback = void Function();
