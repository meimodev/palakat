// Palakat · Calm ledger · token desain v1.0.0
// Dibuat dari kanvas desain. Sumber kebenaran: palakat-tokens.json.
// Fon: tambahkan Plus Jakarta Sans dan IBM Plex Mono ke pubspec.yaml.
import 'package:flutter/material.dart';

abstract final class PalakatColors {
  /// Latar aplikasi
  static const Color kertas = Color(0xFFF3F5F1);
  /// Kartu, isian, lembar
  static const Color permukaan = Color(0xFFFFFFFF);
  /// Teks utama, dibukukan, ditutup
  static const Color tinta = Color(0xFF13201C);
  /// Teks pendamping
  static const Color tinta2 = Color(0xFF43514C);
  /// Keterangan, ikon
  static const Color tinta3 = Color(0xFF5E6A66);
  /// Garis putus-putus draf
  static const Color putus = Color(0xFF808D87);
  /// Pemisah, tepi kartu
  static const Color garis = Color(0xFFDDE2DB);
  /// Tepi isian dan chip
  static const Color garisTegas = Color(0xFF7F8C86);
  /// Teks dan ikon di atas bidang laut
  static const Color diLaut = Color(0xFFFFFFFF);
  /// Teks di atas bidang bata
  static const Color diBata = Color(0xFFFFFFFF);
  /// Tindakan utama, terpenuhi, cocok
  static const Color laut = Color(0xFF0E5A63);
  /// Tautan saat disentuh
  static const Color lautTua = Color(0xFF0A4249);
  /// Terpilih, siap, Usulan AI
  static const Color lautLembut = Color(0xFFE1EEED);
  /// Hambatan, gagal
  static const Color bata = Color(0xFFA63C1C);
  /// Latar pesan gagal
  static const Color bataLembut = Color(0xFFF8E8E0);
  /// Teks di atas Tinta
  static const Color diTinta = Color(0xFFEAF0EC);
  /// Teks pendamping di atas Tinta
  static const Color diTinta2 = Color(0xFFD5DDD8);
}

/// Tema gelap. Maknanya sama dengan PalakatColors; hanya terang dan gelapnya yang bertukar.
abstract final class PalakatColorsGelap {
  /// Latar aplikasi
  static const Color kertas = Color(0xFF0E1513);
  /// Kartu, isian, lembar
  static const Color permukaan = Color(0xFF17201D);
  /// Teks utama di atas kertas dan permukaan; garis penuh transaksi dibukukan; bidang penuh untuk bulan yang sudah ditutup dan laporan resmi
  static const Color tinta = Color(0xFFEAF0EC);
  /// Teks pendamping di atas kertas, permukaan, lautLembut dan bataLembut
  static const Color tinta2 = Color(0xFFB4C0BA);
  /// Keterangan dan ikon di atas kertas dan permukaan
  static const Color tinta3 = Color(0xFF93A19B);
  /// Garis putus-putus draf: belum masuk saldo
  static const Color putus = Color(0xFF5F6F69);
  /// Pemisah dan tepi kartu; latar tombol nonaktif dan lencana Dibatalkan
  static const Color garis = Color(0xFF2A3632);
  /// Tepi isian dan chip yang belum dipilih
  static const Color garisTegas = Color(0xFF5C726A);
  /// Tindakan utama, syarat terpenuhi, cocok
  static const Color laut = Color(0xFF6CC3CB);
  /// Tautan saat disentuh; teks Usulan AI di atas permukaan dan lautLembut
  static const Color lautTua = Color(0xFF9BDCE2);
  /// Latar terpilih, siap, Usulan AI
  static const Color lautLembut = Color(0xFF1B3B3A);
  /// Hambatan dan kegagalan saja
  static const Color bata = Color(0xFFF09A7A);
  /// Latar pesan gagal
  static const Color bataLembut = Color(0xFF3B2018);
  /// Kalimat di atas bidang tinta
  static const Color diTinta = Color(0xFF13201C);
  /// Teks pendamping di atas bidang tinta
  static const Color diTinta2 = Color(0xFF43514C);
  /// Teks dan ikon di atas bidang laut (tombol utama, lencana Sudah dipastikan)
  static const Color diLaut = Color(0xFF0E1513);
  /// Teks di atas bidang bata (tombol Coba lagi, penghitung hambatan)
  static const Color diBata = Color(0xFF0E1513);
}

abstract final class PalakatRadius {
  static const double lencana = 6;
  static const double isian = 12;
  static const double kartu = 14;
  static const double kartuBesar = 16;
  static const double lembar = 22;
  static const double chip = 999;
}

abstract final class PalakatSpace {
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s40 = 40;
  /// Sasaran sentuh paling kecil.
  static const double sentuhMin = 44;
  static const double tombolUtama = 52;
}

