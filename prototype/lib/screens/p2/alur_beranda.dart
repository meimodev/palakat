import 'package:flutter/widgets.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/bertindak_sebagai.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/riwayat_alur.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import '../../app/layar.dart';

const _hariT = '16/11/2026';
const _jabatan = ['Penatua Kolom 7', 'Ketua Komisi Diakonia'];

/// The board's `T`: key, title, "Sebagai …" line.
const _tindak = [
  (
    'a',
    'Baptisan · Gabriel Wenas menunggu verifikasi',
    'Sebagai Penatua Kolom 7',
  ),
  (
    'b',
    'Jadwal ibadah Kolom 7 bersama Komisi Diakonia',
    'Sebagai Penatua Kolom 7 atau Ketua Komisi Diakonia',
  ),
  (
    'c',
    'Permintaan dana Komisi Diakonia',
    'Sebagai Ketua Komisi Diakonia · pengajuan Anda sendiri',
  ),
];

/// 56 · Alur · Beranda gabungan (spec 15): one Beranda, the post picked per action.
class AlurBerandaScreen extends StatefulWidget {
  const AlurBerandaScreen({super.key});

  @override
  State<AlurBerandaScreen> createState() => _AlurBerandaState();
}

class _AlurBerandaState extends State<AlurBerandaScreen> {
  String _pesan = '';
  final List<String> _riw = [];
  String _v = 'beranda';
  final List<String> _beres = [];
  String _jab = '';

  void _ke(String v) => setState(() {
    _v = v;
    _pesan = '';
  });

  void _selesai(String k, String teks) => setState(() {
    _v = 'beranda';
    _beres.add(k);
    _pesan = teks;
    _riw.insert(0, '$_hariT · $teks');
  });

  @override
  Widget build(BuildContext context) {
    final isi = switch (_v) {
      'a' => _viewA(),
      'b' => _viewB(),
      'c' => _viewC(context),
      _ => _beranda(context),
    };
    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Alur · Beranda gabungan',
            anakJudul: 'Satu Beranda; jabatan dipilih per tindakan',
            kembaliKe: Layar.beranda,
            labelKembali: 'Kembali ke Beranda',
          ),
          Expanded(
            child: SingleChildScrollView(
              // A new view starts at the top.
              key: ValueKey(_v),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, w) in isi.indexed) ...[
                    if (i > 0) const SizedBox(height: 16),
                    w,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget get _kembali => Tombol(
    'Kembali',
    onPressed: () => _ke('beranda'),
    jenis: JenisTombol.teks,
    ukuran: UkuranTombol.kecil,
  );

  List<Widget> _beranda(BuildContext context) {
    final c = context.warna;
    final sisa = _tindak.where((t) => !_beres.contains(t.$1)).toList();
    return [
      const DaftarJabatan(nama: 'Pnt. Hendrik Rumagit', jabatan: _jabatan),
      if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
      Semantics(
        header: true,
        child: Text(
          'Perlu tindakan · ${sisa.length}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      for (final t in sisa)
        Tekan(
          onTap: () => _ke(t.$1),
          radius: 14,
          child: Kartu(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.$2,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        t.$3,
                        style: TextStyle(fontSize: 13, color: c.tinta3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                PalakatIkon(Ikon.lanjut, ukuran: 18, warna: c.tinta3),
              ],
            ),
          ),
        ),
      // Unreachable on this board (item c never finishes); drawn anyway.
      if (sisa.isEmpty)
        Kartu(
          status: GarisStatus.draf,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Tidak ada yang perlu tindakan',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Pekerjaan dari semua jabatan Anda akan muncul di sini.',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ],
          ),
        ),
      if (_riw.isNotEmpty) RiwayatAlur(baris: _riw),
    ];
  }

