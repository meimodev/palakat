/// The church's clock (README 3.3). Times are WITA (UTC+8) wall-clock times,
/// held as `DateTime.utc` values whose fields read in WITA, so they never
/// depend on the device's time zone.
abstract class Clock {
  DateTime now();
}

/// The real time: now in WITA.
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now().toUtc().add(const Duration(hours: 8));
}

/// A clock for tests that stands still until [majukan] moves it.
class FixedClock implements Clock {
  FixedClock(this._saat);
  DateTime _saat;

  @override
  DateTime now() => _saat;

  void majukan(Duration d) => _saat = _saat.add(d);
}
