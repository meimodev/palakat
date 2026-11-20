import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The app theme: light at every launch (the boards are drawn light); the
/// "Tema gelap" switch in AkunSaya turns dark on for the rest of the run.
/// Held in memory only, like all state (D6).
final temaProvider = NotifierProvider<TemaNotifier, ThemeMode>(
  TemaNotifier.new,
);

class TemaNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light;

  void gelap(bool on) => state = on ? ThemeMode.dark : ThemeMode.light;
}
