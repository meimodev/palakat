class Result<T, Failure> {
  final T? _success;
  final Failure? _failure;

  Result.success(T value) : _success = value, _failure = null;

  Result.failure(Failure failure) : _success = null, _failure = failure;

  V? when<V>({
    required V? Function(T data) onSuccess,
    void Function(Failure failure)? onFailure,
  }) {
    if (_success != null) {
      return onSuccess(_success as T);
    }
    onFailure!(_failure as Failure);
    return null;
  }

  Result<R, F2> mapTo<R, F2>({
    required R Function(T) onSuccess,
    F2 Function(Failure)? onFailure,
  }) {
    if (_success != null) {
      return Result.success(onSuccess(_success as T));
    }

    if (onFailure != null) {
      return Result.failure(onFailure(_failure as Failure));
    } else {
      return Result.failure(_failure as dynamic);
    }
  }
}

class Failure implements Exception{
  final String message;
  final int? code;

  Failure(this.message, [this.code]);
}