abstract final class PalakatMotion {
  /// Umpan balik sentuh
  static const Duration sentuh = Duration(milliseconds: 160);
  /// Pindah layar, lembar bawah naik
  static const Duration pindahLayar = Duration(milliseconds: 280);
  /// Cocokkan: dua sisi terkait
  static const Duration kait = Duration(milliseconds: 450);
  /// Bukukan: tinta menyapu, No. Bukti dicap
  static const Duration tinta = Duration(milliseconds: 700);
  /// Tutup buku: tombol ditahan sampai penuh
  static const Duration segelTahan = Duration(milliseconds: 1600);
  /// Tutup buku: layar menggelap, gembok terpasang
  static const Duration segel = Duration(milliseconds: 900);
  static const Curve keluar = Cubic(0.2, 0.8, 0.2, 1);
  /// Hormati MediaQuery.disableAnimations: pakai Duration.zero bila true.
  static Duration atau(BuildContext context, Duration d) =>
      MediaQuery.of(context).disableAnimations ? Duration.zero : d;
}

abstract final class PalakatText {
  static const String sans = 'PlusJakartaSans';
  static const String mono = 'IBMPlexMono';
  /// Judul halaman web
  static const TextStyle judulHalaman = TextStyle(fontFamily: sans, fontSize: 26, fontWeight: FontWeight.w700, color: PalakatColors.tinta);
  /// Judul layar utama ponsel
  static const TextStyle judulBesar = TextStyle(fontFamily: sans, fontSize: 22, fontWeight: FontWeight.w700, color: PalakatColors.tinta);
  /// Judul layar dan lembar
  static const TextStyle judulLayar = TextStyle(fontFamily: sans, fontSize: 18, fontWeight: FontWeight.w700, color: PalakatColors.tinta);
  /// Judul bagian
  static const TextStyle judulBagian = TextStyle(fontFamily: sans, fontSize: 16, fontWeight: FontWeight.w700, color: PalakatColors.tinta);
  /// Isi di ponsel
  static const TextStyle isi = TextStyle(fontFamily: sans, fontSize: 16, fontWeight: FontWeight.w400, color: PalakatColors.tinta);
  /// Isi di web
  static const TextStyle isiWeb = TextStyle(fontFamily: sans, fontSize: 15, fontWeight: FontWeight.w400, color: PalakatColors.tinta);
  /// Teks pendamping, chip
  static const TextStyle pendamping = TextStyle(fontFamily: sans, fontSize: 14, fontWeight: FontWeight.w400, color: PalakatColors.tinta);
  /// Keterangan, lencana (terkecil)
  static const TextStyle keterangan = TextStyle(fontFamily: sans, fontSize: 13, fontWeight: FontWeight.w400, color: PalakatColors.tinta);
  /// Saldo buku di Beranda
  static const TextStyle jumlahUtama = TextStyle(fontFamily: mono, fontSize: 38, fontWeight: FontWeight.w500, color: PalakatColors.tinta, fontFeatures: [FontFeature.tabularFigures()]);
  /// Isian jumlah
  static const TextStyle jumlahIsian = TextStyle(fontFamily: mono, fontSize: 30, fontWeight: FontWeight.w500, color: PalakatColors.tinta, fontFeatures: [FontFeature.tabularFigures()]);
  /// Jumlah di baris
  static const TextStyle jumlah = TextStyle(fontFamily: mono, fontSize: 16, fontWeight: FontWeight.w500, color: PalakatColors.tinta, fontFeatures: [FontFeature.tabularFigures()]);
  /// No. Bukti, No. MA
  static const TextStyle kode = TextStyle(fontFamily: mono, fontSize: 13, fontWeight: FontWeight.w400, color: PalakatColors.tinta, fontFeatures: [FontFeature.tabularFigures()]);
}

/// Garis putus-putus (Draf, belum masuk saldo) dan titik-titik (Usulan AI)
/// tidak ada di BoxDecoration. Gambar dengan CustomPainter atau paket dotted_border.

ThemeData palakatTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: PalakatColors.laut,
    onPrimary: PalakatColors.permukaan,
    primaryContainer: PalakatColors.lautLembut,
    onPrimaryContainer: PalakatColors.lautTua,
    secondary: PalakatColors.tinta,
    onSecondary: PalakatColors.permukaan,
    error: PalakatColors.bata,
    onError: PalakatColors.permukaan,
    errorContainer: PalakatColors.bataLembut,
    onErrorContainer: PalakatColors.bata,
    surface: PalakatColors.kertas,
    onSurface: PalakatColors.tinta,
    onSurfaceVariant: PalakatColors.tinta2,
    outline: PalakatColors.putus,
    outlineVariant: PalakatColors.garis,
    inverseSurface: PalakatColors.tinta,
    onInverseSurface: PalakatColors.diTinta,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: PalakatColors.kertas,
    fontFamily: PalakatText.sans,
    textTheme: const TextTheme(
      headlineMedium: PalakatText.judulHalaman,
      headlineSmall: PalakatText.judulBesar,
      titleLarge: PalakatText.judulLayar,
      titleMedium: PalakatText.judulBagian,
      bodyLarge: PalakatText.isi,
      bodyMedium: PalakatText.pendamping,
      bodySmall: PalakatText.keterangan,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(PalakatSpace.sentuhMin, PalakatSpace.tombolUtama),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PalakatRadius.kartu)),
      ),
    ),
    // Flutter sebelum 3.27: ganti CardThemeData dengan CardTheme.
    cardTheme: CardThemeData(
      color: PalakatColors.permukaan,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PalakatRadius.kartu),
        side: const BorderSide(color: PalakatColors.garis),
      ),
    ),
  );
}
