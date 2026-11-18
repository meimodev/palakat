import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../widgets/tekan.dart';
import 'kendali.dart';

/// How a [Tautan] opens its target (navigation.md, Quick reference).
enum Cara {
  /// `push('/X')`: drill-ins.
  dorong,

  /// `go('/X')`: side-nav and tab items, sign in and out, "finish and go home".
  ganti,

  /// `kembaliKe('/X')`: back arrows, breadcrumbs, "Kembali …" links.
  naik,
}

/// Page locations of the router's stack, bottom to top, with shell and pushed
/// matches flattened (navigation.md 5.1): `['/', '/Main', '/Main/catat']`.
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

extension TautanKonteks on BuildContext {
  /// `context.kembaliKe('/Main')`: see [kembaliKeDengan].
  void kembaliKe(String lokasi) => kembaliKeDengan(GoRouter.of(this), lokasi);
}

/// Every control that opens another board (CONVENTIONS, components.md 1.6,
/// navigation.md 3.1). [ke] is a board stem (`'WebBukti'`) or a child route of
/// the board itself (`'Main/catat'`).
///
/// - A link to the page open now (kind self) does not navigate: it calls
///   [diSini], or does nothing.
/// - [Cara.dorong] to a board with child routes that is already in the stack
///   pops down to `/<ke>` and resets that board (navigation.md 2.1, 5.1).
class Tautan extends StatelessWidget {
  const Tautan({
    super.key,
    required this.ke,
    required this.child,
    this.cara = Cara.dorong,
    this.label,
    this.radius = 0,
    this.diSini,
  });

  final String ke;
  final Widget child;
  final Cara cara;

  /// Board aria-label; replaces the child's own semantics.
  final String? label;

  /// For the focus ring.
  final double radius;

  /// In-board effect of a self link.
  final VoidCallback? diSini;

  @override
  Widget build(BuildContext context) => Tekan(
    onTap: () => buka(GoRouter.of(context)),
    label: label,
    radius: radius,
    peran: PeranTekan.tautan,
    child: child,
  );

  /// What a press does; public so chrome outside the navigator can reuse it.
  void buka(GoRouter router) {
    final tujuan = '/$ke';
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
        final ulang = ulangPapan[ke];
        if (ulang == null) {
          router.push(tujuan);
          return;
        }
        // The board is in the stack: pop down to its root page, then reset it.
        var s = t;
        while (s.length > 1 && s.last != tujuan) {
          router.pop();
          final baru = tumpukanHalaman(router);
          if (baru.length >= s.length) break; // a pop that did not apply
          s = baru;
        }
        ulang();
    }
  }
}
