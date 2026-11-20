import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../mock/mock.dart';
import '../../shell/halaman_a4.dart';
import '../../theme/palakat_tema.dart';

/// F02 Buku Kas Umum page frame shared by A4F02b and A4F02c: the landscape
/// A4 page, its header, the cash-book table and the page footer.
class HalamanBku extends StatelessWidget {
  const HalamanBku({
    super.key,
    required this.halaman,
    required this.pindahan,
    required this.baris,
    required this.saldo,
    required this.akhir,
    this.penutup,
  });

  /// 'halaman 2 dari 3'.
  final String halaman;

  /// First emphasised row: uraian, penerimaan, pengeluaran, saldo.
  final (String, int, int, int) pindahan;
  final List<Transaksi> baris;

  /// "Saldo semua Kas/Bank" after each row of [baris].
  final List<int> saldo;

  /// Last emphasised row.
  final (String, int, int, int) akhir;

  /// Below the table (A4F02c's closing block).
  final Widget? penutup;

  @override
  Widget build(BuildContext context) => HalamanA4(
    ukuran: const Size(1123, 794),
    kode: 'F02 · LAPORAN RESMI',
    judul: 'BUKU KAS UMUM',
    subjudul:
        'Jemaat Karunia · Periode laporan 1–31 Oktober 2026 · semua Kas/Bank',
    kanan: const [
      'ID SNP-2026-10-01',
      'Dibekukan 16/11/2026 11.05',
      'Versi Mata Anggaran 2026.1',
    ],
    kakiKanan: 'F02 · $halaman',
    isi: [
      Builder(
        builder: (context) {
          final c = context.warna;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Baris(
                garis: BorderSide(color: c.tinta, width: 1.5),
                atas: 6,
                tebal: true,
                sel: const [
                  'Tanggal',
                  'No. Bukti',
                  'No. MA',
                  'Uraian',
                  'Kas/Bank',
                  'Penerimaan',
                  'Pengeluaran',
                  // U+2060: Chrome does not break after the slash here
                  'Saldo semua Kas/\u2060Bank',
                ],
              ),
              _tegas(c, pindahan),
              for (var i = 0; i < baris.length; i++)
                _Baris(
                  garis: BorderSide(color: c.garisTegas),
                  tanda: baris[i].tandaRantai,
                  sel: [
                    baris[i].tanggal ?? '',
                    baris[i].noBukti ?? '',
                    _duaBaris(baris[i].kodeMA ?? '—'),
                    baris[i].uraian,
                    _duaBaris(baris[i].kasBank),
                    baris[i].masuk == 0 ? '' : rp(baris[i].masuk),
                    baris[i].keluar == 0 ? '' : rp(baris[i].keluar),
                    rp(saldo[i]),
                  ],
                ),
              _tegas(c, akhir),
            ],
          );
        },
      ),
      ?penutup,
    ],
  );

  static String _duaBaris(String s) => s.replaceAll('; ', '\n');

  static Widget _tegas(PalakatWarna c, (String, int, int, int) r) => _Baris(
    garis: BorderSide(color: c.tinta, width: 1.5),
    tebal: true,
    sel: ['', '', '', r.$1, '', rp(r.$2), rp(r.$3), rp(r.$4)],
  );
}

/// One grid row: columns 74 112 96 1fr 122 102 102 116, gap 10.
class _Baris extends StatelessWidget {
  const _Baris({
    required this.sel,
    required this.garis,
    this.atas = 4,
    this.tebal = false,
    this.tanda,
  });

  final List<String> sel;
  final BorderSide garis;
  final double atas;
  final bool tebal;

  /// Inline print tag after the uraian ('Pembalikan', 'Koreksi dari …').
  final String? tanda;

  static const _lebar = <double?>[74, 112, 96, null, 122, 102, 102, 116];

  @override
  Widget build(BuildContext context) {
    final kepala = atas == 6; // the column header row has no mono cells
    const mono = TextStyle(fontFamily: PalakatText.mono);
    Widget isi(int i) {
      final kanan = i >= 5;
      final gaya = !kepala && (i == 1 || i == 2 || kanan) ? mono : null;
      if (i == 3 && tanda != null) {
        return Text.rich(
          TextSpan(
            text: '${sel[i]} ',
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: _TandaCetak(tanda!),
              ),
            ],
          ),
        );
      }
      return Text(
        sel[i],
        style: gaya,
        textAlign: kanan ? TextAlign.right : TextAlign.left,
        // a CSS date never breaks mid-word; it may overflow its 74 column
        softWrap: i != 0,
        overflow: TextOverflow.visible,
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: atas),
      decoration: BoxDecoration(border: Border(bottom: garis)),
      child: DefaultTextStyle.merge(
        style: tebal ? const TextStyle(fontWeight: FontWeight.w700) : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < _lebar.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              if (_lebar[i] == null)
                Expanded(child: isi(i))
              else
                SizedBox(width: _lebar[i], child: isi(i)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Inline print tag: 1 px tinta border, radius 4, padding 0 5, 600.
class _TandaCetak extends StatelessWidget {
  const _TandaCetak(this.teks);
  final String teks;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5),
    decoration: BoxDecoration(
      border: Border.all(color: context.warna.tinta),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      teks,
      softWrap: false,
      style: const TextStyle(fontWeight: FontWeight.w600),
    ),
  );
}
