import 'package:flutter/widgets.dart';

import '../theme/palakat_tema.dart';
import '../widgets/pita_jabatan_kosong.dart';
import 'nav_samping.dart';
import 'prototipe_state.dart';

/// Laptop page scaffold (components.md 4.4): `kertas`, body 15 / 1.45, at
/// least the window height, scrolls as one page. [nav] beside `main` when
/// the window is wider than 860, above it otherwise.
///
/// `main`: padding 28 `clamp(16px, 3vw, 40px)` 40, column gap [jarak]; its
/// first child is `PitaJabatanKosong.web` while [jabatanKosong] and the global
/// switch are on.
class HalamanWeb extends StatelessWidget {
  const HalamanWeb({
    super.key,
    required this.nav,
    required this.isi,
    this.jarak = 20,
    this.jabatanKosong = false,
  });

  /// null on pages without nav (sign-in, launcher).
  final NavSamping? nav;

  /// Children of `<main>`.
  final List<Widget> isi;

  /// Main column gap: 20 (most), 24 (WebBeranda, TabBeranda), 22 (WebAwal,
  /// WebAwalIsian), 18 (WebLaporan).
  final double jarak;

  /// The board carries the `jabatanKosong` tweak.
  final bool jabatanKosong;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final pita =
        jabatanKosong &&
        (PrototypeState.maybeOf(context)?.jabatanKosong ?? false);
    final anak = [if (pita) const PitaJabatanKosong.web(), ...isi];
    final utama = Padding(
      padding: EdgeInsets.fromLTRB(
        context.jepit(16, 3, 40),
        28,
        context.jepit(16, 3, 40),
        40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < anak.length; i++) ...[
            if (i > 0) SizedBox(height: jarak),
            anak[i],
          ],
        ],
      ),
    );
    final sempit = navSempit(context);

    return ColoredBox(
      color: c.kertas,
      child: DefaultTextStyle(
        style: PalakatText.isiWeb.copyWith(color: c.tinta, height: 1.45),
        child: LayoutBuilder(
          builder: (context, k) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: k.maxHeight.isFinite ? k.maxHeight : 0,
              ),
              child: nav == null
                  ? utama
                  : sempit
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [nav!, utama],
                    )
                  : Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: lebarNav(k.maxWidth)),
                          child: utama,
                        ),
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          width: lebarNav(k.maxWidth),
                          child: nav!,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
