import 'package:flutter/material.dart';

import '../boards.dart';

/// Session state of the prototype chrome (components.md 4.9, CONVENTIONS
/// "Prototype chrome"): the global switches and every board's tweak values.
/// Nothing persists; a reload starts from the defaults.
class PrototypeState extends ChangeNotifier {
  bool _jabatanKosong = false, _gelap = false, _kurangiGerak = false;
  bool _bingkaiPonsel = true, _urutPerjalanan = false, _dibuang = false;
  final Map<String, Map<String, Object>> _tweak = {};

  /// stem → prototype devices registered by that board ([AlatPrototipe]).
  /// Only the Keadaan panel listens.
  final ValueNotifier<Map<String, List<Widget>>> perangkat = ValueNotifier(
    const {},
  );

  /// Global: the Operator Yanti Sumual runs the vacant Bendahara Jemaat post.
  bool get jabatanKosong => _jabatanKosong;
  set jabatanKosong(bool v) => _ubah(() => _jabatanKosong = v);

  /// Terang (false) / Gelap (true).
  bool get gelap => _gelap;
  set gelap(bool v) => _ubah(() => _gelap = v);
  ThemeMode get tema => _gelap ? ThemeMode.dark : ThemeMode.light;
  set tema(ThemeMode m) => gelap = m == ThemeMode.dark;

  /// Forces reduced motion on (applied once at the app root, components.md 1.5).
  bool get kurangiGerak => _kurangiGerak;
  set kurangiGerak(bool v) => _ubah(() => _kurangiGerak = v);

  /// Phone boards in the 390 × 844 device frame on wide windows.
  bool get bingkaiPonsel => _bingkaiPonsel;
  set bingkaiPonsel(bool v) => _ubah(() => _bingkaiPonsel = v);

  /// Launcher ordering: "Halaman kanvas" (false) or "Perjalanan jabatan" (true).
  bool get urutPerjalanan => _urutPerjalanan;
  set urutPerjalanan(bool v) => _ubah(() => _urutPerjalanan = v);

  /// Current value of a board's tweak, or its `data-props` default.
  /// `jabatanKosong` reads the global switch.
  Object tweak(String stem, String nama) {
    if (nama == 'jabatanKosong') return _jabatanKosong;
    return _tweak[stem]?[nama] ?? _bawaan(stem, nama);
  }

  /// Sets a board's tweak; `jabatanKosong` writes the global switch.
  void setTweak(String stem, String nama, Object v) {
    if (nama == 'jabatanKosong') {
      jabatanKosong = v as bool;
      return;
    }
    _bawaan(stem, nama); // throws on an unknown stem or tweak
    _ubah(() => (_tweak[stem] ??= {})[nama] = v);
  }

  /// components.md 4.9 names for [tweak] and [setTweak].
  Object nilai(String stem, String nama) => tweak(stem, nama);
  void setel(String stem, String nama, Object v) => setTweak(stem, nama, v);

  // stem → live registrations (owner, devices), oldest first. Parent and child
  // pages of one board share a stem; the newest (the top page) is published.
  final Map<String, List<(Object, List<Widget>)>> _alat = {};

  /// Called by [AlatPrototipe] on mount and on every rebuild.
  void pasangAlat(Object pemilik, String stem, List<Widget> alat) {
    final d = _alat[stem] ??= [];
    final i = d.indexWhere((e) => identical(e.$1, pemilik));
    i < 0 ? d.add((pemilik, alat)) : d[i] = (pemilik, alat);
    _terbitAlat(stem);
  }

  /// Called by [AlatPrototipe] on dispose: the page below shows its own again.
  void lepasAlat(Object pemilik, String stem) {
    _alat[stem]?.removeWhere((e) => identical(e.$1, pemilik));
    _terbitAlat(stem);
  }

  void _terbitAlat(String stem) {
    if (_dibuang) return;
    final d = _alat[stem];
    final baru = {...perangkat.value}..remove(stem);
    if (d != null && d.isNotEmpty) {
      baru[stem] = d.last.$2;
    } else {
      _alat.remove(stem);
    }
    perangkat.value = baru;
  }

  static Object _bawaan(String stem, String nama) {
    final p = papanMenurutStem[stem];
    if (p == null) throw ArgumentError.value(stem, 'stem', 'not a board');
    for (final t in p.tweaks) {
      if (t.nama == nama) return t.bawaan;
    }
    throw ArgumentError.value(nama, 'nama', 'no such tweak on $stem');
  }

  void _ubah(void Function() f) {
    f();
    notifyListeners();
  }

  @override
  void dispose() {
    _dibuang = true;
    perangkat.dispose();
    super.dispose();
  }

  /// The app's state; rebuilds [context] on every change.
  static PrototypeState of(BuildContext context) => maybeOf(context)!;

  static PrototypeState? maybeOf(BuildContext context, {bool dengar = true}) =>
      dengar
      ? context.dependOnInheritedWidgetOfExactType<PrototipeLingkup>()?.notifier
      : context.getInheritedWidgetOfExactType<PrototipeLingkup>()?.notifier;
}

/// Provides the [PrototypeState] at the app root.
class PrototipeLingkup extends InheritedNotifier<PrototypeState> {
  const PrototipeLingkup({
    super.key,
    required PrototypeState keadaan,
    required super.child,
  }) : super(notifier: keadaan);
}

extension PrototipeKonteks on BuildContext {
  /// The app's [PrototypeState]; the caller rebuilds on every change.
  PrototypeState get prototipe => PrototypeState.of(this);

  /// A board tweak's current value, typed: `context.tweak<String>('Main', 'bulan')`.
  T tweak<T extends Object>(String stem, String nama) =>
      prototipe.tweak(stem, nama) as T;
}
