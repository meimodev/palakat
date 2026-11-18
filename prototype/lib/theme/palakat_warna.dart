import 'package:flutter/material.dart';

import 'palakat_tokens.dart';

@immutable
class PalakatWarna extends ThemeExtension<PalakatWarna> {
  const PalakatWarna({
    required this.kertas,
    required this.permukaan,
    required this.tinta,
    required this.tinta2,
    required this.tinta3,
    required this.putus,
    required this.garis,
    required this.garisTegas,
    required this.laut,
    required this.lautTua,
    required this.lautLembut,
    required this.bata,
    required this.bataLembut,
    required this.diTinta,
    required this.diTinta2,
    required this.diLaut,
    required this.diBata,
    required this.tirai,
  });

  final Color kertas, permukaan, tinta, tinta2, tinta3, putus, garis, garisTegas;
  final Color laut, lautTua, lautLembut, bata, bataLembut, diTinta, diTinta2;
  final Color diLaut, diBata;

  /// Scrim behind a bottom sheet. Boards: rgba(19,32,28,.45) = tinta at 45 %.
  final Color tirai;

  static const terang = PalakatWarna(
    kertas: PalakatColors.kertas,
    permukaan: PalakatColors.permukaan,
    tinta: PalakatColors.tinta,
    tinta2: PalakatColors.tinta2,
    tinta3: PalakatColors.tinta3,
    putus: PalakatColors.putus,
    garis: PalakatColors.garis,
    garisTegas: PalakatColors.garisTegas,
    laut: PalakatColors.laut,
    lautTua: PalakatColors.lautTua,
    lautLembut: PalakatColors.lautLembut,
    bata: PalakatColors.bata,
    bataLembut: PalakatColors.bataLembut,
    diTinta: PalakatColors.diTinta,
    diTinta2: PalakatColors.diTinta2,
    diLaut: PalakatColors.diLaut,
    diBata: PalakatColors.diBata,
    tirai: Color(0x7313201C),
  );

  static const gelap = PalakatWarna(
    kertas: PalakatColorsGelap.kertas,
    permukaan: PalakatColorsGelap.permukaan,
    tinta: PalakatColorsGelap.tinta,
    tinta2: PalakatColorsGelap.tinta2,
    tinta3: PalakatColorsGelap.tinta3,
    putus: PalakatColorsGelap.putus,
    garis: PalakatColorsGelap.garis,
    garisTegas: PalakatColorsGelap.garisTegas,
    laut: PalakatColorsGelap.laut,
    lautTua: PalakatColorsGelap.lautTua,
    lautLembut: PalakatColorsGelap.lautLembut,
    bata: PalakatColorsGelap.bata,
    bataLembut: PalakatColorsGelap.bataLembut,
    diTinta: PalakatColorsGelap.diTinta,
    diTinta2: PalakatColorsGelap.diTinta2,
    diLaut: PalakatColorsGelap.diLaut,
    diBata: PalakatColorsGelap.diBata,
    tirai: Color(0xB30E1513),
  );

  @override
  PalakatWarna copyWith({
    Color? kertas,
    Color? permukaan,
    Color? tinta,
    Color? tinta2,
    Color? tinta3,
    Color? putus,
    Color? garis,
    Color? garisTegas,
    Color? laut,
    Color? lautTua,
    Color? lautLembut,
    Color? bata,
    Color? bataLembut,
    Color? diTinta,
    Color? diTinta2,
    Color? diLaut,
    Color? diBata,
    Color? tirai,
  }) =>
      PalakatWarna(
        kertas: kertas ?? this.kertas,
        permukaan: permukaan ?? this.permukaan,
        tinta: tinta ?? this.tinta,
        tinta2: tinta2 ?? this.tinta2,
        tinta3: tinta3 ?? this.tinta3,
        putus: putus ?? this.putus,
        garis: garis ?? this.garis,
        garisTegas: garisTegas ?? this.garisTegas,
        laut: laut ?? this.laut,
        lautTua: lautTua ?? this.lautTua,
        lautLembut: lautLembut ?? this.lautLembut,
        bata: bata ?? this.bata,
        bataLembut: bataLembut ?? this.bataLembut,
        diTinta: diTinta ?? this.diTinta,
        diTinta2: diTinta2 ?? this.diTinta2,
        diLaut: diLaut ?? this.diLaut,
        diBata: diBata ?? this.diBata,
        tirai: tirai ?? this.tirai,
      );

  @override
  PalakatWarna lerp(PalakatWarna? o, double t) {
    if (o == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return PalakatWarna(
      kertas: l(kertas, o.kertas),
      permukaan: l(permukaan, o.permukaan),
      tinta: l(tinta, o.tinta),
      tinta2: l(tinta2, o.tinta2),
      tinta3: l(tinta3, o.tinta3),
      putus: l(putus, o.putus),
      garis: l(garis, o.garis),
      garisTegas: l(garisTegas, o.garisTegas),
      laut: l(laut, o.laut),
      lautTua: l(lautTua, o.lautTua),
      lautLembut: l(lautLembut, o.lautLembut),
      bata: l(bata, o.bata),
      bataLembut: l(bataLembut, o.bataLembut),
      diTinta: l(diTinta, o.diTinta),
      diTinta2: l(diTinta2, o.diTinta2),
      diLaut: l(diLaut, o.diLaut),
      diBata: l(diBata, o.diBata),
      tirai: l(tirai, o.tirai),
    );
  }
}

/// The only shadow: the floating receipt in Kamera, LihatDokumen, WebLihatDokumen.
const bayanganMelayang = [
  BoxShadow(offset: Offset(0, 12), blurRadius: 32, color: Color(0x66000000)),
];

/// Illustration colours (CONVENTIONS): kept here so widgets and screens stay hex-free.
abstract final class PalakatIlustrasi {
  /// 3rd segment of BatangPembagian (Awal, Bagi, WebBagi, AlihPeruntukan, WebAlihPeruntukan).
  static const peruntukanKetiga = Color(0xFF86B5B8);

  /// Paper of the photographed receipt (Kamera, LihatDokumen, WebLihatDokumen, WebUnggah).
  static const kertasNota = Color(0xFFFBFAF6);

  /// 1px top rule inside the lautLembut answer card of Cari and WebCari.
  static const garisJawaban = Color(0xFFC9DAD9);
}
