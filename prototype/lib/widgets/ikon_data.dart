import 'package:flutter/foundation.dart';

/// One inline SVG from the boards (components.md 2.5). Colours are
/// placeholders: `{warna}` = the tint, `{tebal}` = stroke width, `{token}` =
/// that PalakatWarna token (laut, diLaut, bata, diBata, tinta, tinta2, tinta3,
/// putus, garis, permukaan).
@immutable
class IkonData {
  const IkonData({
    required this.viewBox,
    required this.isi,
    this.akar = '',
    this.tebal,
  });

  /// A line icon on the 24 grid: one thin stroke, round caps and corners.
  const IkonData.garis(this.isi)
    : viewBox = '0 0 24 24',
      akar = akarGaris,
      tebal = tipis;

  static const double tipis = 1.5;
  static const akarGaris =
      'fill="none" stroke="{warna}" stroke-width="{tebal}" '
      'stroke-linecap="round" stroke-linejoin="round"';

  final String viewBox;
  final String akar;
  final String isi;
  final double? tebal;
}

/// The app's icons. The line icons were redrawn for the demo app (owner
/// request): simple, one thin stroke ([IkonData.tipis] on the 24 grid), round caps and
/// round corners, each matching what it stands for. [PalakatIkon] keeps the
/// stroke thin at every size. The logo ([tanda]), the progress rings and the
/// end frames of the two animated marks ([selesai], [segel]) are the boards'
/// own drawings (icon-inventory.json).
abstract final class Ikon {
  static const _tipis = IkonData.tipis;
  static const _garis = IkonData.akarGaris;
  static const _kotak = '0 0 24 24';

  // ---------- Navigation and actions ----------

  static const kembali = IkonData.garis('<path d="M14.5 6.5L9 12l5.5 5.5"/>');
  static const lanjut = IkonData.garis('<path d="M9.5 6.5L15 12l-5.5 5.5"/>');
  static const tambah = IkonData.garis('<path d="M12 5.5v13M5.5 12h13"/>');
  static const silang = IkonData.garis(
    '<path d="M6.5 6.5l11 11M17.5 6.5l-11 11"/>',
  );
  static const centang = IkonData.garis(
    '<path d="M5.5 12.5l4.2 4.2 8.8-9.2"/>',
  );
  static const cari = IkonData.garis(
    '<circle cx="11" cy="11" r="6.2"/><path d="M15.8 15.8L20 20"/>',
  );
  static const unggah = IkonData.garis(
    '<path d="M12 15.5V5M8 9l4-4 4 4M5 19h14"/>',
  );
  static const impor = IkonData.garis(
    '<path d="M12 4.5V14M8 10.5l4 4 4-4M5 19h14"/>',
  );
  static const kamera = IkonData.garis(
    '<path d="M5 8h2.2l1.4-2.2h6.8L16.8 8H19a2 2 0 0 1 2 2v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-7a2 2 0 0 1 2-2z"/>'
    '<circle cx="12" cy="13.2" r="3.3"/>',
  );
  static const kait = IkonData.garis(
    '<path d="M9.5 14.5l5-5M10.5 6.8l1-1a4.4 4.4 0 0 1 6.2 6.2l-1 1M13.5 17.2l-1 1a4.4 4.4 0 0 1-6.2-6.2l1-1"/>',
  );
  static const tanpaSambungan = IkonData.garis(
    '<path d="M3 9a14 14 0 0 1 18 0M6.2 12.4a9 9 0 0 1 11.6 0M9.3 15.6a4.5 4.5 0 0 1 5.4 0M4 4l16 16"/>'
    '<circle cx="12" cy="19" r=".9" fill="{warna}"/>',
  );

  // ---------- Phone bar: places ----------

  static const beranda = IkonData.garis(
    '<path d="M4.5 10.5L12 4l7.5 6.5V18a2 2 0 0 1-2 2h-11a2 2 0 0 1-2-2z"/>'
    '<path d="M10 20v-5h4v5"/>',
  );

  /// Money in and money out.
  static const transaksi = IkonData.garis(
    '<path d="M6 8h12M15 5l3 3-3 3M18 16H6M9 13l-3 3 3 3"/>',
  );
  static const bulan = IkonData.garis(
    '<rect x="4" y="5.5" width="16" height="14.5" rx="3"/>'
    '<path d="M4 10h16M8.5 3.5v4M15.5 3.5v4"/>',
  );
  static const kotakMasuk = IkonData.garis(
    '<path d="M4 13.5l2.6-7a2 2 0 0 1 1.9-1.3h7a2 2 0 0 1 1.9 1.3l2.6 7V17a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2z"/>'
    '<path d="M4 13.5h4.5a3.5 3.5 0 0 0 7 0H20"/>',
  );

