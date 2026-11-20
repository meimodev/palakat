/// Why a command did not happen (README 3.4). The UI renders it through
/// `widgets/penolakan.dart`: "Tidak dapat dilakukan: {action}." followed by
/// [because] and, when known, "Yang perlu bertindak: {whoCanAct}".
class Refusal {
  const Refusal({required this.action, required this.because, this.whoCanAct});

  /// The board's action word: 'Catat penugasan', 'Bukukan'.
  final String action;

  /// The board's reason sentence, ending with a full stop.
  final String because;

  /// Names of who may act instead ('Pnt. Jefry Wowor'), or null.
  final String? whoCanAct;

  @override
  String toString() => 'Refusal($action: $because)';
}

/// The outcome of every command (README 3.4): [Ok] or [Refused].
sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;

  /// The value of an [Ok]; throws on [Refused].
  T get value => switch (this) {
    Ok<T>(:final value) => value,
    Refused<T>(:final refusal) => throw StateError('$refusal'),
  };

  /// The refusal of a [Refused], or null.
  Refusal? get refusal => switch (this) {
    Ok<T>() => null,
    Refused<T>(:final refusal) => refusal,
  };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  @override
  final T value;
}

final class Refused<T> extends Result<T> {
  const Refused(this.refusal);
  @override
  final Refusal refusal;
}
