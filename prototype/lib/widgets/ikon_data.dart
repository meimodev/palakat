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
  final String viewBox;
  final String akar;
  final String isi;
  final double? tebal;
}

/// The 25 distinct inline SVGs of the boards (icon-inventory.json,
/// components.md 5.1/5.2). Path data is copied verbatim from the boards.
///
/// | Ikon | Default size / stroke | Colour | Boards |
/// | --- | --- | --- | --- |
/// | kembali | 22 / 2 | tinta (white on Kamera) | every phone back button (98 boards) |
/// | tanda | 26 (40 Masuk, WebMasuk) | laut | logo: Main, Awal, Masuk, TabBeranda, TabCatat, TabTransaksi, all Web boards |
/// | lanjut | 18 / 2 | tinta3 | row chevrons: Main, Awal, Lainnya, Laporan, TabBeranda, AlurBeranda, AntreanVerifikasi, BerandaJabatan, CariOrang, DokumenGereja, Keluar, KotakMasuk, Pengumuman, PermohonanSurat, WartaArsip + Web twins, WebBeranda |
/// | terpenuhi | 22 (18, 20, 26) | laut + diLaut | Main, TabCatat, TutupBuku, WebCatat, WebTutupBuku; label "Terpenuhi" |
/// | belumTerpenuhi | 22 (20) | bata + diBata | Main, TabCatat, TutupBuku, WebCatat; label "Belum terpenuhi" |
/// | untukDiketahui | 22 (20) | tinta3 | Main, TabCatat, WebCatat; label "Untuk diketahui" |
/// | beranda | 22 / 2 | currentColor | Main, Lainnya tab bar |
/// | transaksi | 22 / 2 | currentColor | Main, Lainnya tab bar |
/// | tambah | 24 / 2.4 | diLaut on laut | Main, Lainnya Catat button |
/// | bulan | 22 / 2 | currentColor | Main, Lainnya tab bar |
/// | lainnya | 22 | currentColor | Main, Lainnya tab bar |
/// | kamera | 20 / 2 | laut | Main "Lampirkan dokumen pendukung" |
/// | silang | 18 / 2 (16 / 2.4 AwalIsian, WebAwalIsian) | tinta3 | Bagi, WebBagi, AwalIsian, WebAwalIsian |
/// | centang | 20 / 2.5 laut; 14 / 3.4 permukaan | laut / permukaan | LihatTransaksi, WebLihatTransaksi, WebRekonsiliasi |
/// | kait | 16 / 2.6 (15 WebRekonsiliasi) | diLaut in a laut circle | TutupBuku, WebRekonsiliasi |
/// | tanpaSambungan | 22 / 2 | bata | Sambungan, WebSambungan |
/// | unggah | 36 / 1.8 | tinta2 | WebUnggah drop zone |
/// | sesiBerakhir | 56 | putus, tinta | Sambungan, WebSambungan |
/// | cincinProses | 56 (52 web) | garis, tinta | TutupBuku, WebTutupBuku; rotates 1 s (Ulang/putar) |
/// | lingkarBelum | 88 | putus | Awal (wBelum) |
/// | lingkarTunggu | 88 | tinta | Awal (wTunggu); rotates 6 s |
/// | lingkarMasuk | 72 | tinta | Masuk, WebMasuk; static |
/// | lingkarBendahara | 34 | tinta | Bendahara; rotates 6 s |
/// | selesai | 88 (56 HitungKas) | laut, diLaut | Awal (wAktif), HitungKas; end frame of the animation |
/// | segel | 104 | permukaan on tinta | TutupBuku, WebTutupBuku; end frame of the animation |
abstract final class Ikon {
  static const _garis =
      'fill="none" stroke="{warna}" stroke-width="{tebal}" stroke-linecap="round"';
  static const _garisSudut = '$_garis stroke-linejoin="round"';

  static const kembali = IkonData(
    viewBox: '0 0 24 24',
    akar: _garis,
    tebal: 2,
    isi: '<path d="M15 6l-6 6 6 6"/>',
  );
  static const lanjut = IkonData(
    viewBox: '0 0 24 24',
    akar: _garis,
    tebal: 2,
    isi: '<path d="M9 6l6 6-6 6"/>',
  );
  static const tanda = IkonData(
    viewBox: '0 0 24 24',
    isi:
        '<rect x="2" y="2" width="20" height="20" rx="6" fill="none" stroke="{laut}" stroke-width="2" stroke-dasharray="3 3"/>'
        '<path d="M12 2h4a6 6 0 0 1 6 6v8a6 6 0 0 1-6 6h-4z" fill="{laut}"/>',
  );
  static const terpenuhi = IkonData(
    viewBox: '0 0 24 24',
    isi:
        '<circle cx="12" cy="12" r="11" fill="{laut}"/>'
        '<path d="M7 12.5l3.2 3.2L17 9" fill="none" stroke="{diLaut}" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/>',
  );
  static const belumTerpenuhi = IkonData(
    viewBox: '0 0 24 24',
    isi:
        '<rect x="1" y="1" width="22" height="22" rx="6" fill="{bata}"/>'
        '<path d="M12 6.5v7M12 17v.5" fill="none" stroke="{diBata}" stroke-width="2.4" stroke-linecap="round"/>',
  );
  static const untukDiketahui = IkonData(
    viewBox: '0 0 24 24',
    isi: '<circle cx="12" cy="12" r="10" fill="none" stroke="{tinta3}" stroke-width="2" stroke-dasharray="3 3"/>',
  );
  static const beranda = IkonData(
    viewBox: '0 0 24 24',
    akar: _garisSudut,
    tebal: 2,
    isi: '<path d="M4 11l8-7 8 7v9H4z"/>',
  );
  static const transaksi = IkonData(
    viewBox: '0 0 24 24',
    akar: _garis,
    tebal: 2,
    isi: '<path d="M5 7h14M5 12h14M5 17h9"/>',
  );
  static const tambah = IkonData(
    viewBox: '0 0 24 24',
    akar: _garis,
    tebal: 2.4,
    isi: '<path d="M12 5v14M5 12h14"/>',
  );
  static const bulan = IkonData(
    viewBox: '0 0 24 24',
    akar: _garis,
    tebal: 2,
    isi: '<rect x="4" y="5" width="16" height="15" rx="3"/><path d="M4 10h16M9 3v4M15 3v4"/>',
  );

