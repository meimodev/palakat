import 'package:flutter/widgets.dart';

import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/riwayat_alur.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';

/// One letter request: the board's `P` entry [jenis, nama, keterangan,
/// status, keluarga·kolom].
class _Mohon {
  _Mohon(this.jenis, this.nama, this.ket, this.kel);
  final String jenis, nama, kel;
  String ket;
  String status = 'Diajukan';
}

const _hariT = '16/11/2026';

enum _V { daftar, buka, tolak }

/// The flow of AlurSurat and WebAlurSurat (screens/19-alursurat.md): the
/// views `daftar`, `buka` and `tolak` with the board's flow object `a`.
/// [web]: `buka` as the two-column row, right column gap 12.
class AlurSuratIsi extends StatefulWidget {
  const AlurSuratIsi({super.key, this.web = false});

  final bool web;

  @override
  State<AlurSuratIsi> createState() => _AlurSuratIsiState();
}

class _AlurSuratIsiState extends State<AlurSuratIsi> {
  final _no = TextEditingController();
  final _alasan = TextEditingController();
  final _p = [
    _Mohon(
      'Surat keterangan',
      'Novita Wenas',
      'Diajukan 14/11/2026 · untuk melamar pekerjaan',
      'Wenas-Lasut · Kolom 7',
    ),
    _Mohon(
      'Atestasi keluar',
      'Keluarga Lasut',
      'Diajukan 15/11/2026 · pindah ke Jemaat lain',
      'Lasut · Kolom 4',
    ),
    _Mohon(
      'Surat keterangan',
      'Agustina Lasut',
      'Dicatat Operator di kantor, 16/11/2026',
      'Wenas-Lasut · Kolom 7',
    ),
  ];
  final _riw = <String>[];
  var _v = _V.daftar;
  var _sel = 0;
  var _file = false;
  var _pesan = '';

  @override
  void dispose() {
    _no.dispose();
    _alasan.dispose();
    super.dispose();
  }

  /// The board's `ke(v, o)`: change view, clear `pesan`, jump to the top.
  void _ke(_V v, [VoidCallback? o]) {
    setState(() {
      _v = v;
      _pesan = '';
      o?.call();
    });
    _keAtas();
  }

  void _keAtas() => Scrollable.maybeOf(context)?.position.jumpTo(0);

  void _kosongkan() {
    _no.clear();
    _alasan.clear();
    _file = false;
  }

  /// First unmet cause of `ok` ("Terbitkan surat"), '' when met.
  String _alasanTerbit() => _no.text.trim().isEmpty
      ? 'nomor surat belum diisi.'
      : (!_file ? 'salinan bertanda tangan belum terlampir.' : '');

  String _alasanTolak() =>
      _alasan.text.trim().isEmpty ? 'alasan belum diisi.' : '';

  /// The board's `ubah`.
  void _ubah(String status, String ket, String teks) {
    setState(() {
      _p[_sel]
        ..status = status
        ..ket = ket;
      _v = _V.daftar;
      _pesan = teks;
      _riw.insert(
        0,
        '$_hariT · $teks Oleh Olvie Pangemanan, Sekretaris Jemaat.',
      );
      _kosongkan();
    });
    _keAtas();
  }

  void _terbit() {
    final p = _p[_sel], n = _no.text.trim();
    _ubah(
      'Diterbitkan',
      'No. $n · $_hariT · hanya anggota, keluarganya dan pelayan yang '
          'menaunginya yang melihat',
      '${p.jenis} ${p.nama} diterbitkan dengan No. $n.',
    );
  }

  void _tolak() {
    final p = _p[_sel], a = _alasan.text.trim();
    _ubah(
      'Tidak diterbitkan',
      'Alasan: $a',
      '${p.jenis} ${p.nama} tidak diterbitkan · alasan: $a.',
    );
  }

  static BentukLencana _bentuk(String status) => switch (status) {
    'Diajukan' => BentukLencana.garis,
    'Diterbitkan' => BentukLencana.tinta,
    _ => BentukLencana.bata,
  };

  Widget _kecil(String t) =>
      Text(t, style: TextStyle(fontSize: 13, color: context.warna.tinta3));

