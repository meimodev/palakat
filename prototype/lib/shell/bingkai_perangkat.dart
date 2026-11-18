import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';

import '../boards.dart';
import '../theme/palakat_tema.dart';
import '../widgets/ikon.dart';
import '../widgets/tekan.dart';
import 'panel_keadaan.dart';
import 'prototipe_state.dart';

/// Device frame around the router's navigator, plus the Keadaan panel
/// (components.md 4.8 and 4.9 placement, navigation.md 5.2). Used once, in
/// `MaterialApp.router(builder: …)`; [router] is passed in because the
/// builder's context sits above the router.
class BingkaiPerangkat extends StatefulWidget {
  const BingkaiPerangkat({
    super.key,
    required this.router,
    required this.child,
  });
  final GoRouter router;
  final Widget child;

  @override
  State<BingkaiPerangkat> createState() => _BingkaiPerangkatState();
}

class _BingkaiPerangkatState extends State<BingkaiPerangkat> {
  // Keeps the navigator's state when the layout around it changes.
  final _kunci = GlobalKey();
  bool _buka = false;
  String? _jalurTadi;

  void _setBuka(bool v) => setState(() => _buka = v);

  @override
  void initState() {
    super.initState();
    widget.router.routerDelegate.addListener(_rute);
  }

  @override
  void didUpdateWidget(BingkaiPerangkat old) {
    super.didUpdateWidget(old);
    if (old.router != widget.router) {
      old.router.routerDelegate.removeListener(_rute);
      widget.router.routerDelegate.addListener(_rute);
    }
  }

  @override
  void dispose() {
    widget.router.routerDelegate.removeListener(_rute);
    super.dispose();
  }

  // The delegate can notify while the Router builds (first route): rebuild after that frame.
  void _rute() {
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final lokasi = lokasiAtas(widget.router);
    if (lokasi.jalur != _jalurTadi) {
      _jalurTadi = lokasi.jalur;
      _buka = false; // a new page starts with the floating panel closed
    }
    final c = context.warna;
    final k = PrototypeState.of(context);
    final mq = MediaQuery.of(context);
    final layar = mq.size;
    final ponsel =
        lokasi.stem != null &&
        papanMenurutStem[lokasi.stem]!.bentuk == Bentuk.ponsel;
    final navigator = KeyedSubtree(key: _kunci, child: widget.child);
    Widget panel({VoidCallback? tutup}) =>
        PanelKeadaan(router: widget.router, lokasi: lokasi, onTutup: tutup);

    if (ponsel && layar.width > 600 && k.bingkaiPonsel) {
      final samping = layar.width >= 800; // panel always open beside the frame
      final tinggiBebas = layar.height - 48;
      final s = math.min(
        1.0,
        math.min(
          tinggiBebas / 844,
          (layar.width - 48 - (samping ? 344 : 0)) / 390,
        ),
      );
      final bingkai = SizedBox(
        width: 390 * s,
        height: 844 * s,
        child: FittedBox(
          child: SizedBox(
            width: 390,
            height: 844,
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(
                border: Border.all(color: c.garisTegas),
                borderRadius: BorderRadius.circular(36),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: MediaQuery(
                  data: mq.copyWith(
                    size: const Size(390, 844),
                    padding: EdgeInsets.zero,
                    viewPadding: EdgeInsets.zero,
                    viewInsets: EdgeInsets.zero,
                  ),
                  child: navigator,
                ),
              ),
            ),
          ),
        ),
      );
      final latar = ColoredBox(
        color: c.garis,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: samping
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      bingkai,
                      const SizedBox(width: 24),
                      SizedBox(
                        width: 320,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: tinggiBebas),
                          child: panel(),
                        ),
                      ),
                    ],
                  )
                : bingkai,
          ),
        ),
      );
      return samping
          ? latar
          : _mengambang(context, latar, panel, layar, lembar: false);
    }
    return _mengambang(
      context,
      ponsel ? SafeArea(child: navigator) : navigator,
      panel,
      layar,
      lembar: ponsel,
    );
  }

  /// The page with a floating way into the panel: a handle at the right edge
  /// opening a sheet ([lembar], full-screen phone boards), otherwise a round
  /// button bottom-right opening a 320-wide panel.
  Widget _mengambang(
    BuildContext context,
    Widget isi,
    Widget Function({VoidCallback? tutup}) panel,
    Size layar, {
    required bool lembar,
  }) {
    final c = context.warna;
    void tutup() => _setBuka(false);
    return Stack(
      children: [
        Positioned.fill(child: isi),
        if (!_buka && lembar)
          Positioned(
            right: 0,
            top: (layar.height - 64) / 2,
            child: Tekan(
              onTap: () => _setBuka(true),
              label: 'Keadaan',
              radius: 12,
              minTinggi: 64,
              // 44 wide hit area (accessibility), 24 wide handle at the edge.
              child: Align(
                alignment: Alignment.centerRight,
                widthFactor: 1,
                child: Container(
                  width: 24,
                  height: 64,
                  decoration: BoxDecoration(
                    color: c.tinta,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(12),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: PalakatIkon(
                      Ikon.lainnya,
                      ukuran: 16,
                      warna: c.permukaan,
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (!_buka && !lembar)
          Positioned(
            right: 16,
            bottom: 16,
            child: Tekan(
              onTap: () => _setBuka(true),
              label: 'Keadaan',
              radius: 24,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: c.tinta,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: PalakatIkon(Ikon.lainnya, warna: c.permukaan),
              ),
            ),
          ),
        if (_buka) ...[
          Positioned.fill(
            child: GestureDetector(
              onTap: tutup,
              child: ColoredBox(color: c.tirai),
            ),
          ),
          if (lembar)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: layar.height * .85),
                child: panel(tutup: tutup),
              ),
            )
          else
            Positioned(
              top: 16,
              right: 16,
              width: math.min(320, layar.width - 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: layar.height - 32),
                child: panel(tutup: tutup),
              ),
            ),
        ],
      ],
    );
  }
}
