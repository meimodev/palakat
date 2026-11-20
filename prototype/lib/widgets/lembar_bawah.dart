import 'dart:async';

import 'package:flutter/widgets.dart';

import '../motion/kerangka.dart';
import '../theme/palakat_tema.dart';
import 'tekan.dart';

/// The phone bottom sheet with its scrim, as drawn on Bagi, Draf, Keluar,
/// Kewajiban, Koreksi, Lainnya, Main, MataAnggaran, Pemeriksa, PilihBulan.
/// Not a route: put it last in the screen's Stack (`LayarPonsel.overlay`)
/// while it is open, or use [tampilkanLembarBawah].
///
/// In a `<Stem>Kendali` overlay (above a nested ShellRoute navigator) the
/// sheet's own PopScope sits on the shell's page, which system Back does not
/// reach first: the child page adds `PopScope(canPop: !open)` that closes it
/// (Lainnya, MataAnggaran).
///
/// Layout follows the two board forms: [jarak] 14 (Lainnya, Kewajiban …):
/// column gap 14, handle margin 4, title margin 0; [jarak] 0 (Main, Bagi):
/// handle margin 14, title margin 0 0 6 (PilihBulan with [anakJudul]:
/// title margin 0 0 4, subtitle margin 0 0 12).
class LembarBawah extends StatelessWidget {
  const LembarBawah({
    super.key,
    required this.judul,
    required this.isi,
    required this.onTutup,
    this.anakJudul,
    this.pegangan = true,
    this.latar,
    this.padding,
    this.ukuranJudul = 18,
    this.labelTirai = 'Kembali',
    this.jarak = 14,
    this.masuk = Kerangka.naik,
    this.kurva,
  });

  /// h2 text, also the route name for screen readers.
  final String judul;

  /// Under the title, in the same block: 14 `tinta2`.
  final String? anakJudul;
  final List<Widget> isi;

  /// The scrim, Escape and system Back call it. Closing is instant.
  final VoidCallback onTutup;

  /// The 40 × 4 handle (no handle on Draf, Keluar, PilihBulan).
  final bool pegangan;

  /// `permukaan` (default) or `kertas` (PilihBulan).
  final Color? latar;

  /// Default 10 20 24, or 18 20 24 without a handle. Main: 10 20 28;
  /// PilihBulan 18 20 20.
  final EdgeInsetsGeometry? padding;

  /// 18; 19 Pemeriksa; 20 MataAnggaran.
  final double ukuranJudul;

  /// The scrim button's label (Main: 'Kembali ke Beranda').
  final String labelTirai;

  /// Column gap: 14 on most, 12 Keluar, 0 Main, Bagi, PilihBulan.
  final double jarak;

  /// Entry keyframe: `naik` (default), `Kerangka.muncul` (Draf, Keluar,
  /// PilihBulan), null for none (LihatDokumen).
  final Bingkai? masuk;

  /// Default `PalakatMotion.keluar` for `naik`, `Curves.ease` otherwise.
  final Curve? kurva;

