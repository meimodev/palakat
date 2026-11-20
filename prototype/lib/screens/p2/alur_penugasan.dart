import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_modul.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/riwayat_alur.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import '../../app/layar.dart';

const _hariT = '16/11/2026';
const _hari = 20261116;
const _saran = [
  'Sym. Greis Mamahit',
  'Pnt. Altje Rompas',
  'Pdt. Lidya Rondonuwu',
];
const _doks = ['SK BPMJ No. 14/2026', 'Belum ada dokumen'];

/// The board's `tgl`: hh/bb/tttt → yyyymmdd, or null. Days per month unchecked.
int? _tgl(String t) {
  final m = RegExp(r'^(\d\d)/(\d\d)/(\d{4})$').firstMatch(t.trim());
  if (m == null) return null;
  final d = int.parse(m[1]!), b = int.parse(m[2]!);
  if (b < 1 || b > 12 || d < 1 || d > 31) return null;
  return int.parse(m[3]!) * 10000 + b * 100 + d;
}

/// 53 · Alur · Penugasan jabatan: the list and the form change in place.
class AlurPenugasanScreen extends StatefulWidget {
  const AlurPenugasanScreen({super.key});

  @override
  State<AlurPenugasanScreen> createState() => _AlurPenugasanScreenState();
}

class _AlurPenugasanScreenState extends State<AlurPenugasanScreen> {
  final _gulir = ScrollController();
  final _orang = TextEditingController();
  final _mulai = TextEditingController(text: _hariT);
  String _pesan = '', _dok = '';
  final _riw = <String>[];
  bool _form = false;
  int _sel = 0;
  // [jabatan, unit, holder, since]; an empty holder means vacant.
  final _j = [
    ['Syamas', 'Kolom 3', '', ''],
    ['Penatua', 'Kolom 2', '', ''],
    ['Ketua', 'Komisi Diakonia', 'Pnt. Hendrik Rumagit', '01/03/2026'],
    ['Operator', 'Jemaat', 'Yanti Sumual', '01/11/2026'],
  ];

  @override
  void dispose() {
    _gulir.dispose();
    _orang.dispose();
    _mulai.dispose();
    super.dispose();
  }

  String _alasan() {
    final o = _orang.text.trim();
    final t = _tgl(_mulai.text);
    if (o.isEmpty) return 'orang belum diisi.';
    if (o.contains('Lidya')) {
      return 'Anda tidak dapat menugaskan jabatan kepada diri sendiri.';
    }
    if (t == null) return 'tanggal mulai tidak dikenali. Contoh: 16/11/2026.';
    if (t > _hari) {
      return 'tanggal mulai belum tiba. Penugasan dicatat pada atau setelah tanggal mulainya.';
    }
    if (_dok.isEmpty) return 'keputusan gereja belum dipilih.';
    if (_dok == 'Belum ada dokumen') {
      return 'penugasan memerlukan keputusan tertulis gereja di Dokumen gereja.';
    }
    return '';
  }

  void _lihat(bool form, [VoidCallback? ubah]) {
    setState(() {
      ubah?.call();
      _form = form;
    });
    if (_gulir.hasClients) _gulir.jumpTo(0);
  }

  void _keDaftar(String pesan) {
    _pesan = pesan;
    _orang.clear();
    _dok = '';
  }

  void _ubah(int i, String org, String sejak, String teks) => _lihat(false, () {
    _j[i][2] = org;
    _j[i][3] = sejak;
    _keDaftar(teks);
    _riw.insert(0, '$_hariT · $teks Dicatat oleh Pdt. Lidya Rondonuwu.');
  });

