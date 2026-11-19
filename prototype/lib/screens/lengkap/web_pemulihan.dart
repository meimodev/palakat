import 'package:flutter/material.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/perangkat_prototipe.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/tombol.dart';
import 'pemulihan.dart';

class WebPemulihanScreen extends StatefulWidget {
  const WebPemulihanScreen({super.key});

  @override
  State<WebPemulihanScreen> createState() => _WebPemulihanScreenState();
}

class _WebPemulihanScreenState extends State<WebPemulihanScreen> {
  /// Bumped by the self nav item "Pemulihan akun": a fresh step block, as
  /// reopening the board on the canvas.
  int _generasi = 0;

  /// The top bar's height below 860 (it grows while the menu is open).
  final _nav = GlobalKey();
  double _tinggiNav = 61;

  void _ulang() => setState(() => _generasi++);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_ukurNav);
  }

  /// Runs after every frame (the menu toggles inside NavSamping, which does
  /// not rebuild this state), so the box follows the open or closed bar.
  void _ukurNav(_) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback(_ukurNav);
    final h = _nav.currentContext?.size?.height;
    if (navSempit(context) && h != null && h != _tinggiNav) {
      setState(() => _tinggiNav = h);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final sempit = navSempit(context);
    // main: padding 28 … 40 around the centring wrapper (flex 1 of 100vh).
    // Below 860 the board's flex-wrap shares the spare height s between the
    // nav line and the main line: the card sits 3s/4 down a box of the
    // remaining viewport, i.e. at y 0.5 of it, and the page still ends at 100vh.
    final vh = MediaQuery.sizeOf(context).height;
    final tinggi = sempit ? vh - _tinggiNav - 68 : vh - 68;
    return AlatPrototipe(
      stem: 'WebPemulihan',
      alat: alatPemulihan,
      child: HalamanWeb(
        nav: NavSamping(
          key: _nav,
          item: navPemulihan,
          aktif: 0,
          pengguna: const Text('Belum masuk'),
          diSini: _ulang,
        ),
        isi: [
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: tinggi),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Align(
                alignment: Alignment(0, sempit ? 0.5 : 0),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 460),
                  padding: EdgeInsets.all(context.jepit(24, 4, 40)),
                  decoration: ShapeDecoration(
                    color: c.permukaan,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: c.garis),
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: LangkahPemulihan(
                    key: ValueKey(_generasi),
                    akunSaya: const Tautan(
                      ke: 'WebAkunSaya',
                      child: SizedBox(),
                    ),
                    beranda: const Tombol(
                      'Buka Beranda',
                      onPressed: null,
                      ke: 'WebBeranda',
                      cara: Cara.ganti,
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