  /// Everything else: a grid of screens.
  static const lainnya = IkonData.garis(
    '<rect x="4.5" y="4.5" width="6" height="6" rx="1.8"/>'
    '<rect x="13.5" y="4.5" width="6" height="6" rx="1.8"/>'
    '<rect x="4.5" y="13.5" width="6" height="6" rx="1.8"/>'
    '<rect x="13.5" y="13.5" width="6" height="6" rx="1.8"/>',
  );
  static const dokumen = IkonData.garis(
    '<path d="M7 3.5h6.5l5 5v10a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2v-13a2 2 0 0 1 2-2z"/>'
    '<path d="M13.5 3.5v5h5M8.5 13h7M8.5 16.5h4.5"/>',
  );

  /// A person given a post.
  static const penugasan = IkonData.garis(
    '<circle cx="10" cy="8" r="3.5"/>'
    '<path d="M4 19.5V19a6 6 0 0 1 9.4-4.9M14.5 17.2l2 2 4-4.4"/>',
  );

  /// A checked list: the second check, and a readiness statement.
  static const periksa = IkonData.garis(
    '<rect x="5" y="5" width="14" height="15.5" rx="2.5"/>'
    '<path d="M9.5 5V4.5a1 1 0 0 1 1-1h3a1 1 0 0 1 1 1V5M8.8 13l2.3 2.3 4.2-4.6"/>',
  );
  static const verifikasi = IkonData.garis(
    '<path d="M12 3.5l7 2.6v5.4c0 4.2-2.9 7.6-7 9-4.1-1.4-7-4.8-7-9V6.1z"/>'
    '<path d="M8.8 12l2.3 2.3 4.2-4.6"/>',
  );
  static const dataJemaat = IkonData.garis(
    '<circle cx="9" cy="8.5" r="3.2"/>'
    '<path d="M3.5 19v-.5a5.5 5.5 0 0 1 11 0v.5M15.5 5.6a3.2 3.2 0 0 1 0 5.8M17 14.2a5.5 5.5 0 0 1 3.5 4.8"/>',
  );
  static const keuanganUnit = IkonData.garis(
    '<path d="M17.5 8.5v-3H6a2 2 0 0 0 0 4h12a2 2 0 0 1 2 2v6a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V7.5"/>'
    '<circle cx="16.2" cy="14.5" r=".9" fill="{warna}"/>',
  );

  /// View only.
  static const terbatas = IkonData.garis(
    '<path d="M2.8 12s3.4-6 9.2-6 9.2 6 9.2 6-3.4 6-9.2 6-9.2-6-9.2-6z"/>'
    '<circle cx="12" cy="12" r="2.6"/>',
  );
  static const panitia = IkonData.garis(
    '<path d="M6 20.5v-16M6 5h10.5l-2 3.75 2 3.75H6"/>',
  );
  static const persembahan = IkonData.garis(
    '<path d="M12 19.5s-7-4.3-7-9.4a4 4 0 0 1 7-2.6 4 4 0 0 1 7 2.6c0 5.1-7 9.4-7 9.4z"/>',
  );

  // ---------- Phone bar: raised actions ----------

  static const terbitkan = IkonData.garis(
    '<path d="M20 4l-9.5 9.5M20 4l-6 16-3.5-6.5L4 10z"/>',
  );
  static const ibadah = IkonData.garis(
    '<path d="M12 3v4M10.2 4.8h3.6M7 20.5v-9L12 8l5 3.5v9M4.5 20.5h15M10.5 20.5V17a1.5 1.5 0 0 1 3 0v3.5"/>',
  );
  static const dana = IkonData.garis(
    '<rect x="3" y="6.5" width="18" height="11" rx="2.5"/>'
    '<circle cx="12" cy="12" r="2.5"/><path d="M6.5 10.5v3M17.5 10.5v3"/>',
  );
  static const surat = IkonData.garis(
    '<rect x="3.5" y="5.5" width="17" height="13" rx="2.5"/>'
    '<path d="M4.2 7.6l7.8 5.9 7.8-5.9"/>',
  );

  // ---------- Status marks ----------

