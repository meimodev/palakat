import 'package:flutter/material.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/riwayat_alur.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';

/// 55 · Alur · Pelimpahan tugas (screens/15-cariorang.md): Pnt. Hendrik
/// Rumagit delegates one task with an end date. Views `daftar` and `form`
/// change in place under one header.
class AlurPelimpahanScreen extends StatefulWidget {
  const AlurPelimpahanScreen({super.key});

  @override
  State<AlurPelimpahanScreen> createState() => _AlurPelimpahanScreenState();
}

const _hari = 20261116, _hariT = '16/11/2026', _diri = 'Pnt. Hendrik Rumagit';
const _penerima = ['Sym. Greis Mamahit', _diri];
const _daftarTugas = [
  'Verifikasi data Kolom 7',
  'Menyetujui jadwal ibadah Kolom 7',
];

/// The board's `tgl`: hh/bb/tttt after trim, month 1–12, day 1–31, as yyyymmdd.
int? _tgl(String t) {
  final m = RegExp(r'^(\d\d)/(\d\d)/(\d{4})$').firstMatch(t.trim());
  if (m == null) return null;
  final d = int.parse(m[1]!), b = int.parse(m[2]!);
  if (b < 1 || b > 12 || d < 1 || d > 31) return null;
  return int.parse(m[3]!) * 10000 + b * 100 + d;
}

class _AlurPelimpahanScreenState extends State<AlurPelimpahanScreen> {
  String _pesan = '', _v = 'daftar', _kepada = '', _tugas = '', _st = '';
  List<String> _riw = [];
  final _sampai = TextEditingController();
  final _gulir = ScrollController();

  @override
  void dispose() {
    _sampai.dispose();
    _gulir.dispose();
    super.dispose();
  }

  String _alasan() {
    final s = _sampai.text, t = _tgl(s);
    if (_kepada.isEmpty) return 'penerima belum dipilih.';
    if (_kepada == _diri) {
      return 'tugas tidak dapat dilimpahkan kepada diri sendiri.';
    }
    if (_tugas.isEmpty) return 'tugas belum dipilih.';
    if (s.trim().isEmpty) return 'tanggal berakhir belum diisi.';
    if (t == null) {
      return 'tanggal berakhir tidak dikenali. Contoh: 30/11/2026.';
    }
    if (t <= _hari) return 'tanggal berakhir harus setelah hari ini ($_hariT).';
    return '';
  }

  void _ke(String v) {
    if (_gulir.hasClients) _gulir.jumpTo(0);
    _v = v;
    _pesan = '';
  }

  void _keForm() => setState(() {
    _ke('form');
    _kepada = '';
    _tugas = '';
    _sampai.clear();
  });

  void _batal() => setState(() => _ke('daftar'));

  void _buat() => setState(() {
    _ke('daftar');
    _st = 'aktif';
    _pesan = '$_kepada diberi tahu lewat Pemberitahuan.';
    _riw = [
      '$_hariT · Pelimpahan dibuat: $_tugas kepada $_kepada sampai ${_sampai.text.trim()}',
      ..._riw,
    ];
  });

  void _akhiri() => setState(() {
    _st = 'usai';
    _pesan = '';
    _riw = [
      '$_hariT · Pelimpahan diakhiri: $_tugas kembali hanya kepada $_diri',
      ..._riw,
    ];
  });

