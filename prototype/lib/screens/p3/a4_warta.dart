import 'package:flutter/material.dart';

import '../../shell/halaman_a4.dart';
import '../../theme/palakat_tema.dart';

/// The published Warta Jemaat of 22/11/2026 (Q27): one fixed A4 page, no
/// state, no links. Masthead and footer come from [HalamanA4.warta].
class A4WartaScreen extends StatelessWidget {
  const A4WartaScreen({super.key});

  @override
  Widget build(BuildContext context) => const HalamanA4.warta(
    isi: [
      _Bagian('Ibadah minggu ini', [
        _Baris('Ibadah Subuh', '05.00'),
        _Baris('Ibadah Pagi', '09.00'),
        _Baris('Ibadah Malam', '18.00'),
      ]),
      _Bagian('Pengumuman', [
        _Paragraf(
          'Kerja bakti halaman gereja.',
          ' Sabtu, 21 November 2026 pukul 07.00. Membawa alat kebersihan masing-masing.',
        ),
        _Paragraf(
          'Pendaftaran katekisasi sidi 2027.',
          ' Dibuka sampai 31 Desember 2026 di Sekretariat Jemaat.',
        ),
      ]),
      _Bagian('Peristiwa jemaat', [
        Text('Syukur HUT pernikahan: Keluarga Wenas-Lasut — Kolom 7'),
        Text('Sampul syukur: Tanpa nama, Kolom 4'),
      ]),
      _Bagian('Jumlah kehadiran · Minggu, 15 November 2026', [
        _Baris('Ibadah Subuh', '96'),
        _Baris('Ibadah Pagi', '231'),
        _Baris('Ibadah Malam', '85'),
        _Baris('Jumlah', '412', jumlah: true),
      ]),
      _Bagian('Ringkasan keuangan · Oktober 2026', [
        _Baris('Pendapatan', 'Rp14.820.000'),
        _Baris('Belanja', 'Rp11.455.000'),
        _Catatan(
          'Dari laporan resmi Oktober 2026. Laporan lengkap ada pada Bendahara Jemaat.',
        ),
      ]),
    ],
  );
}

/// Section: 13/700 upper-case heading, letter-spacing .5, a 1.5 `tinta` rule
/// under it (padding-bottom 3, margin-bottom 6), then lines with gap 3.
class _Bagian extends StatelessWidget {
  const _Bagian(this.judul, this.baris);

  final String judul;
  final List<Widget> baris;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Container(
        padding: const EdgeInsets.only(bottom: 3),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: context.warna.tinta, width: 1.5),
          ),
        ),
        child: Semantics(
          header: true,
          child: Text(
            judul.toUpperCase(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: .5,
            ),
          ),
        ),
      ),
      for (var i = 0; i < baris.length; i++) ...[
        if (i > 0) const SizedBox(height: 3),
        baris[i],
      ],
    ],
  );
}

/// Label left, mono value right (never shrinking). [jumlah]: the 700 total
/// row with a 1 `tinta` rule above, padding-top 3.
class _Baris extends StatelessWidget {
  const _Baris(this.label, this.nilai, {this.jumlah = false});

  final String label, nilai;
  final bool jumlah;

  @override
  Widget build(BuildContext context) {
    final baris = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: 16),
        Text(nilai, style: const TextStyle(fontFamily: PalakatText.mono)),
      ],
    );
    if (!jumlah) return baris;
    return Container(
      padding: const EdgeInsets.only(top: 3),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.warna.tinta)),
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontWeight: FontWeight.w700),
        child: baris,
      ),
    );
  }
}

class _Paragraf extends StatelessWidget {
  const _Paragraf(this.tebal, this.sisa);

  final String tebal, sisa;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: [
        TextSpan(
          text: tebal,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        TextSpan(text: sisa),
      ],
    ),
  );
}

class _Catatan extends StatelessWidget {
  const _Catatan(this.teks);

  final String teks;

  @override
  Widget build(BuildContext context) =>
      Text(teks, style: TextStyle(color: context.warna.tinta2));
}
