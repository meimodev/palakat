import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/finance/finance.dart';
import '../../providers/keuangan/laporan.dart';
import '../../shell/halaman_a4.dart';
import '../../theme/palakat_tema.dart';
import '../a4/a4_laporan.dart';
import '../lanjut/laporan_tabel.dart';

/// A4 · Salinan TERBATAS of the route's month for the viewer's Fund: F05
/// and F07 with only that Fund's rows, and its opening and closing balance
/// (RestrictedReport, D27).
class A4TerbatasScreen extends ConsumerWidget {
  const A4TerbatasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = laporanRute(context, ref);
    final t = ref.watch(terbatasProvider);
    final r = l == null
        ? null
        : ref.watch(laporanTerbatasProvider(l.periode.id));
    if (l == null || t == null || r == null) {
      return const Center(child: Text('Tidak berwenang'));
    }
    final dana = t.dana.name;
    final bulan = namaBulanLaporan(l);
    final lembar = {for (final (k, _, x) in lembarTerbatas(l, r)) k: x};
    final f02 = r.datasets[ReportForm.f02]!.totals;
    List<_Baris> ma(String kode, String jenis) => [
      _Baris.kepala(['No. MA', 'Nama Mata Anggaran', bulan]),
      for (final x in lembar[kode]!.rows)
        x.last is int
            ? _Baris.tebal([
                '',
                'Jumlah $jenis peruntukan $dana',
                x[2] as String,
              ])
            : _Baris([x[0] as String, x[1] as String, x[2] as String]),
    ];
    return Material(
      type: MaterialType.transparency,
      child: HalamanA4(
        ukuran: const Size(794, 1123),
        kode: '${kodeA4(l, 'F05 dan F07')} · TERBATAS',
        judul: 'REALISASI MENURUT MATA ANGGARAN',
        subjudul: subjudulA4(l),
        kanan: kananA4(l),
        kakiKanan: 'F05 dan F07 · TERBATAS · halaman 1 dari 1',
        isi: [
          _KotakTerbatas(dana),
          _Bagian(
            judul: 'F05 · Pendapatan peruntukan $dana',
            child: _Tabel(kolom: _kolomMa, baris: ma('F05', 'Pendapatan')),
          ),
          _Bagian(
            judul: 'F07 · Belanja peruntukan $dana',
            atasJudul: 6,
            child: _Tabel(kolom: _kolomMa, baris: ma('F07', 'Belanja')),
          ),
          _Bagian(
            child: _Tabel(
              kolom: const [null, 170],
              baris: [
                _Baris.kepala(['Saldo peruntukan $dana', bulan]),
                _Baris(['Saldo awal', rp(f02['opening'] as int)]),
                _Baris.tebal(['Saldo akhir', rp(f02['closing'] as int)]),
              ],
            ),
          ),
          _TidakAda(dana),
        ],
      ),
    );
  }
}

const _kolomMa = <double?>[150, null, 170];

class _KotakTerbatas extends StatelessWidget {
  const _KotakTerbatas(this.dana);
  final String dana;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
    decoration: BoxDecoration(
      border: Border.all(color: context.warna.tinta, width: 2),
    ),
    child: Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'TERBATAS · Akses terbatas: Peruntukan $dana.',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text:
                ' File ini dibuat khusus untuk bagian peruntukan $dana. Ini '
                'bukan versi tersembunyi dari file seluruh Jemaat.',
          ),
        ],
      ),
      style: const TextStyle(fontSize: 15),
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
  const _TidakAda(this.dana);
  final String dana;

  List<String> get _baris => [
    'Baris peruntukan lain tidak dicetak, juga tidak sebagai Rp0.',
    'Jumlah seluruh transaksi, uraian, pelaku, file dokumen pendukung dan '
        'celah nomor tidak disertakan.',
    'Mata Anggaran tanpa transaksi peruntukan $dana di bulan ini tidak '
        'dicetak.',
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