  /// Closes the sheet around [context] (a [tampilkanLembarBawah] sheet
  /// completes its Future with [hasil]).
  static void tutup<T>(BuildContext context, [T? hasil]) =>
      context.getInheritedWidgetOfExactType<_Penutup>()?.tutup(hasil);

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final rapat = jarak == 0;
    final kepala = <Widget>[
      Semantics(
        header: true,
        child: Text(
          judul,
          style: TextStyle(fontSize: ukuranJudul, fontWeight: FontWeight.w700),
        ),
      ),
      if (anakJudul != null) ...[
        if (rapat) const SizedBox(height: 4),
        Text(anakJudul!, style: TextStyle(fontSize: 14, color: c.tinta2)),
      ],
    ];
    final anak = <Widget>[
      if (pegangan)
        Padding(
          padding: EdgeInsets.only(bottom: rapat ? 14 : 4),
          child: Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.garisTegas,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      Padding(
        padding: EdgeInsets.only(
          bottom: rapat ? (anakJudul == null ? 6 : 12) : 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: kepala,
        ),
      ),
      ...isi,
    ];

    Widget lembar = Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.fromLTRB(20, pegangan ? 10 : 18, 20, 24),
      decoration: BoxDecoration(
        color: latar ?? c.permukaan,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(PalakatRadius.lembar),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < anak.length; i++) ...[
            // Board: the handle's margin (4 or 14) adds to the column gap.
            if (i > 0) SizedBox(height: jarak),
            anak[i],
          ],
        ],
      ),
    );
    if (masuk != null) {
      lembar = Gerak(
        masuk!,
        lama: PalakatMotion.pindahLayar,
        kurva:
            kurva ??
            (masuk == Kerangka.naik ? PalakatMotion.keluar : Curves.ease),
        child: lembar,
      );
    }

    final luar = context.getInheritedWidgetOfExactType<_Penutup>();
    return _Penutup(
      tutup: luar?.tutup ?? (_) => onTutup(),
      child: LayoutBuilder(
        builder: (context, ruang) => Actions(
          actions: {
            DismissIntent: CallbackAction<DismissIntent>(
              onInvoke: (_) {
                onTutup();
                return null;
              },
            ),
          },
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (sudah, _) {
              if (!sudah) onTutup();
            },
            child: FocusScope(
              autofocus: true,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Gerak(
                      Kerangka.pudar,
                      lama: const Duration(milliseconds: 200),
                      child: Tekan(
                        onTap: onTutup,
                        label: labelTirai,
                        child: ColoredBox(color: c.tirai),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Semantics(
                      scopesRoute: true,
                      namesRoute: true,
                      explicitChildNodes: true,
                      label: judul,
                      child: ConstrainedBox(
                        // Prototype safeguard: no board's sheet is this tall.
                        constraints: BoxConstraints(
                          maxHeight: ruang.maxHeight * .85,
                        ),
                        child: SingleChildScrollView(child: lembar),
                      ),
                    ),
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

class _Penutup extends InheritedWidget {
  const _Penutup({required this.tutup, required super.child});
  final void Function(Object? hasil) tutup;
  @override
  bool updateShouldNotify(_Penutup old) => false;
}

/// Shows a [LembarBawah] in the nearest [Overlay] (inside the phone frame
/// when the frame has its own Navigator). The Future completes with the
/// value passed to [LembarBawah.tutup], or null when the scrim, Escape or
/// Back closes it.
Future<T?> tampilkanLembarBawah<T>(
  BuildContext context, {
  required String judul,
  required WidgetBuilder isi,
  String? anakJudul,
  bool pegangan = true,
  Color? latar,
  EdgeInsetsGeometry? padding,
  double ukuranJudul = 18,
  String labelTirai = 'Kembali',
  double jarak = 14,
  Bingkai? masuk = Kerangka.naik,
}) {
  final selesai = Completer<T?>();
  late final OverlayEntry entri;
  late final LocalHistoryEntry riwayat;
  void tutup(Object? hasil) {
    if (selesai.isCompleted) return;
    selesai.complete(hasil as T?);
    entri.remove();
    entri.dispose();
    riwayat.remove();
  }

  // An overlay entry sits outside the route, so PopScope cannot see system
  // Back; a local history entry makes Back close the sheet, not the screen.
  // ponytail: a link that leaves the screen while the sheet is open leaves
  // the entry behind; screens that navigate from a sheet use the Stack form.
  riwayat = LocalHistoryEntry(onRemove: () => tutup(null));
  ModalRoute.of(context)?.addLocalHistoryEntry(riwayat);

  entri = OverlayEntry(
    builder: (ctx) => _Penutup(
      tutup: tutup,
      child: LembarBawah(
        judul: judul,
        anakJudul: anakJudul,
        isi: [Builder(builder: isi)],
        onTutup: () => tutup(null),
        pegangan: pegangan,
        latar: latar,
        padding: padding,
        ukuranJudul: ukuranJudul,
        labelTirai: labelTirai,
        jarak: jarak,
        masuk: masuk,
      ),
    ),
  );
  Overlay.of(context).insert(entri);
  return selesai.future;
}