  static const terpenuhi = IkonData(
    viewBox: _kotak,
    akar: _garis,
    tebal: _tipis,
    isi:
        '<circle cx="12" cy="12" r="9.5" stroke="{laut}"/>'
        '<path d="M8 12.4l2.8 2.8 5.4-5.8" stroke="{laut}"/>',
  );
  static const belumTerpenuhi = IkonData(
    viewBox: _kotak,
    akar: _garis,
    tebal: _tipis,
    isi:
        '<rect x="2.5" y="2.5" width="19" height="19" rx="6" stroke="{bata}"/>'
        '<path d="M12 7.5v6M12 16.6v.1" stroke="{bata}"/>',
  );
  static const untukDiketahui = IkonData(
    viewBox: _kotak,
    akar: _garis,
    tebal: _tipis,
    isi:
        '<circle cx="12" cy="12" r="9.5" stroke="{tinta3}" stroke-dasharray="2.5 3"/>'
        '<path d="M12 11v5M12 8v.1" stroke="{tinta3}"/>',
  );

  /// The session ended: a closed padlock in a dashed ring.
  static const sesiBerakhir = IkonData(
    viewBox: '0 0 56 56',
    akar: 'fill="none" stroke-linecap="round" stroke-linejoin="round"',
    isi:
        '<circle cx="28" cy="28" r="26" stroke="{putus}" stroke-width="1.5" stroke-dasharray="4 5"/>'
        '<rect x="19" y="26" width="18" height="14" rx="3.5" stroke="{tinta}" stroke-width="1.8"/>'
        '<path d="M22.5 26v-3.5a5.5 5.5 0 0 1 11 0V26" stroke="{tinta}" stroke-width="1.8"/>'
        '<circle cx="28" cy="33" r="1.2" fill="{tinta}"/>',
  );

  // ---------- The boards' own marks ----------

  static const tanda = IkonData(
    viewBox: _kotak,
    isi:
        '<rect x="2" y="2" width="20" height="20" rx="6" fill="none" stroke="{laut}" stroke-width="2" stroke-dasharray="3 3"/>'
        '<path d="M12 2h4a6 6 0 0 1 6 6v8a6 6 0 0 1-6 6h-4z" fill="{laut}"/>',
  );

  static const cincinProses = IkonData(
    viewBox: '0 0 56 56',
    isi:
        '<circle cx="28" cy="28" r="24" fill="none" stroke="{garis}" stroke-width="4"/>'
        '<path d="M28 4a24 24 0 0 1 24 24" fill="none" stroke="{tinta}" stroke-width="4" stroke-linecap="round"/>',
  );
  static const lingkarBelum = IkonData(
    viewBox: '0 0 88 88',
    isi: '<circle cx="44" cy="44" r="38" fill="none" stroke="{putus}" stroke-width="3" stroke-dasharray="5 6"/>',
  );
  static const lingkarTunggu = IkonData(
    viewBox: '0 0 88 88',
    isi: '<circle cx="44" cy="44" r="38" fill="none" stroke="{tinta}" stroke-width="3" stroke-dasharray="5 6"/>',
  );
  static const lingkarMasuk = IkonData(
    viewBox: '0 0 88 88',
    isi: '<circle cx="44" cy="44" r="38" fill="none" stroke="{tinta}" stroke-width="4" stroke-dasharray="6 7"/>',
  );
  static const lingkarBendahara = IkonData(
    viewBox: '0 0 88 88',
    isi: '<circle cx="44" cy="44" r="38" fill="none" stroke="{tinta}" stroke-width="6" stroke-dasharray="9 10"/>',
  );
  // Static end frames of the two animated icons (the motion draws the frames before it, 5.3).
  static const selesai = IkonData(
    viewBox: '0 0 88 88',
    isi:
        '<circle cx="44" cy="44" r="38" fill="{laut}" stroke="{laut}" stroke-width="3"/>'
        '<path d="M29 45l10 10 20-21" fill="none" stroke="{diLaut}" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"/>',
  );
  static const segel = IkonData(
    viewBox: '0 0 104 104',
    isi:
        '<circle cx="52" cy="52" r="46" fill="none" stroke="{permukaan}" stroke-width="3"/>'
        '<rect x="35" y="48" width="34" height="26" rx="5" fill="{permukaan}"/>'
        '<path d="M41 48v-8a11 11 0 0 1 22 0v8" fill="none" stroke="{permukaan}" stroke-width="4" stroke-linecap="round"/>',
  );
}
