import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../theme/palakat_tema.dart';
import '../widgets/pita_jabatan_kosong.dart';
import 'nav_samping.dart';
import 'prototipe_state.dart';

/// Laptop page scaffold (components.md 4.4): `kertas`, body 15 / 1.45, at
/// least the window height, scrolls as one page. [nav] beside `main` when
/// the window is wider than 860, above it otherwise (see [_HalamanSempit]).
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
  /// WebTutupBuku), 18 (WebLaporan).
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

    // The Material ancestor TextFields need, outside the page text style so it
    // does not reset it to the theme's bodyMedium.
    return Material(
      type: MaterialType.transparency,
      child: ColoredBox(
        color: c.kertas,
        child: DefaultTextStyle(
          style: PalakatText.isiWeb.copyWith(
            color: c.tinta,
            height: 1.45,
            // CSS splits line-height leading evenly above and below the glyphs.
            leadingDistribution: TextLeadingDistribution.even,
          ),
          child: LayoutBuilder(
            builder: (context, k) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: k.maxHeight.isFinite ? k.maxHeight : 0,
                ),
                child: nav == null
                    ? utama
                    : sempit
                    ? _HalamanSempit(children: [nav!, utama])
                    : Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              left: lebarNav(k.maxWidth),
                            ),
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
      ),
    );
  }
}

/// The narrow page (860 px and below): the boards' root is `min-height:100vh;
/// display:flex; flex-wrap:wrap` with nav and `main` on separate lines, so
/// align-content stretch shares the spare height equally between them. The
/// nav (first child) gets its half (NavSamping centres its row in it); `main`
/// keeps its content at the top and the page ends at the minimum height.
class _HalamanSempit extends MultiChildRenderObjectWidget {
  const _HalamanSempit({required super.children});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderHalamanSempit();
}

class _RenderHalamanSempit extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {
  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! MultiChildLayoutParentData) {
      child.parentData = MultiChildLayoutParentData();
    }
  }

  @override
  void performLayout() {
    final nav = firstChild!;
    final utama = childAfter(nav)!;
    final lebar = constraints.maxWidth;
    nav.layout(BoxConstraints.tightFor(width: lebar), parentUsesSize: true);
    utama.layout(BoxConstraints.tightFor(width: lebar), parentUsesSize: true);
    final sisa = constraints.minHeight - nav.size.height - utama.size.height;
    if (sisa > 0) {
      // A minimum, not a tight height: tight constraints would make the nav a
      // relayout boundary, and an opened Menu would then overflow that height.
      nav.layout(
        BoxConstraints(
          minWidth: lebar,
          maxWidth: lebar,
          minHeight: nav.size.height + sisa / 2,
        ),
        parentUsesSize: true,
      );
    }
    (utama.parentData! as MultiChildLayoutParentData).offset = Offset(
      0,
      nav.size.height,
    );
    size = constraints.constrain(
      Size(lebar, nav.size.height + utama.size.height),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
