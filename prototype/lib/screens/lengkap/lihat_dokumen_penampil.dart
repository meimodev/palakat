import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../mock/jabatan_kosong.dart';
import '../../motion/kerangka.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../app/belum_dipindah.dart';

/// The two files of the supporting document of BKU-2026-0147 (the boards' `H`).
typedef _Nota = ({
  String toko,
  String alamat,
  List<(String, String)> baris,
  String total,
  String tgl,
  String kaki,
});

const List<_Nota> _halaman = [
  (
    toko: 'TOKO SINAR',
    alamat: 'Jl. Pierre Tendean 7',
    baris: [('Fotokopi warta', ''), ('300 lbr x 500', '150.000')],
    total: 'Rp150.000',
    tgl: '16/11/2026',
    kaki: 'Terima kasih',
  ),
  (
    toko: 'TANDA TERIMA',
    alamat: 'Jemaat Karunia',
    baris: [('Diterima dari', ''), ('Bendahara', '150.000')],
    total: 'Rp150.000',
    tgl: '16/11/2026',
    kaki: 'Penerima: Toko Sinar',
  ),
];

/// State and handlers shared by LihatDokumen and WebLihatDokumen:
/// `{ hal: 0, zoom: 1, st: 'unggah' }`.
mixin KeadaanLihatDokumen<T extends StatefulWidget> on State<T> {
  int hal = 0;
  double zoom = 1;
  bool terverifikasi = false;

  String get fileNama => hal == 0 ? 'nota-16-11.jpg' : 'tanda-terima-16-11.jpg';

  void prev() => setState(() {
    hal = 0;
    zoom = 1;
  });
  void next() => setState(() {
    hal = 1;
    zoom = 1;
  });
  void besar() => setState(() => zoom = zoom + 0.25 > 2 ? 2 : zoom + 0.25);
  void kecil() =>
      setState(() => zoom = zoom - 0.25 < 0.75 ? 0.75 : zoom - 0.25);
  void verif() => setState(() => terverifikasi = true);

  /// Viewer area (paper) and the paging/zoom controls, for a dark `tinta` field.
  List<Widget> penampil() => [
    Expanded(
      child: _Kertas(nota: _halaman[hal], zoom: zoom),
    ),
    _Kendali(
      hal: hal,
      zoom: zoom,
      prev: hal == 0 ? null : prev,
      next: hal == 1 ? null : next,
      kecil: zoom <= 0.75 ? null : kecil,
      besar: zoom >= 2 ? null : besar,
    ),
  ];

  /// Panel rows a–f; [tautan] is the screen's own "Tolak, …" link.
  List<Widget> panel(BuildContext context, {required Widget tautan}) {
    final c = context.warna;
    final jk = belumDipindah(false);
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Flexible(
            child: Text(
              'BKU-2026-0147',
              style: TextStyle(
                fontFamily: PalakatText.mono,
                fontSize: 13,
                color: c.tinta2,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Flexible(
            child: Text(
              '−Rp150.000',
              style: TextStyle(
                fontFamily: PalakatText.mono,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      const Text(
        'Fotokopi warta jemaat',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dokumen pendukung · 2 file',
            style: TextStyle(fontSize: 14, color: c.tinta2),
          ),
          Text(
            terverifikasi
                ? 'Terverifikasi (oleh ${plk(jk)})'
                : 'Diunggah, belum diverifikasi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: terverifikasi ? c.tinta : c.bata,
            ),
          ),
          Text(
            'Diunggah oleh ${plk(jk)}, 16/11/2026 10.41',
            style: TextStyle(fontSize: 13, color: c.tinta3),
          ),
        ],
      ),
      if (!terverifikasi)
        Tombol('Verifikasi', onPressed: verif, paddingH: 20)
      else
        Gerak(
          Kerangka.muncul,
          lama: const Duration(milliseconds: 300),
          child: Semantics(
            liveRegion: true,
            child: Text(
              'Memenuhi syarat tutup buku November 2026.',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ),
        ),
      tautan,
    ];
  }
}

/// "Tolak, lepaskan, atau catat pengecualian": min height 44, centred, 700.
class IsiTautanTolak extends StatelessWidget {
  const IsiTautanTolak({super.key});

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 44),
    alignment: Alignment.center,
    child: const TautanTeks(
      'Tolak, lepaskan, atau catat pengecualian',
      berat: FontWeight.w700,
      rata: TextAlign.center,
    ),
  );
}

/// The photographed receipt, centred in a scrolling area (padding 24), scaled
/// by [zoom] around its centre (`transform .25s` keluar). Scaling does not
/// change layout, so at 200 % half the paper is clipped, as on the board.
class _Kertas extends StatelessWidget {
  const _Kertas({required this.nota, required this.zoom});
  final _Nota nota;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    // The receipt paper stays light in the Gelap theme, so its ink does too.
    final c = PalakatWarna.terang;
    final putus = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GarisLurus(warna: c.tinta3, gaya: GayaGaris.putus),
    );
    final kertas = Container(
      width: 230 + 32, // CSS content-box: width 230 plus padding 16 16
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: const BoxDecoration(
        color: PalakatIlustrasi.kertasNota,
        boxShadow: bayanganMelayang,
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          fontFamily: PalakatText.mono,
          fontSize: 13,
          height: 1.55,
          leadingDistribution: TextLeadingDistribution.even,
          color: c.tinta,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              nota.toko,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(nota.alamat, textAlign: TextAlign.center),
            putus,
            for (final b in nota.baris) _baris(b.$1, b.$2),
            putus,
            DefaultTextStyle.merge(
              style: const TextStyle(fontWeight: FontWeight.w600),
              child: _baris('TOTAL', nota.total),
            ),
            const SizedBox(height: 8),
            Text(nota.tgl),
            Text(nota.kaki),
          ],
        ),
      ),
    );
    // `overflow: auto` with a centred, scaled paper: the scaled paper's
    // right and bottom overflow can be scrolled to, its left and top cannot.
    return LayoutBuilder(
      builder: (context, k) => TweenAnimationBuilder<double>(
        tween: Tween(end: zoom),
        duration: context.gerak(const Duration(milliseconds: 250)),
        curve: PalakatMotion.keluar,
        builder: (context, s, kertas) => SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _Skala(
              lebar: k.maxWidth,
              tinggi: k.maxHeight,
              skala: s,
              child: Transform.scale(scale: s, child: kertas),
            ),
          ),
        ),
        child: kertas,
      ),
    );
  }

  Widget _baris(String n, String rp) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Flexible(child: Text(n)),
      const SizedBox(width: 8),
      Text(rp),
    ],
  );
}

