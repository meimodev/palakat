import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../mock/mock.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';

/// The `keadaan` options of DokumenGereja and WebDokumenGereja, in order.
const opsiDokumenGereja = [
  'Daftar dokumen',
  'Dokumen dengan revisi',
  'Belum ada dokumen',
  'Dilihat anggota jemaat',
];

/// The view state both boards share: `{ k: null }`, view = `k ?? keadaan`.
/// A handler-set `k` lasts until the tweak changes (spec 17 intro).
mixin KeadaanDokumenGereja<T extends StatefulWidget> on State<T> {
  String? _k, _kDari;

  /// Index of the view shown; an unknown value falls back to 0.
  int indeks(String keadaan) {
    final k = _kDari == keadaan ? _k : null;
    return math.max(0, opsiDokumenGereja.indexOf(k ?? keadaan));
  }

  /// `go<i>`: `setState({ k: O[i] })`.
  void pilih(int i, String keadaan) => setState(() {
    _k = opsiDokumenGereja[i];
    _kDari = keadaan;
  });
}

/// Region 2 of both boards: the items of the gap-16 column for view [ki].
/// [ke] is the publish board, [keBaris] the board's own stem (rows are
/// self links); [onBuka] is "Buka salinan bertanda tangan" (`go1`).
List<Widget> isiDokumenGereja({
  required bool web,
  required int ki,
  required String ke,
  required String keBaris,
  required VoidCallback onBuka,
}) {
  final daftar = ki == 0 || ki == 3;
  final dok = ki == 3
      ? [for (final i in dokumenGerejaUntukAnggota) semuaDokumenGereja[i]]
      : semuaDokumenGereja;
  return [
    if (daftar) ...[
      const Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _Chip('Semua jenis', dipilih: true),
          _Chip('Tahun 2026'),
          _Chip('Ditujukan untuk: semua'),
        ],
      ),
      if (web)
        _TabelWeb(dok: dok, keBaris: keBaris)
      else
        for (final d in dok) _BarisPonsel(d: d, keBaris: keBaris),
    ],
    if (ki == 0) _baris(_TombolLink('Terbitkan dokumen', ke: ke, tinta: true)),
    if (ki == 1) ...[
      Kartu(
        child: Builder(
          builder: (context) {
            final c = context.warna;
            return _Kolom([
              const _Atas(
                'Surat edaran jadwal ibadah Natal 2026',
                'Revisi 2',
                BentukLencana.tinta,
              ),
              Text(
                'Keputusan dan surat edaran · 12/11/2026 · Ditujukan untuk: Semua anggota',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
              Text(
                'Revisi yang berlaku. $dokumenRevisi2Oleh.',
                style: TextStyle(fontSize: 13, color: c.tinta3),
              ),
              _baris(
                // A `<button>` (border-box): 48 high including its line.
                Tombol(
                  'Buka salinan bertanda tangan',
                  onPressed: onBuka,
                  jenis: JenisTombol.kedua,
                  ukuran: UkuranTombol.sedang,
                ),
                tepi: 0,
              ),
            ]);
          },
        ),
      ),
      Kartu(
        status: GarisStatus.draf,
        child: Builder(
          builder: (context) {
            final c = context.warna;
            return _Kolom([
              const _Atas(
                'Revisi 1',
                'Digantikan oleh revisi 2',
                BentukLencana.abu,
              ),
              Text(
                'Diterbitkan 12/11/2026 16.40',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
              Text(
                'Tetap dapat dibuka. Dokumen yang sudah diterbitkan tidak pernah diubah diam-diam; ralat selalu menjadi revisi baru.',
                style: TextStyle(fontSize: 13, color: c.tinta3),
              ),
            ]);
          },
        ),
      ),
      _baris(_TombolLink('Terbitkan revisi baru', ke: ke, tinta: false)),
    ],
    if (ki == 2) ...[
      Kartu(
        status: GarisStatus.draf,
        child: Builder(
          builder: (context) => _Kolom([
            const Text(
              'Belum ada dokumen',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              'Mulai dengan menerbitkan satu dokumen: surat keputusan, notulen rapat, tata ibadah, atau surat untuk anggota.',
              style: TextStyle(fontSize: 14, color: context.warna.tinta2),
            ),
          ]),
        ),
      ),
      _baris(_TombolLink('Terbitkan dokumen', ke: ke, tinta: true)),
    ],
    if (ki == 3)
      Builder(
        builder: (context) => Text(
          'Anggota hanya melihat dokumen yang ditujukan untuknya. Dokumen pendukung keuangan tidak disimpan di sini; itu ada pada transaksinya.',
          style: TextStyle(fontSize: 13, color: context.warna.tinta3),
        ),
      ),
  ];
}