  /// The inbox tray of the phone bar's "Kotak masuk" tab (not drawn on the
  /// boards; in their stroke style).
  static const kotakMasuk = IkonData(
    viewBox: '0 0 24 24',
    akar: _garisSudut,
    tebal: 2,
    isi: '<path d="M4 13l2.5-8h11L20 13v6H4z"/><path d="M4 13h5a3 3 0 0 0 6 0h5"/>',
  );
  static const lainnya = IkonData(
    viewBox: '0 0 24 24',
    akar: 'fill="{warna}"',
    isi: '<circle cx="5" cy="12" r="2"/><circle cx="12" cy="12" r="2"/><circle cx="19" cy="12" r="2"/>',
  );
  static const kamera = IkonData(
    viewBox: '0 0 24 24',
    akar: _garisSudut,
    tebal: 2,
    isi:
        '<path d="M4 8h3l2-3h6l2 3h3v11H4z"/><circle cx="12" cy="13" r="3.5"/>',
  );
  static const silang = IkonData(
    viewBox: '0 0 24 24',
    akar: _garis,
    tebal: 2,
    isi: '<path d="M6 6l12 12M18 6L6 18"/>',
  );
  static const centang = IkonData(
    viewBox: '0 0 24 24',
    akar: _garisSudut,
    tebal: 2.5,
    isi: '<path d="M5 12.5l4.5 4.5L19 7.5"/>',
  );
  static const kait = IkonData(
    viewBox: '0 0 24 24',
    akar: _garis,
    tebal: 2.6,
    isi: '<path d="M9 15l6-6M10 6l1-1a5 5 0 0 1 7 7l-1 1M14 18l-1 1a5 5 0 0 1-7-7l1-1"/>',
  );
  static const tanpaSambungan = IkonData(
    viewBox: '0 0 24 24',
    akar: _garis,
    tebal: 2,
    isi:
        '<path d="M2 8.5a15 15 0 0 1 20 0M5.5 12a10 10 0 0 1 13 0M9 15.5a5 5 0 0 1 6 0M3 3l18 18"/>'
        '<circle cx="12" cy="19" r="1" fill="{warna}"/>',
  );
  static const unggah = IkonData(
    viewBox: '0 0 24 24',
    akar: _garisSudut,
    tebal: 1.8,
    isi: '<path d="M12 16V5M7.5 9.5L12 5l4.5 4.5M5 19h14"/>',
  );
  static const sesiBerakhir = IkonData(
    viewBox: '0 0 56 56',
    akar: 'fill="none"',
    isi:
        '<circle cx="28" cy="28" r="26" stroke="{putus}" stroke-width="2" stroke-dasharray="5 5"/>'
        '<rect x="18" y="26" width="20" height="15" rx="3" fill="{tinta}"/>'
        '<path d="M22 26v-4a6 6 0 0 1 12 0v4" stroke="{tinta}" stroke-width="2.5"/>',
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

  /// Every icon by name with its most common board size, for the gallery and tests.
  static const semua = <String, (IkonData, double)>{
    'kembali': (kembali, 22),
    'tanda': (tanda, 26),
    'lanjut': (lanjut, 18),
    'terpenuhi': (terpenuhi, 22),
    'belumTerpenuhi': (belumTerpenuhi, 22),
    'untukDiketahui': (untukDiketahui, 22),
    'beranda': (beranda, 22),
    'transaksi': (transaksi, 22),
    'tambah': (tambah, 24),
    'bulan': (bulan, 22),
    'lainnya': (lainnya, 22),
    'kotakMasuk': (kotakMasuk, 22),
    'kamera': (kamera, 20),
    'silang': (silang, 18),
    'centang': (centang, 20),
    'kait': (kait, 16),
    'tanpaSambungan': (tanpaSambungan, 22),
    'unggah': (unggah, 36),
    'sesiBerakhir': (sesiBerakhir, 56),
    'cincinProses': (cincinProses, 56),
    'lingkarBelum': (lingkarBelum, 88),
    'lingkarTunggu': (lingkarTunggu, 88),
    'lingkarMasuk': (lingkarMasuk, 72),
    'lingkarBendahara': (lingkarBendahara, 34),
    'selesai': (selesai, 88),
    'segel': (segel, 104),
  };
}
