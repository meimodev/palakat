import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/palakat_tema.dart';

/// A4 page scaffold (components.md 4.7, navigation.md 1.7): a fixed white
/// page, always in the light palette (paper does not follow the dark theme),
/// centred on `kertas` with 24 margin, scaled down to fit narrower windows,
/// scrolling; at the frame size or narrower the margin is 0. Content beyond
/// the page is clipped (`overflow: hidden`). [isi] is built inside the page's
/// light Theme: read colours inside the [isi] widgets (a Builder), never from
/// the calling screen's context, which is dark under Gelap.
class HalamanA4 extends StatelessWidget {
  const HalamanA4({
    super.key,
    required this.ukuran,
    required this.kode,
    required this.judul,
    required this.subjudul,
    required this.kanan,
    required this.kakiKanan,
    required this.isi,
  }) : _warta = false,
       kakiKiri = _kakiKiri;

  /// A4Warta's own form: padding 56 60 0, gap 20, 14 / 1.45, centred header
  /// "WARTA JEMAAT", footer 60 / 36 at 13 px (the board's 12 raised).
  /// [subjudul] 'GMIM Jemaat Karunia · Minggu, {d} {bulan} {tahun}',
  /// [kakiKanan] 'Edisi dd/mm/yyyy · halaman 1 dari 1', [kakiKiri]
  /// 'Diterbitkan dd/mm/yyyy oleh Sekretaris Jemaat · nama mengikuti Tampilan
  /// nama pilihan anggota'.
  const HalamanA4.warta({
    super.key,
    required this.subjudul,
    required this.kakiKanan,
    required this.kakiKiri,
    required this.isi,
  }) : ukuran = const Size(794, 1123),
       kode = '',
       judul = 'WARTA JEMAAT',
       kanan = const [],
       _warta = true;

  /// `Size(794, 1123)` portrait, `Size(1123, 794)` landscape (A4F02a–c).
  final Size ukuran;

  /// 'F01 · LAPORAN RESMI'.
  final String kode;

  /// 'LAPORAN PERBENDAHARAAN BULANAN'.
  final String judul;

  /// 'Jemaat Karunia · Periode laporan 1–31 {bulan} {tahun} · …'.
  final String subjudul;

  /// Mono lines at the right of the header.
  final List<String> kanan;

  /// 'F01 · halaman 1 dari 1'.
  final String kakiKanan;
  final List<Widget> isi;
  final bool _warta;

  /// The footer's left text.
  final String kakiKiri;

  static const _kakiKiri =
      'Palakat · format bawaan aplikasi, bukan formulir resmi GMIM · Jemaat Karunia';

  @override
  Widget build(BuildContext context) {
    final latar = context.warna.kertas;
    return ColoredBox(
      color: latar,
      child: LayoutBuilder(
        builder: (context, k) {
          // No margin up to the frame size, where the board's page fills the
          // frame edge to edge.
          final m = k.maxWidth >= ukuran.width + 48 ? 24.0 : 0.0;
          final skala = math.min(
            1.0,
            math.max(0.0, k.maxWidth - 2 * m) / ukuran.width,
          );
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(m),
              child: Center(
                child: SizedBox(
                  width: ukuran.width * skala,
                  height: ukuran.height * skala,
                  child: FittedBox(
                    child: Theme(
                      data: palakatTema(Brightness.light),
                      child: Builder(builder: _halaman),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _halaman(BuildContext context) {
    final c = context.warna;
    final tepi = _warta ? 60.0 : 52.0;
    final kepala = _warta
        ? Container(
            padding: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: c.tinta, width: 2)),
            ),
            child: Column(
              children: [
                Text(
                  judul,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  subjudul,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          )
        : Container(
            padding: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: c.tinta, width: 2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kode,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          letterSpacing: .4,
                          color: c.tinta2,
                        ),
                      ),
                      Text(
                        judul,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .2,
                        ),
                      ),
                      Text(subjudul),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final b in kanan)
                      Text(
                        b,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: PalakatText.mono,
                          color: c.tinta2,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
    final jarak = _warta ? 20.0 : 14.0;
    final anak = [kepala, ...isi];
    return SizedBox.fromSize(
      size: ukuran,
      // The Material ancestor TextFields need, outside the page text style.
      child: Material(
        type: MaterialType.transparency,
        child: ColoredBox(
          color: c.permukaan,
          child: DefaultTextStyle(
            style: TextStyle(
              fontFamily: PalakatText.sans,
              fontSize: _warta ? 14 : 13,
              height: _warta ? 1.45 : 1.4,
              // CSS splits line-height leading evenly above and below the glyphs.
              leadingDistribution: TextLeadingDistribution.even,
              color: c.tinta,
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  // overflow: hidden, without overflow errors
                  child: SingleChildScrollView(
                    primary: false,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      tepi,
                      _warta ? 56 : 48,
                      tepi,
                      0,
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
                  ),
                ),
                Positioned(
                  left: tepi,
                  right: tepi,
                  bottom: _warta ? 36 : 34,
                  child: Container(
                    padding: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: c.tinta)),
                    ),
                    child: DefaultTextStyle.merge(
                      style: TextStyle(
                        color: c.tinta2,
                        fontSize: _warta ? 13 : null,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: Text(kakiKiri)),
                          const SizedBox(width: 24),
                          Text(
                            kakiKanan,
                            style: const TextStyle(
                              fontFamily: PalakatText.mono,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
