import 'dart:ui';

import 'package:flutter/foundation.dart';

/// The screen set the app shows (README 3.2, D13). The only file that reads
/// `kIsWeb` and the platform (grep check G11).
enum Tata {
  /// Android phone: phone screens, full screen.
  ponsel,

  /// Android tablet (shortest side 600 or more): the web screens, with
  /// TabBeranda, TabTransaksi and TabCatat for the finance home, list and form.
  tablet,

  /// Web, any window width: the web screens.
  web,
}

/// Pure choice of the layout: the web is always [Tata.web]; otherwise a
/// logical shortest side of 600 or more is a tablet.
Tata pilihTata({required bool web, required Size ukuranLogis}) {
  if (web) return Tata.web;
  return ukuranLogis.shortestSide >= 600 ? Tata.tablet : Tata.ponsel;
}

/// [pilihTata] for this device, read once at launch from the first view.
Tata tataPerangkat() {
  final v = PlatformDispatcher.instance.views.first;
  return pilihTata(
    web: kIsWeb,
    ukuranLogis: v.physicalSize / v.devicePixelRatio,
  );
}
