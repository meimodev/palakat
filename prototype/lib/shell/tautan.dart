import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/layar.dart';
import '../app/tata.dart';
import '../providers/actor.dart';
import '../providers/layout.dart';
import '../widgets/tekan.dart';

/// How a [Tautan] opens its target (navigation.md, Quick reference).
enum Cara {
  /// `push`: drill-ins.
  dorong,

  /// `go`: side-nav and tab items, sign in and out, "finish and go home".
  ganti,

  /// Pop when the page directly below is the target or one of its child
  /// routes, otherwise `go`: back arrows, breadcrumbs, "Kembali …" links.
  naik,
}

/// Page locations of the router's stack, bottom to top, with shell and pushed
/// matches flattened (navigation.md 5.1): `['/', '/keuangan', '/keuangan/catat']`.
List<String> tumpukanHalaman(GoRouter router) {
  final hasil = <String>[];
  void jalan(List<RouteMatchBase> daftar) {
    for (final m in daftar) {
      if (m is ShellRouteMatch) {
        jalan(m.matches);
      } else {
        hasil.add(m.matchedLocation);
      }
    }
  }

  jalan(router.routerDelegate.currentConfiguration.matches);
  return hasil;
}

/// Kind "up" (navigation.md 5.1): pop when the page directly below is
/// [lokasi] or one of its child routes, otherwise `go(lokasi)`.
void kembaliKeDengan(GoRouter router, String lokasi) {
  final t = tumpukanHalaman(router);
  if (t.length >= 2) {
    final bawah = t[t.length - 2];
    if (bawah == lokasi || bawah.startsWith('$lokasi/')) {
      router.pop();
      return;
    }
  }
  router.go(lokasi);
}

/// Whether the current layout has a screen for [ke]: a screen drawn for both
/// layouts leaves out a link the other layout lacks (D13).
bool adaLayar(BuildContext context, Layar ke) => ke.adaUntuk(
  ProviderScope.containerOf(context, listen: false).read(layoutProvider),
);

extension TautanKonteks on BuildContext {
  /// Kind "up" to a screen: see [kembaliKeDengan].
  void naikKe(Layar ke, {Map<String, String> param = const {}, String? anak}) =>
      kembaliKeDengan(GoRouter.of(this), ke.lokasi(param: param, anak: anak));

  /// `push` to a screen or one of its child routes.
  void dorongKe(
    Layar ke, {
    Map<String, String> param = const {},
    String? anak,
  }) => GoRouter.of(this).push(ke.lokasi(param: param, anak: anak));

  /// `go` to a screen or one of its child routes.
  void gantiKe(
    Layar ke, {
    Map<String, String> param = const {},
    String? anak,
  }) => GoRouter.of(this).go(ke.lokasi(param: param, anak: anak));
}

/// Every control that opens another screen (README 3.6): [ke] with its path
/// parameters [param], or its child route [anak] (`'rinci'`, `'kasus/7'`).
///
/// - A link to the page open now (kind self) does not navigate: it calls
///   [diSini], or does nothing.
/// - [Cara.dorong] to a phone screen with child routes that is already in the
///   stack pops down to it ([layarBerKendali]; a ShellRoute has one navigator
///   key).
/// - A link to a screen the current layout does not have fails an assert in
///   debug (D13).
/// - A link to a screen whose module is not active renders nothing (D21).
class Tautan extends ConsumerWidget {
  const Tautan({
    super.key,
    required this.ke,
    required this.child,
    this.param = const {},
    this.anak,
    this.cara = Cara.dorong,
    this.label,
    this.radius = 0,
    this.diSini,
    this.minLebar = 44,
    this.minTinggi = 44,
  });

  final Layar ke;
  final Map<String, String> param;
  final String? anak;
  final Widget child;
  final Cara cara;

  /// Board aria-label; replaces the child's own semantics.
  final String? label;

  /// For the focus ring.
  final double radius;

  /// In-board effect of a self link.
  final VoidCallback? diSini;

  /// Target minimum, passed to [Tekan]; below 44 only where the board draws
  /// a smaller fixed size.
  final double minLebar;
  final double minTinggi;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tata = ref.watch(layoutProvider);
    assert(
      ke.adaUntuk(tata),
      'Tautan ke Layar.${ke.name}: tidak ada layar untuk Tata.${tata.name}',
    );
    // A module that is not active leaves no trace (D21, KeadaanUmum).
    if (!ref.watch(canProvider).moduleActive(ke.modulLayar.modul)) {
      return const SizedBox.shrink();
    }
    return Tekan(
      onTap: () => buka(context),
      label: label,
      radius: radius,
      peran: PeranTekan.tautan,
      minLebar: minLebar,
      minTinggi: minTinggi,
      child: child,
    );
  }

  /// What a press does; public so a text span or chip can reuse it.
  void buka(BuildContext context) {
    final router = GoRouter.of(context);
    final tata = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(layoutProvider);
    final tujuan = ke.lokasi(param: param, anak: anak);
    final t = tumpukanHalaman(router);
    if (t.isNotEmpty && t.last == tujuan) {
      diSini?.call();
      return;
    }
    switch (cara) {
      case Cara.ganti:
        router.go(tujuan);
      case Cara.naik:
        kembaliKeDengan(router, tujuan);
      case Cara.dorong:
        if (tata != Tata.ponsel ||
            !layarBerKendali.contains(ke) ||
            !t.contains(tujuan)) {
          router.push(tujuan);
          return;
        }
        // The screen is in the stack: pop down to it.
        var s = t;
        while (s.length > 1 && s.last != tujuan) {
          router.pop();
          final baru = tumpukanHalaman(router);
          if (baru.length >= s.length) break; // a pop that did not apply
          s = baru;
        }
    }
  }
}
