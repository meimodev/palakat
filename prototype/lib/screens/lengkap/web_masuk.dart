import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/tombol.dart';
import 'masuk_langkah.dart';

/// Web · Masuk dan menunggu verifikasi: the signed-out side nav (one item,
/// "Masuk") and the sign-in card centred in the main column.
class WebMasukScreen extends StatefulWidget {
  const WebMasukScreen({super.key});

  @override
  State<WebMasukScreen> createState() => _WebMasukScreenState();
}

class _WebMasukScreenState extends State<WebMasukScreen> {
  final _nav = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return LayoutBuilder(
      builder: (context, k) => HalamanWeb(
        nav: NavSamping(
          key: _nav,
          item: navMasuk,
          aktif: 0,
          pengguna: const Text('Belum masuk'),
        ),
        isi: [
          // `main` is at least the window height minus its padding 28 + 40.
          TengahBarisUtama(
            nav: _nav,
            tinggi: k.maxHeight - 68,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Container(
                    padding: EdgeInsets.all(context.jepit(24, 4, 40)),
                    decoration: BoxDecoration(
                      color: c.permukaan,
                      border: Border.all(color: c.garis),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const LangkahMasuk(
                      stem: 'WebMasuk',
                      jarak: 32,
                      pemulihan: Tautan(
                        ke: 'WebPemulihan',
                        child: TautanMasuk(teksPemulihan),
                      ),
                      hubungkan: Tautan(
                        ke: 'WebAlurMasuk',
                        child: TautanMasuk(teksHubungkan),
                      ),
                      awal: Tombol(
                        teksAwal,
                        onPressed: null,
                        ke: 'WebAwal',
                        jenis: JenisTombol.kedua,
                        ukuran: UkuranTombol.sedang,
                      ),
                      beranda: Tombol(
                        'Buka Beranda',
                        onPressed: null,
                        ke: 'WebBeranda',
                        cara: Cara.ganti,
                      ),
                      terbatas: Tombol(
                        'Buka peruntukan Diakonia',
                        onPressed: null,
                        ke: 'WebTerbatas',
                        cara: Cara.ganti,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The boards' `flex: 1` wrapper that centres the card in `main`'s flex line
/// (WebMasuk, WebPemulihan). That line is the window minus the nav line:
/// beside the nav above 860, below the nav (stretched by HalamanWeb with half
/// the spare height) at 860 and below. The child keeps its own height and is
/// only shifted down, since a taller `main` would shrink the nav's share.
class TengahBarisUtama extends StatefulWidget {
  const TengahBarisUtama({
    super.key,
    required this.nav,
    required this.tinggi,
    required this.child,
  });

  /// The page's NavSamping; its stretched height is measured after each frame.
  final GlobalKey nav;

  /// Window height minus `main`'s vertical padding.
  final double tinggi;
  final Widget child;

  @override
  State<TengahBarisUtama> createState() => _TengahBarisUtamaState();
}

class _TengahBarisUtamaState extends State<TengahBarisUtama> {
  /// First guess: the closed top bar before it is stretched.
  double _tinggiNav = 61;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_ukurNav);
  }

  /// Runs after every frame (the menu toggles inside NavSamping, which does
  /// not rebuild this state), so the card follows the open or closed bar.
  void _ukurNav(_) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback(_ukurNav);
    final h = widget.nav.currentContext?.size?.height;
    if (navSempit(context) && h != null && h != _tinggiNav) {
      setState(() => _tinggiNav = h);
    }
  }

  @override
  Widget build(BuildContext context) => _Geser(
    tinggi: widget.tinggi - (navSempit(context) ? _tinggiNav : 0),
    child: widget.child,
  );
}

/// Lays the child out at its own height and offsets it to the middle of
/// [tinggi] (no offset when the child is taller).
class _Geser extends SingleChildRenderObjectWidget {
  const _Geser({required this.tinggi, required super.child});
  final double tinggi;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderGeser(tinggi);

  @override
  void updateRenderObject(BuildContext context, _RenderGeser r) =>
      r.tinggi = tinggi;
}

class _RenderGeser extends RenderShiftedBox {
  _RenderGeser(this._tinggi) : super(null);

  double _tinggi;
  set tinggi(double v) {
    if (v == _tinggi) return;
    _tinggi = v;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    final anak = child!;
    anak.layout(constraints, parentUsesSize: true);
    size = constraints.constrain(anak.size);
    (anak.parentData! as BoxParentData).offset = Offset(
      0,
      math.max(0, (_tinggi - anak.size.height) / 2),
    );
  }
}
