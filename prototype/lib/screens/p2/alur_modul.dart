import 'package:flutter/widgets.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_modul.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/riwayat_alur.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import '../../app/layar.dart';

const _hariT = '16/11/2026';

/// The board's `M`: name and dependency ('' = none); the state lives in [_AlurModulState._k].
const _modul = [
  ('Keuangan', ''),
  ('Pengumuman', ''),
  ('Warta Jemaat', 'Pengumuman'),
  ('Data jemaat', ''),
  ('Ibadah dan kegiatan', 'Data jemaat'),
  ('Jumlah kehadiran', 'Ibadah dan kegiatan'),
];

/// 57 · Alur · Modul (spec 15): on in dependency order, off to Hanya baca with a reason.
class AlurModulScreen extends StatefulWidget {
  const AlurModulScreen({super.key});

  @override
  State<AlurModulScreen> createState() => _AlurModulState();
}

class _AlurModulState extends State<AlurModulScreen> {
  String _pesan = '';
  final List<String> _riw = [];
  String _v = 'daftar';
  int _sel = 3;
  final _alasan = TextEditingController();
  final _k = [
    KeadaanModul.aktif,
    KeadaanModul.aktif,
    KeadaanModul.aktif,
    KeadaanModul.tidakAktif,
    KeadaanModul.tidakAktif,
    KeadaanModul.tidakAktif,
  ];

  @override
  void dispose() {
    _alasan.dispose();
    super.dispose();
  }

  String get _nama => _modul[_sel].$1;
  String get _dep => _modul[_sel].$2;

  /// "Hanya baca" counts as not active.
  String _kurang() {
    if (_dep.isEmpty) return '';
    final i = _modul.indexWhere((m) => m.$1 == _dep);
    return _k[i] == KeadaanModul.aktif
        ? ''
        : 'modul $_dep harus aktif lebih dulu.';
  }

  // P12: not blank, no minimum length. The board shows no sentence; the
  // field's label is read out as the hint.
  String _kurangAlasan() => _alasan.text.trim().isEmpty ? 'Alasan · wajib' : '';

  void _ke(String v, [int? sel]) => setState(() {
    _v = v;
    _pesan = '';
    if (sel != null) _sel = sel;
    if (v == 'mati') _alasan.clear();
  });

  void _ubah(KeadaanModul baru, String teks) => setState(() {
    _k[_sel] = baru;
    _v = 'daftar';
    _alasan.clear();
    _pesan = teks;
    _riw.insert(0, '$_hariT · $teks Oleh Pdt. Lidya Rondonuwu.');
  });

  @override
  Widget build(BuildContext context) {
    final isi = switch (_v) {
      'aktif' => _aktif(context),
      'mati' => _mati(context),
      _ => _daftar(context),
    };
    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Alur · Modul',
            anakJudul: 'Mengaktifkan dan menonaktifkan, satu per satu',
            kembaliKe: Layar.modul,
            labelKembali: 'Kembali ke Modul',
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
    onPressed: () => _ke('daftar'),
    jenis: JenisTombol.teks,
    ukuran: UkuranTombol.kecil,
  );

  List<Widget> _daftar(BuildContext context) {
    final c = context.warna;
    return [
      if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
      for (final (i, (nama, dep)) in _modul.indexed)
        Kartu(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              KepalaKartu(judul: nama, ujung: LencanaModul.modul(_k[i])),
              const SizedBox(height: 6),
              Text(
                dep.isNotEmpty
                    ? 'Perlu: $dep aktif'
                    : _k[i] == KeadaanModul.hanyaBaca
                    ? 'Riwayat tetap dapat dibaca'
                    : 'Tidak bergantung pada modul lain',
                style: TextStyle(fontSize: 13, color: c.tinta3),
              ),
              if (_k[i] != KeadaanModul.aktif) ...[
                const SizedBox(height: 6),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Tombol(
                    'Aktifkan modul',
                    onPressed: () => _ke('aktif', i),
                    jenis: JenisTombol.kedua,
                    ukuran: UkuranTombol.sedang,
                    lebarPenuh: false,
                  ),
                ),
              ] else if (i > 0) ...[
                const SizedBox(height: 6),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Tombol(
                    'Nonaktifkan modul',
                    onPressed: () => _ke('mati', i),
                    jenis: JenisTombol.teks,
                    ukuran: UkuranTombol.kecil,
                    lebarPenuh: false,
                  ),
                ),
              ],
            ],
          ),
        ),
      Text(
        'Modul yang tidak aktif tidak tampil di navigasi, pencarian, pemberitahuan atau keadaan kosong mana pun.',
        style: TextStyle(fontSize: 13, color: c.tinta3),
      ),
      if (_riw.isNotEmpty) RiwayatAlur(baris: _riw),
    ];
  }

  List<Widget> _aktif(BuildContext context) {
    final kurang = _kurang();
    return [
      Kartu(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KepalaKartu(
              judul: 'Aktifkan modul: $_nama',
              // Always this badge, even for a Hanya baca module (as drawn).
              ujung: const LencanaModul.modul(KeadaanModul.tidakAktif),
            ),
            if (_dep.isNotEmpty) ...[
              const SizedBox(height: 6),
              BarisInfo('Harus aktif lebih dulu', _dep),
            ],
            const SizedBox(height: 6),
            Text(
              'Mengaktifkan modul membuka layarnya bagi jabatan yang berwenang. Tidak ada data yang dibuat sendiri oleh aplikasi.',
              style: TextStyle(fontSize: 13, color: context.warna.tinta3),
            ),
          ],
        ),
      ),
      if (kurang.isNotEmpty)
        Penolakan(
          tindakan: 'Aktifkan modul',
          sebab: kurang,
          jalan: const [],
          ukuranTeks: 14,
        ),
      BarisTombol(
        anak: [
          TombolBersyarat(
            label: 'Aktifkan modul',
            tindakan: 'Aktifkan modul',
            alasan: kurang,
            periksa: _kurang,
            sudahMulai: false,
            onPressed: () =>
                _ubah(KeadaanModul.aktif, 'Modul $_nama aktif sejak $_hariT.'),
          ),
          _kembali,
        ],
      ),
    ];
  }

  List<Widget> _mati(BuildContext context) => [
    Kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KepalaKartu(
            judul: 'Nonaktifkan modul: $_nama',
            ujung: const LencanaModul.modul(KeadaanModul.aktif),
          ),
          const SizedBox(height: 6),
          Text.rich(
            const TextSpan(
              children: [
                TextSpan(
                  text: 'Menonaktifkan tidak menghapus apa pun. Modul menjadi ',
                ),
                TextSpan(
                  text: 'Hanya baca',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: ': yang sudah ada tetap dapat dibaca, tetapi tidak ada yang baru.',
                ),
              ],
            ),
            style: TextStyle(fontSize: 14, color: context.warna.tinta2),
          ),
        ],
      ),
    ),
    IsianAlur(
      label: 'Alasan · wajib',
      controller: _alasan,
      onChanged: (_) => setState(() {}),
      baris: 3,
    ),
    BarisTombol(
      anak: [
        TombolBersyarat(
          label: 'Nonaktifkan modul',
          tindakan: 'Nonaktifkan modul',
          alasan: _kurangAlasan(),
          periksa: _kurangAlasan,
          sudahMulai: false,
          onPressed: () => _ubah(
            KeadaanModul.hanyaBaca,
            'Modul $_nama dinonaktifkan dan menjadi Hanya baca · alasan: ${_alasan.text.trim()}.',
          ),
        ),
        _kembali,
      ],
    ),
  ];
}