  @override
  Widget build(BuildContext context) => LayarPonsel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const KepalaPonsel(
          judul: 'Alur · Pelimpahan tugas',
          anakJudul: 'Untuk sementara, dengan tanggal berakhir',
          kembaliKe: 'Pelimpahan',
          labelKembali: 'Kembali ke Pelimpahan tugas',
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _gulir,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: _v == 'form' ? _form(context) : _daftar(context),
            ),
          ),
        ),
      ],
    ),
  );

  List<Widget> _daftar(BuildContext context) {
    final c = context.warna;
    final usai = _st == 'usai';
    return [
      if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
      if (_st.isEmpty) ...[
        Kartu(
          status: GarisStatus.draf,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 6,
            children: [
              const Text(
                'Belum ada pelimpahan',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                'Limpahkan satu tugas kepada pelayan lain bila Anda berhalangan. '
                'Pelimpahan selalu punya tanggal berakhir.',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ],
          ),
        ),
        BarisTombol(
          anak: [
            Tombol(
              'Buat pelimpahan',
              jenis: JenisTombol.tinta,
              onPressed: _keForm,
            ),
          ],
        ),
      ] else ...[
        Kartu(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 6,
            children: [
              KepalaKartu(
                judul: _tugas,
                ujung: LencanaStatus(
                  usai ? 'Berakhir' : 'Aktif',
                  bentuk: usai ? BentukLencana.abu : BentukLencana.laut,
                ),
              ),
              Text(
                'Penatua Kolom 7 → $_kepada',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
              Text(
                usai
                    ? 'Diakhiri $_hariT oleh $_diri'
                    : 'Berlaku sampai ${_sampai.text.trim()} · berakhir sendiri pada tanggalnya',
                style: TextStyle(fontSize: 13, color: c.tinta3),
              ),
            ],
          ),
        ),
        BarisTombol(
          anak: [
            Tombol(
              usai ? 'Buat pelimpahan baru' : 'Akhiri sekarang',
              jenis: JenisTombol.kedua,
              ukuran: UkuranTombol.sedang,
              onPressed: usai ? _keForm : _akhiri,
            ),
          ],
        ),
        if (!usai)
          Text(
            'Selama pelimpahan aktif, Anda dan penerima sama-sama dapat '
            'menjalankan tugas ini. Setiap tindakan mencatat siapa yang '
            'menjalankannya.',
            style: TextStyle(fontSize: 13, color: c.tinta3),
          ),
      ],
      if (_riw.isNotEmpty) RiwayatAlur(baris: _riw),
    ];
  }

  List<Widget> _form(BuildContext context) {
    final alasan = _alasan();
    final mulai = _kepada.isNotEmpty || _tugas.isNotEmpty || _sampai.text != '';
    return [
      _GrupChip(
        label: 'Dilimpahkan kepada',
        pilihan: _penerima,
        terpilih: _kepada,
        onPilih: (n) => setState(() {
          _kepada = n;
          _pesan = '';
        }),
      ),
      _GrupChip(
        label: 'Tugas',
        pilihan: _daftarTugas,
        terpilih: _tugas,
        onPilih: (n) => setState(() {
          _tugas = n;
          _pesan = '';
        }),
      ),
      IsianAlur(
        label: 'Berlaku sampai',
        controller: _sampai,
        onChanged: (_) => setState(() {}),
        petunjuk: 'hh/bb/tttt',
        keterangan: 'Wajib. Pelimpahan berakhir sendiri pada tanggal ini.',
        keyboard: TextInputType.datetime,
      ),
      if (mulai && alasan.isNotEmpty)
        Penolakan(
          tindakan: 'Buat pelimpahan',
          sebab: alasan,
          jalan: const [],
          ukuranTeks: 14,
        ),
      BarisTombol(
        anak: [
          TombolBersyarat(
            label: 'Buat pelimpahan',
            tindakan: 'Buat pelimpahan',
            alasan: alasan,
            periksa: _alasan,
            sudahMulai: false,
            onPressed: _buat,
          ),
          Tombol(
            'Batalkan',
            jenis: JenisTombol.teks,
            ukuran: UkuranTombol.kecil,
            onPressed: _batal,
          ),
        ],
      ),
    ];
  }
}

/// K7 as the flow boards draw it: caption 14 `tinta2`, gap 6, chips in a wrap
/// with gap 8 and no trailing margin (ChipPilihan adds an 8 px bottom margin).
class _GrupChip extends StatelessWidget {
  const _GrupChip({
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
    spacing: 6,
    children: [
      Text(label, style: TextStyle(fontSize: 14, color: context.warna.tinta2)),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final n in pilihan)
            ChipSatu(teks: n, dipilih: n == terpilih, onTap: () => onPilih(n)),
        ],
      ),
    ],
  );
}