/// Centres [child] (laid out unscaled) in a [lebar] × [tinggi] viewport and
/// grows to the right and bottom edges of the child scaled by [skala].
class _Skala extends SingleChildRenderObjectWidget {
  const _Skala({
    required this.lebar,
    required this.tinggi,
    required this.skala,
    super.child,
  });
  final double lebar, tinggi, skala;

  @override
  _RenderSkala createRenderObject(BuildContext context) =>
      _RenderSkala(lebar, tinggi, skala);

  @override
  void updateRenderObject(BuildContext context, _RenderSkala r) => r
    ..lebar = lebar
    ..tinggi = tinggi
    ..skala = skala
    ..markNeedsLayout();
}

class _RenderSkala extends RenderShiftedBox {
  _RenderSkala(this.lebar, this.tinggi, this.skala) : super(null);
  double lebar, tinggi, skala;

  @override
  void performLayout() {
    final anak = child!..layout(const BoxConstraints(), parentUsesSize: true);
    final u = anak.size;
    (anak.parentData! as BoxParentData).offset = Offset(
      (lebar - u.width) / 2,
      (tinggi - u.height) / 2,
    );
    size = Size(
      math.max(lebar, (lebar + u.width * skala) / 2),
      math.max(tinggi, (tinggi + u.height * skala) / 2),
    );
  }
}

/// ‹ "1 dari 2" › · − "100%" +: row, centred, gap 8, padding 10 16 14.
class _Kendali extends StatelessWidget {
  const _Kendali({
    required this.hal,
    required this.zoom,
    required this.prev,
    required this.next,
    required this.kecil,
    required this.besar,
  });
  final int hal;
  final double zoom;
  final VoidCallback? prev, next, kecil, besar;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    // The board draws no disabled look (inline white overrides it).
    Widget tombol(String glyph, String label, VoidCallback? onTap) => Tekan(
      onTap: onTap,
      label: label,
      radius: 12,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: c.tinta3, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          glyph,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: c.permukaan,
          ),
        ),
      ),
    );
    Widget label(String teks, double min, {bool mono = false}) => Container(
      constraints: BoxConstraints(minWidth: min),
      alignment: Alignment.center,
      child: Text(
        teks,
        style: TextStyle(
          fontSize: 14,
          fontFamily: mono ? PalakatText.mono : null,
        ),
      ),
    );
    Widget groep(List<Widget> c) =>
        Row(mainAxisSize: MainAxisSize.min, spacing: 8, children: c);
    // The 16 px spacer is a CSS flex item that shrinks (to 12 at 390 wide);
    // the rest never shrinks. Narrower than that, the board's row overflows
    // its 16 px padding, centred: the padding gives way while the row still
    // fits the viewer. Narrower still, the zoom pair wraps under the pager:
    // the buttons keep their 44 px targets.
    return LayoutBuilder(
      builder: (context, luar) => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: luar.maxWidth < 346
              ? 16
              : ((luar.maxWidth - 346) / 2).clamp(0, 16),
        ).copyWith(top: 10, bottom: 14),
        child: LayoutBuilder(
          builder: (context, k) => DefaultTextStyle.merge(
            style: const TextStyle(
              leadingDistribution: TextLeadingDistribution.even,
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              // gap 8 + spacer + gap 8; 346 = everything else.
              spacing: 16 + (k.maxWidth - 346).clamp(0, 16),
              runSpacing: 8,
              children: [
                groep([
                  tombol('‹', 'Halaman sebelumnya', prev),
                  label('${hal + 1} dari 2', 70),
                  tombol('›', 'Halaman berikutnya', next),
                ]),
                groep([
                  tombol('−', 'Perkecil', kecil),
                  label('${(zoom * 100).round()}%', 52, mono: true),
                  tombol('+', 'Perbesar', besar),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
