import 'package:flutter/material.dart';

import '../../shell/halaman_a4.dart';
import '../../theme/palakat_tema.dart';

/// A4 · Salinan TERBATAS, peruntukan Diakonia: the printed restricted copy
/// with F05 and F07 for Diakonia only. Static page, no controls.
class A4TerbatasScreen extends StatelessWidget {
  const A4TerbatasScreen({super.key});

  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: HalamanA4(
      ukuran: const Size(794, 1123),
      kode: 'F05 dan F07 · LAPORAN RESMI · TERBATAS',
      judul: 'REALISASI MENURUT MATA ANGGARAN',
      subjudul: 'Jemaat Karunia · Periode laporan 1–31 Oktober 2026',
      kanan: const [
        'ID SNP-2026-10-01',
        'Dibekukan 16/11/2026 11.05',
        'Versi Mata Anggaran 2026.1',
      ],
      kakiKanan: 'F05 dan F07 · TERBATAS · halaman 1 dari 1',
      isi: const [
        _KotakTerbatas(),
        _Bagian(
          judul: 'F05 · Pendapatan peruntukan Diakonia',
          child: _Tabel(
            kolom: _kolomMa,
            baris: [
              _Baris.kepala(['No. MA', 'Nama Mata Anggaran', 'Oktober 2026']),
              _Baris(['1.3.55.01.00', 'Persembahan Diakonia', 'Rp950.000']),
              _Baris.tebal([
                '',
                'Jumlah Pendapatan peruntukan Diakonia',
                'Rp950.000',
              ]),
            ],
          ),
        ),
        _Bagian(
          judul: 'F07 · Belanja peruntukan Diakonia',
          atasJudul: 6,
          child: _Tabel(
            kolom: _kolomMa,
            baris: [
              _Baris.kepala(['No. MA', 'Nama Mata Anggaran', 'Oktober 2026']),
              _Baris(['4.03.03.00', 'Diakonia duka', 'Rp0']),
              _Baris(['4.03.04.00', 'Diakonia sakit', 'Rp300.000']),
              _Baris.tebal([
                '',
                'Jumlah Belanja peruntukan Diakonia',
                'Rp300.000',
              ]),
            ],
          ),
        ),
        _Bagian(
          child: _Tabel(
            kolom: [null, 170],
            baris: [
              _Baris.kepala(['Saldo peruntukan Diakonia', 'Oktober 2026']),
              _Baris(['Saldo awal', 'Rp3.050.000']),
              _Baris.tebal(['Saldo akhir', 'Rp3.700.000']),
            ],
          ),
        ),
        _TidakAda(),
      ],
    ),
  );
}

const _kolomMa = <double?>[150, null, 170];

class _KotakTerbatas extends StatelessWidget {
  const _KotakTerbatas();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
    decoration: BoxDecoration(
      border: Border.all(color: context.warna.tinta, width: 2),
    ),
    child: const Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'TERBATAS · Akses terbatas: Peruntukan Diakonia.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text: ' File ini dibuat khusus untuk bagian peruntukan Diakonia. Ini bukan versi tersembunyi dari file seluruh Jemaat.',
          ),
        ],
      ),
      style: TextStyle(fontSize: 15),
    ),
  );
}

/// A 15 px block with an optional bold title (margin [atasJudul] 0 2).
class _Bagian extends StatelessWidget {
  const _Bagian({this.judul, this.atasJudul = 0, required this.child});

  final String? judul;
  final double atasJudul;
  final Widget child;

  @override
  Widget build(BuildContext context) => DefaultTextStyle.merge(
    style: const TextStyle(fontSize: 15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (judul != null)
          Padding(
            padding: EdgeInsets.only(top: atasJudul, bottom: 2),
            child: Text(
              judul!,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        child,
      ],
    ),
  );
}

enum _JenisBaris { kepala, biasa, tebal }

class _Baris {
  const _Baris(this.sel) : jenis = _JenisBaris.biasa;
  const _Baris.kepala(this.sel) : jenis = _JenisBaris.kepala;
  const _Baris.tebal(this.sel) : jenis = _JenisBaris.tebal;

  final List<String> sel;
  final _JenisBaris jenis;
}

/// The A4 report table: grid rows, column gap 10. Width null = 1fr. The last
/// column is the amount (right-aligned, mono in body rows); a first column of
/// fixed width holds the No. MA (mono in body rows).
class _Tabel extends StatelessWidget {
  const _Tabel({required this.kolom, required this.baris});

  final List<double?> kolom;
  final List<_Baris> baris;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final b in baris)
          Container(
            padding: EdgeInsets.symmetric(
              vertical: b.jenis == _JenisBaris.kepala ? 6 : 4,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: b.jenis == _JenisBaris.biasa
                    ? BorderSide(color: c.garisTegas)
                    : BorderSide(color: c.tinta, width: 1.5),
              ),
            ),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                fontWeight: b.jenis == _JenisBaris.biasa
                    ? null
                    : FontWeight.w700,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < kolom.length; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    _sel(b, i),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _sel(_Baris b, int i) {
    final akhir = i == kolom.length - 1;
    final mono = b.jenis != _JenisBaris.kepala && (akhir || kolom[i] != null);
    final teks = Text(
      b.sel[i],
      textAlign: akhir ? TextAlign.right : TextAlign.left,
      style: mono ? const TextStyle(fontFamily: PalakatText.mono) : null,
    );
    final w = kolom[i];
    return w == null ? Expanded(child: teks) : SizedBox(width: w, child: teks);
  }
}

class _TidakAda extends StatelessWidget {
  const _TidakAda();

  static const _baris = [
    'Baris peruntukan lain tidak dicetak, juga tidak sebagai Rp0.',
    'Jumlah seluruh transaksi, uraian, pelaku, file dokumen pendukung dan celah nomor tidak disertakan.',
    'Baris bernilai Rp0 di atas adalah baris yang boleh dipakai peruntukan Diakonia dan memang tidak ada transaksinya.',
  ];

  @override
  Widget build(BuildContext context) => DefaultTextStyle.merge(
    style: const TextStyle(fontSize: 15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Yang tidak ada di salinan ini',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        for (final t in _baris) ...[const SizedBox(height: 6), Text(t)],
      ],
    ),
  );
}