  void _catatTugas() {
    final j = _j[_sel], o = _orang.text.trim(), m = _mulai.text.trim();
    _ubah(
      _sel,
      o,
      m,
      '${j[0]} ${j[1]} dipegang $o sejak $m. Keputusan: $_dok.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = _form ? _isiForm(context) : _isiDaftar(context);
    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Alur · Penugasan jabatan',
            anakJudul: 'Dari jabatan kosong sampai ada pemegangnya',
            kembaliKe: Layar.penugasan,
            labelKembali: 'Kembali ke Penugasan jabatan',
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _gulir,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, w) in body.indexed) ...[
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

  List<Widget> _isiDaftar(BuildContext context) {
    final c = context.warna;
    return [
      if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
      for (final (i, x) in _j.indexed) _kartu(c, i, x),
      Text(
        'Penugasan mencatat keputusan gereja; keputusannya sendiri ada di Dokumen gereja, bukan persetujuan di aplikasi.',
        style: TextStyle(fontSize: 13, color: c.tinta3),
      ),
      if (_riw.isNotEmpty) RiwayatAlur(baris: _riw),
    ];
  }

  Widget _kartu(PalakatWarna c, int i, List<String> x) {
    final kosong = x[2].isEmpty;
    return Kartu(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KepalaKartu(
            judul: '${x[0]} ${x[1]}',
            ujung: LencanaModul.jabatan(
              kosong ? KeadaanJabatan.jabatanKosong : KeadaanJabatan.aktif,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            kosong ? 'Belum ada pemegang' : '${x[2]} · sejak ${x[3]}',
            style: TextStyle(fontSize: 13, color: c.tinta3),
          ),
          if (kosong) ...[
            const SizedBox(height: 6),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Tombol(
                'Tugaskan',
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.sedang,
                lebarPenuh: false,
                onPressed: () => _lihat(true, () {
                  _sel = i;
                  _pesan = '';
                }),
              ),
            ),
          ],
          if (!kosong && i == 2) ...[
            const SizedBox(height: 6),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Tombol(
                'Catat berakhir',
                jenis: JenisTombol.teks,
                ukuran: UkuranTombol.kecil,
                lebarPenuh: false,
                onPressed: () => _ubah(
                  i,
                  '',
                  '',
                  '${x[0]} ${x[1]}: penugasan ${x[2]} berakhir $_hariT. Jabatan ini menjadi Jabatan kosong.',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _isiForm(BuildContext context) {
    final j = _j[_sel];
    final alasan = _alasan();
    final mulai = _orang.text.isNotEmpty || _dok.isNotEmpty;
    return [
      Kartu(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BarisInfo('Jabatan', j[0]),
            const SizedBox(height: 6),
            BarisInfo('Unit', j[1]),
          ],
        ),
      ),
      IsianAlur(
        label: 'Orang',
        controller: _orang,
        onChanged: (_) => setState(() {}),
        petunjuk: 'Nama orang',
        keterangan: 'Ketik nama, atau pilih di bawah.',
      ),
      _ChipAlur(
        label: 'Dari Data jemaat',
        pilihan: _saran,
        terpilih: _orang.text,
        onPilih: (n) => setState(() {
          _orang.text = n;
          _pesan = '';
        }),
      ),
      IsianAlur(
        label: 'Mulai',
        controller: _mulai,
        onChanged: (_) => setState(() {}),
        petunjuk: 'hh/bb/tttt',
        keterangan: 'Tanggal, bulan, tahun. Contoh: 16/11/2026.',
        keyboard: TextInputType.datetime,
      ),
      _ChipAlur(
        label: 'Keputusan gereja',
        pilihan: _doks,
        terpilih: _dok,
        onPilih: (n) => setState(() {
          _dok = n;
          _pesan = '';
        }),
      ),
      if (mulai && alasan.isNotEmpty)
        Penolakan(
          tindakan: 'Catat penugasan',
          sebab: alasan,
          jalan: const [],
          ukuranTeks: 14,
        ),
      BarisTombol(
        anak: [
          TombolBersyarat(
            label: 'Catat penugasan',
            tindakan: 'Catat penugasan',
            alasan: alasan,
            periksa: _alasan,
            sudahMulai: false,
            onPressed: _catatTugas,
          ),
          Tombol(
            'Batalkan',
            jenis: JenisTombol.teks,
            ukuran: UkuranTombol.kecil,
            onPressed: () => _lihat(false, () => _keDaftar('')),
          ),
        ],
      ),
    ];
  }
}

/// Chip group (K7) with the board's plain `gap: 8px` wrap: ChipPilihan adds
/// an 8 px bottom margin under its chips that the flow boards do not have.
class _ChipAlur extends StatelessWidget {
  const _ChipAlur({
    required this.label,
    required this.pilihan,
    required this.terpilih,
    required this.onPilih,
  });

  final String label;
  final List<String> pilihan;
  final String terpilih;
  final ValueChanged<String> onPilih;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(fontSize: 14, color: context.warna.tinta2)),
      const SizedBox(height: 6),
      // Flutter rounds each label's width up to a whole pixel, so two chips
      // that share a 350 line in Chrome (348.x) measure 351 here: 2 px slack
      // keeps the board's line breaks.
      _Longgar(
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final n in pilihan)
              ChipSatu(
                teks: n,
                dipilih: n == terpilih,
                onTap: () => onPilih(n),
              ),
          ],
        ),
      ),
    ],
  );
}

/// Lays its child out 2 px wider than offered and takes the offered width.
class _Longgar extends SingleChildRenderObjectWidget {
  const _Longgar({required Widget super.child});

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderLonggar();
}

class _RenderLonggar extends RenderProxyBox {
  @override
  void performLayout() {
    final c = constraints;
    child!.layout(
      c.copyWith(minWidth: 0, maxWidth: c.maxWidth + 2),
      parentUsesSize: true,
    );
    size = c.constrain(child!.size);
  }
}