/// Button row: wrap, gap 8; one button `flex: 1 1 150px; max-width: 340px`.
/// The `<a>` buttons are content-box, so padding 0 16 (and a 1.5 line) sit
/// outside the 340.
Widget _baris(Widget tombol, {double tepi = 32}) => BarisLentur(
  jarak: 8,
  anak: [Lentur(dasar: 150 + tepi, maks: 340 + tepi, child: tombol)],
);

/// A link drawn as a button (`<a>`, content-box: min-height excludes the
/// 1.5 line, so the outline one is 51 high).
class _TombolLink extends StatelessWidget {
  const _TombolLink(this.label, {required this.ke, required this.tinta});

  final String label;
  final String ke;
  final bool tinta;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tautan(
      ke: ke,
      radius: 14,
      child: RupaTombol(
        label: label,
        isi: tinta ? c.tinta : c.permukaan,
        garis: tinta ? null : GarisBorder.penuh(c.tinta, radius: 14),
        warnaTeks: tinta ? c.permukaan : c.tinta,
        radius: 14,
        tinggi: tinta ? 52 : 51,
        paddingH: 16,
      ),
    );
  }
}

/// A static filter label (`<span>`, content-box: 44 plus its 1.5 line).
class _Chip extends StatelessWidget {
  const _Chip(this.teks, {this.dipilih = false});

  final String teks;
  final bool dipilih;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 47),
    child: ChipSatu(teks: teks, dipilih: dipilih, onTap: null),
  );
}

/// Column, gap 6.
class _Kolom extends StatelessWidget {
  const _Kolom(this.anak);

  final List<Widget> anak;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (var i = 0; i < anak.length; i++) ...[
        if (i > 0) const SizedBox(height: 6),
        anak[i],
      ],
    ],
  );
}

/// Revision card top row: title 700, badge at the end, gap 16.
class _Atas extends StatelessWidget {
  const _Atas(this.judul, this.label, this.bentuk);

  final String judul, label;
  final BentukLencana bentuk;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, k) => Row(
      children: [
        Expanded(
          child: Text(
            judul,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 16),
        // Never wider than the row leaves (the badge text does not wrap).
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: math.max(0, k.maxWidth - 60)),
          child: LencanaStatus(label, bentuk: bentuk),
        ),
      ],
    ),
  );
}

/// Phone list row: its own card, a self link.
class _BarisPonsel extends StatelessWidget {
  const _BarisPonsel({required this.d, required this.keBaris});

  final DokumenGereja d;
  final String keBaris;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tautan(
      ke: keBaris,
      radius: 14,
      child: Kartu(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.judul,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      d.jenisTanggalUntuk,
                      style: TextStyle(fontSize: 13, color: c.tinta3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              LencanaStatus(d.status, bentuk: d.gaya.bentuk),
              const SizedBox(width: 12),
              PalakatIkon(Ikon.lanjut, ukuran: 18, warna: c.tinta3),
            ],
          ),
        ),
      ),
    );
  }
}

/// Web table: one card, rows with a top rule (none on the first).
class _TabelWeb extends StatelessWidget {
  const _TabelWeb({required this.dok, required this.keBaris});

  final List<DokumenGereja> dok;
  final String keBaris;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Kartu(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < dok.length; i++)
              Tautan(
                ke: keBaris,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  decoration: i == 0
                      ? null
                      : BoxDecoration(
                          border: Border(top: BorderSide(color: c.garis)),
                        ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 52),
                    child: Row(
                      children: [
                        Expanded(child: _SelWeb(d: dok[i])),
                        const SizedBox(width: 16),
                        // Each row is its own grid: column 2 is this badge.
                        LencanaStatus(
                          dok[i].status,
                          bentuk: dok[i].gaya.bentuk,
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 20,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: PalakatIkon(
                              Ikon.lanjut,
                              ukuran: 18,
                              warna: c.tinta3,
                            ),
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
    );
  }
}

/// Web cell 1: title `flex: 1 1 260px` and meta `flex: 1.4 1 300px` in a
/// wrapping, baseline-aligned row, gap 2 20.
class _SelWeb extends StatelessWidget {
  const _SelWeb({required this.d});

  final DokumenGereja d;

  @override
  Widget build(BuildContext context) {
    final judul = Text(
      d.judul,
      style: const TextStyle(fontWeight: FontWeight.w600),
    );
    final meta = Text(
      d.jenisTanggalUntuk,
      style: TextStyle(fontSize: 13, color: context.warna.tinta3),
    );
    const anak = [
      Lentur(dasar: 260, child: SizedBox()),
      Lentur(dasar: 300, tumbuh: 1.4, child: SizedBox()),
    ];
    return LayoutBuilder(
      builder: (context, k) {
        final b = BarisLentur.lebar(anak, 20, k.maxWidth);
        if (b.length == 1) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              SizedBox(width: b[0][0], child: judul),
              const SizedBox(width: 20),
              SizedBox(width: b[0][1], child: meta),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [judul, const SizedBox(height: 2), meta],
        );
      },
    );
  }
}