  static Widget _kolom(List<Widget> anak, double jarak) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < anak.length; i++) ...[
        if (i > 0) SizedBox(height: jarak),
        anak[i],
      ],
    ],
  );

  Widget _kepalaP() => KepalaKartu(
    judul: '${_p[_sel].jenis} · ${_p[_sel].nama}',
    ujung: const LencanaStatus('Diajukan', bentuk: BentukLencana.garis),
  );

  List<Widget> _daftar() => [
    if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
    for (final (i, r) in _p.indexed)
      Kartu(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: _kolom([
          KepalaKartu(
            judul: '${r.jenis} · ${r.nama}',
            ujung: LencanaStatus(r.status, bentuk: _bentuk(r.status)),
          ),
          _kecil(r.ket),
          if (r.status == 'Diajukan')
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Tombol(
                'Buka permohonan',
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.sedang,
                lebarPenuh: false,
                onPressed: () => _ke(_V.buka, () {
                  _sel = i;
                  _kosongkan();
                }),
              ),
            ),
        ], 6),
      ),
    _kecil(
      'Permohonan datang dari anggota, atau dicatat Operator di kantor untuk '
      'anggota tanpa ponsel.',
    ),
    if (_riw.isNotEmpty) RiwayatAlur(baris: _riw),
  ];

  List<Widget> _bukaKiri() {
    final p = _p[_sel];
    return [
      Kartu(
        child: _kolom([
          _kepalaP(),
          BarisInfo('Nama', p.nama),
          BarisInfo('Keluarga · Kolom', p.kel),
          const BarisInfo('Status', 'Aktif'),
          _kecil(
            'Diambil dari Data jemaat yang sudah Diverifikasi. Sekretaris '
            'Jemaat membaca, tidak mengubah.',
          ),
        ], 6),
      ),
      IsianAlur(
        label: 'Nomor surat',
        controller: _no,
        onChanged: (_) => setState(() {}),
        petunjuk: 'Contoh: 027/SKet/XI/2026',
        keterangan: 'Sesuai buku agenda surat keluar.',
      ),
    ];
  }

  List<Widget> _bukaKanan() {
    final alasan = _alasanTerbit();
    return [
      Kartu(
        status: GarisStatus.draf,
        child: _kolom([
          KepalaKartu(
            judul: 'Salinan bertanda tangan',
            ujung: _file
                ? const LencanaStatus('Terlampir', bentuk: BentukLencana.garis)
                : const LencanaStatus(
                    'Wajib, belum ada',
                    bentuk: BentukLencana.bata,
                  ),
          ),
          if (!_file) ...[
            _kecil(
              'Tanda tangan ada di dokumennya. Tidak ada persetujuan di '
              'aplikasi untuk dokumen gereja.',
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Tombol(
                'Pilih file',
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.sedang,
                lebarPenuh: false,
                onPressed: () => setState(() => _file = true),
              ),
            ),
          ] else
            _kecil('salinan-bertanda-tangan.pdf · 1 halaman'),
        ], 6),
      ),
      if ((_no.text.isNotEmpty || _file) && alasan.isNotEmpty)
        Penolakan(
          tindakan: 'Terbitkan surat',
          sebab: alasan,
          jalan: const [],
          ukuranTeks: 14,
        ),
      BarisTombol(
        anak: [
          TombolBersyarat(
            label: 'Terbitkan surat',
            tindakan: 'Terbitkan surat',
            alasan: alasan,
            periksa: _alasanTerbit,
            sudahMulai: false,
            onPressed: _terbit,
          ),
          Tombol(
            'Tidak diterbitkan',
            jenis: JenisTombol.kedua,
            ukuran: UkuranTombol.sedang,
            onPressed: () => _ke(_V.tolak),
          ),
          Tombol(
            'Kembali',
            jenis: JenisTombol.teks,
            ukuran: UkuranTombol.kecil,
            onPressed: () => _ke(_V.daftar),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buka() => widget.web
      ? [
          BarisLentur(
            jarak: 28,
            jarakBaris: 20,
            anak: [
              Lentur(dasar: 420, tumbuh: 1.3, child: _kolom(_bukaKiri(), 12)),
              Lentur(dasar: 340, child: _kolom(_bukaKanan(), 12)),
            ],
          ),
        ]
      : [..._bukaKiri(), ..._bukaKanan()];

  List<Widget> _tolakV() => [
    Kartu(
      child: _kolom([
        _kepalaP(),
        _kecil('Pemohon diberi tahu, dengan alasannya.'),
      ], 6),
    ),
    IsianAlur(
      label: 'Alasan · wajib',
      controller: _alasan,
      onChanged: (_) => setState(() {}),
      baris: 3,
    ),
    // The board's `sebab2` is `al && !al`: its refusal line never shows, so
    // (A02) the reason shows in that slot once the person has typed.
    if (_alasan.text.isNotEmpty && _alasanTolak().isNotEmpty)
      Penolakan(
        tindakan: 'Catat tidak diterbitkan',
        sebab: _alasanTolak(),
        jalan: const [],
        ukuranTeks: 14,
      ),
    BarisTombol(
      anak: [
        TombolBersyarat(
          label: 'Catat tidak diterbitkan',
          tindakan: 'Catat tidak diterbitkan',
          alasan: _alasanTolak(),
          periksa: _alasanTolak,
          sudahMulai: false,
          onPressed: _tolak,
        ),
        Tombol(
          'Kembali',
          jenis: JenisTombol.teks,
          ukuran: UkuranTombol.kecil,
          onPressed: () => _ke(_V.buka),
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) => _kolom(switch (_v) {
    _V.daftar => _daftar(),
    _V.buka => _buka(),
    _V.tolak => _tolakV(),
  }, 16);
}
