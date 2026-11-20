import 'package:flutter/material.dart';

import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/riwayat_alur.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';

/// The fixed Kas/Bank cards of KasUnit and WebKasUnit: name, sub-line.
const _tetap = [
  ('Kas', 'Dikelola Jemaat'),
  ('Bank BNI ··4821', 'Dikelola Jemaat'),
  ('Bank SulutGo ··1107', 'Dikelola Jemaat'),
  ('Kas Kolom 7', 'Dikelola oleh Kolom 7 · Bendahara: Deasy Tumbelaka'),
];

const _semuaUnit = ['Panitia Natal 2026', 'Kolom 4', 'Komisi Diakonia'];

/// The body of KasUnit (phone) and WebKasUnit (web): the boards share one
/// logic class, handler for handler. [web] puts the `tambah` form in the
/// two-column form row.
class KasUnitIsi extends StatefulWidget {
  const KasUnitIsi({super.key, this.web = false});

  final bool web;

  @override
  State<KasUnitIsi> createState() => _KasUnitIsiState();
}

class _KasUnitIsiState extends State<KasUnitIsi> {
  String _v = 'daftar';
  final _nama = TextEditingController();
  String? _unit;
  String _pesan = '';
  final _riw = <String>[];
  final _k = <(String, String)>[];

  @override
  void dispose() {
    _nama.dispose();
    super.dispose();
  }

  String _alasan() {
    if (_nama.text.trim().isEmpty) return 'nama Kas/Bank belum diisi.';
    if (_unit == null) return 'unit belum dipilih.';
    if (_unit == 'Komisi Diakonia') {
      return 'Komisi Diakonia belum punya bendahara unit.';
    }
    return '';
  }

  /// The board's `ke(v, o)`: a view change clears `pesan`; the body jumps to top.
  void _ke(String v, [VoidCallback? lagi]) {
    setState(() {
      _v = v;
      _pesan = '';
      lagi?.call();
    });
    final p = Scrollable.maybeOf(context)?.position;
    if (p != null && p.hasPixels) p.jumpTo(0);
  }

  void _keTambah() => _ke('tambah', () {
    _nama.clear();
    _unit = null;
  });

  void _simpan() {
    final n = _nama.text.trim();
    final t = '$n dikelola oleh $_unit, berlaku mulai Desember 2026.';
    final unit = _unit!;
    _ke('daftar', () {
      _k.add((n, unit));
      _pesan = t;
      _riw.insert(0, '16/11/2026 · $t Oleh Meiske Lumentut, Bendahara Jemaat.');
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final anak = _v == 'daftar' ? _daftar(c) : _tambah(c);
    return CssLeading(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < anak.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            anak[i],
          ],
        ],
      ),
    );
  }

  List<Widget> _daftar(PalakatWarna c) => [
    if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
    for (final (j, s) in _tetap) _kartu(c, j, s, 'Aktif', BentukLencana.laut),
    for (final (j, u) in _k)
      _kartu(
        c,
        j,
        'Dikelola oleh $u',
        'Berlaku mulai Desember 2026',
        BentukLencana.draf,
      ),
    BarisTombol(
      anak: [
        Tombol(
          'Tambah Kas/Bank unit',
          jenis: JenisTombol.tinta,
          onPressed: _keTambah,
        ),
      ],
    ),
    Text(
      'Bendahara unit membukukan hanya pada Kas/Bank yang dikelola unitnya. '
      'Kas/Bank lain tetap pada Bendahara Jemaat.',
      style: TextStyle(fontSize: 13, color: c.tinta3),
    ),
    if (_riw.isNotEmpty) RiwayatAlur(baris: List.of(_riw)),
  ];

  Widget _kartu(
    PalakatWarna c,
    String j,
    String s,
    String l,
    BentukLencana b,
  ) => Kartu(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KepalaKartu(
          judul: j,
          ujung: LencanaStatus(l, bentuk: b),
        ),
        const SizedBox(height: 6),
        Text(s, style: TextStyle(fontSize: 13, color: c.tinta3)),
      ],
    ),
  );

  List<Widget> _tambah(PalakatWarna c) {
    final alasan = _alasan();
    final kiri = [
      _TanpaJarakHuruf(
        child: IsianAlur(
          label: 'Nama Kas/Bank',
          controller: _nama,
          petunjuk: 'Contoh: Kas Panitia Natal 2026',
          onChanged: (_) => setState(() {}),
        ),
      ),
      ChipPilihan<String>(
        label: 'Dikelola oleh',
        jarakLabel: 6,
        jarakBawah: 0,
        pilihan: [for (final u in _semuaUnit) (nilai: u, teks: u)],
        terpilih: _unit,
        onPilih: (u) => setState(() {
          _unit = u;
          _pesan = '';
        }),
      ),
      const BarisInfo('Berlaku mulai', 'Desember 2026'),
      Text(
        'Perubahan pengaturan berlaku mulai bulan berikutnya.',
        style: TextStyle(fontSize: 13, color: c.tinta3),
      ),
    ];
    final kanan = [
      if ((_nama.text.isNotEmpty || _unit != null) && alasan.isNotEmpty)
        Penolakan(
          tindakan: 'Simpan',
          sebab: alasan,
          jalan: const [],
          ukuranTeks: 14,
        ),
      BarisTombol(
        anak: [
          TombolBersyarat(
            label: 'Simpan',
            tindakan: 'Simpan',
            alasan: alasan,
            periksa: _alasan,
            sudahMulai: false,
            onPressed: _simpan,
          ),
          Tombol(
            'Batalkan',
            jenis: JenisTombol.teks,
            ukuran: UkuranTombol.kecil,
            onPressed: () => _ke('daftar'),
          ),
        ],
      ),
    ];
    if (!widget.web) return [...kiri, ...kanan];
    Widget kolom(List<Widget> a) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < a.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          a[i],
        ],
      ],
    );
    return [
      BarisLentur(
        jarak: 28,
        jarakBaris: 20,
        anak: [
          Lentur(dasar: 420, tumbuh: 1.3, child: kolom(kiri)),
          Lentur(dasar: 340, child: kolom(kanan)),
        ],
      ),
    ];
  }
}

/// CSS half-leading: the boards split a line's extra height evenly above and
/// below the glyphs; Flutter's default puts more above (text 1–2 px low).
class CssLeading extends StatelessWidget {
  const CssLeading({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DefaultTextStyle.merge(
    style: const TextStyle(leadingDistribution: TextLeadingDistribution.even),
    child: child,
  );
}

/// The M3 TextField takes `bodyLarge` (letter-spacing 0.5) under its text and
/// placeholder; the board's input has none.
class _TanpaJarakHuruf extends StatelessWidget {
  const _TanpaJarakHuruf({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Theme(
      data: t.copyWith(
        textTheme: t.textTheme.copyWith(
          bodyLarge: t.textTheme.bodyLarge?.copyWith(letterSpacing: 0),
        ),
      ),
      child: child,
    );
  }
}