  Widget _kartu(String judul, Widget lencana, List<Widget> baris) => Kartu(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KepalaKartu(judul: judul, ujung: lencana),
        for (final b in baris) ...[const SizedBox(height: 6), b],
      ],
    ),
  );

  Widget _baris(String teks) => Builder(
    builder: (context) =>
        Text(teks, style: TextStyle(fontSize: 14, color: context.warna.tinta2)),
  );

  List<Widget> _viewA() => [
    _kartu(
      'Verifikasi data · Peristiwa: Baptisan',
      const LencanaStatus('Diajukan', bentuk: BentukLencana.garis),
      [
        _baris('Gabriel Wenas · Keluarga Wenas-Lasut · Kolom 7'),
        const BarisInfo('Diajukan oleh', 'Novita Wenas, 15/11/2026'),
      ],
    ),
    const BertindakSebagai.satu(
      jabatan: 'Penatua Kolom 7',
      kalimat: 'Hanya jabatan ini yang berwenang memverifikasi data Kolom 7.',
    ),
    BarisTombol(
      anak: [
        Tombol(
          'Verifikasi data',
          onPressed: () => _selesai(
            'a',
            'Baptisan · Gabriel Wenas diverifikasi · Pnt. Hendrik Rumagit, Penatua Kolom 7',
          ),
          jenis: JenisTombol.tinta,
        ),
        _kembali,
      ],
    ),
  ];

  List<Widget> _viewB() => [
    _kartu(
      'Setujui jadwal · Ibadah Kolom 7 bersama Komisi Diakonia',
      const LencanaStatus('Draf', bentuk: BentukLencana.draf),
      [_baris('Kamis, 19/11/2026 19.00 · rumah Kel. Wenas-Lasut')],
    ),
    const Kartu(
      status: GarisStatus.terpilih,
      radius: 12,
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Dua jabatan Anda dapat menyetujui ini.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(
              text: ' Pilih salah satu. Jabatan yang Anda pilih tercatat di Riwayat dan tidak dapat diubah setelahnya.',
            ),
          ],
        ),
        style: TextStyle(fontSize: 14),
      ),
    ),
    Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bertindak sebagai',
            style: TextStyle(fontSize: 14, color: context.warna.tinta2),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final j in _jabatan)
                ChipSatu(
                  teks: j,
                  dipilih: _jab == j,
                  onTap: () => setState(() {
                    _jab = j;
                    _pesan = '';
                  }),
                ),
            ],
          ),
        ],
      ),
    ),
    BarisTombol(
      anak: [
        TombolBersyarat(
          label: 'Setujui jadwal',
          tindakan: 'Setujui jadwal',
          // The board shows no sentence; the notice's own words are read out.
          alasan: _jab.isEmpty ? 'Pilih salah satu.' : '',
          sudahMulai: false,
          onPressed: () => _selesai(
            'b',
            'Jadwal ibadah Kolom 7 disetujui · Pnt. Hendrik Rumagit, $_jab',
          ),
        ),
        _kembali,
      ],
    ),
  ];

  List<Widget> _viewC(BuildContext context) => [
    _kartu(
      'Permintaan dana · Komisi Diakonia',
      const LencanaStatus('Diajukan', bentuk: BentukLencana.garis),
      const [
        BarisInfo('Jumlah (Rp)', 'Rp750.000', mono: true),
        _BarisInfoSusut(
          'Diajukan oleh',
          'Pnt. Hendrik Rumagit, Ketua Komisi Diakonia',
        ),
      ],
    ),
    const Penolakan(
      tindakan: 'Setujui',
      sebab: 'permintaan ini Anda ajukan sendiri. Jabatan Anda yang lain tidak membuka jalan menyetujuinya.',
      jalan: [],
    ),
    Text(
      'Menunggu Pdt. Lidya Rondonuwu, Ketua Jemaat.',
      style: TextStyle(fontSize: 13, color: context.warna.tinta3),
    ),
    BarisTombol(
      anak: [
        Tombol(
          'Kembali',
          onPressed: () => _ke('beranda'),
          jenis: JenisTombol.kedua,
          ukuran: UkuranTombol.sedang,
        ),
      ],
    ),
  ];
}

/// [BarisInfo] whose two spans shrink as CSS flex items do (`flex-shrink: 1`,
/// weighted by their widths, never below their longest word): on the board the
/// label "Diajukan oleh" wraps beside the long value. BarisInfo never shrinks
/// its label.
class _BarisInfoSusut extends StatelessWidget {
  const _BarisInfoSusut(this.label, this.nilai);

  final String label;
  final String nilai;

  static const _jarak = 16.0;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final dasar = DefaultTextStyle.of(context).style
        .merge(const TextStyle(fontSize: 14));
    final gayaLabel = dasar.copyWith(color: c.tinta2);
    final gayaNilai = dasar.copyWith(
      color: c.tinta,
      fontWeight: FontWeight.w600,
    );
    final skala = MediaQuery.textScalerOf(context);
    double lebar(String t, TextStyle g) {
      final p = TextPainter(
        text: TextSpan(text: t, style: g),
        textDirection: TextDirection.ltr,
        textScaler: skala,
      )..layout();
      final w = p.width;
      p.dispose();
      return w;
    }

    return LayoutBuilder(
      builder: (context, ruang) {
        final wL = lebar(label, gayaLabel), wN = lebar(nilai, gayaNilai);
        final lebih = wL + wN + _jarak - ruang.maxWidth;
        final kata = label
            .split(' ')
            .map((k) => lebar(k, gayaLabel))
            .reduce((a, b) => a > b ? a : b);
        final l = lebih <= 0
            ? wL
            : (wL - lebih * wL / (wL + wN)).clamp(kata, wL);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: l.ceilToDouble(),
              child: Text(label, style: gayaLabel),
            ),
            const SizedBox(width: _jarak),
            Expanded(
              child: Text(nilai, textAlign: TextAlign.right, style: gayaNilai),
            ),
          ],
        );
      },
    );
  }
}
