import 'package:flutter/material.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
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

/// 71 · Alur · Warta mingguan (spec 19). One flow object for the life of the
/// route; four views under one fixed header, no child routes.
class AlurWartaScreen extends StatefulWidget {
  const AlurWartaScreen({super.key});

  @override
  State<AlurWartaScreen> createState() => _AlurWartaScreenState();
}

/// One `U` entry: [judul, waktu-or-isi, penerima, status, masuk].
class _Umum {
  _Umum(this.j, this.s, this.p, this.status, this.masuk);
  final String j, s, p, status;
  bool masuk;
}

const _hariT = '16/11/2026';
const _hari = 20261116;
const _edisi = '22/11/2026';
const _pelaku = 'Olvie Pangemanan, Sekretaris Jemaat';
const _penerima = ['Semua anggota', 'Pelayan dan pengurus', 'Kolom 7'];

/// The board's `tgl`: exactly dd/mm/yyyy, month 1–12, day 1–31, as yyyymmdd.
int? _tgl(String t) {
  final m = RegExp(r'^(\d\d)/(\d\d)/(\d{4})$').firstMatch(t.trim());
  if (m == null) return null;
  final d = int.parse(m[1]!), b = int.parse(m[2]!);
  if (b < 1 || b > 12 || d < 1 || d > 31) return null;
  return int.parse(m[3]!) * 10000 + b * 100 + d;
}

class _AlurWartaScreenState extends State<AlurWartaScreen> {
  String _v = 'warta';
  String _st = 'Draf';
  String _pesan = '';
  final List<String> _riw = [];
  final List<_Umum> _u = [
    _Umum(
      'Kerja bakti halaman gereja',
      'Sabtu, 21/11/2026 pukul 07.00',
      'Semua anggota',
      'Diterbitkan',
      true,
    ),
    _Umum(
      'Rapat pelayan khusus',
      'Rabu, 25/11/2026 pukul 19.00',
      'Pelayan dan pengurus',
      'Diterbitkan',
      false,
    ),
  ];
  String _uUntuk = '';
  bool _nama = false;
  String _ralatTeks = '';
  final _uj = TextEditingController();
  final _ui = TextEditingController();
  final _uAkhir = TextEditingController();
  final _alasan = TextEditingController();
  final _ralat = TextEditingController();

  @override
  void dispose() {
    for (final c in [_uj, _ui, _uAkhir, _alasan, _ralat]) {
      c.dispose();
    }
    super.dispose();
  }

  void _catat(String t) => _riw.insert(0, '$_hariT · $t');

  void _ke(String v) => setState(() {
    _v = v;
    _pesan = '';
  });

  /// `aU`: the first unmet condition of the announcement's "Terbitkan".
  String _aU() {
    final akhir = _uAkhir.text;
    final ta = _tgl(akhir);
    if (_uj.text.trim().isEmpty) return 'judul belum diisi.';
    if (_ui.text.trim().isEmpty) return 'isi belum diisi.';
    if (_uUntuk.isEmpty) return 'penerima belum dipilih.';
    if (akhir.trim().isNotEmpty && ta == null) {
      return 'tanggal berakhir tidak dikenali. Contoh: 30/11/2026.';
    }
    if (akhir.trim().isNotEmpty && ta! <= _hari) {
      return 'tanggal berakhir harus setelah hari ini ($_hariT).';
    }
    return '';
  }

  String _aN() => _alasan.text.trim().isEmpty ? 'alasan belum diisi.' : '';
  String _aR() => _ralat.text.trim().isEmpty ? 'yang diralat belum diisi.' : '';

  void _simpan(String status) => setState(() {
    final j = _uj.text.trim(), p = _uUntuk;
    final masuk = status == 'Diterbitkan' && p == 'Semua anggota';
    final teks =
        'Pengumuman “$j” ${status == 'Draf' ? 'disimpan sebagai Draf; belum terlihat anggota.' : 'diterbitkan untuk $p${masuk ? ' dan dipilih masuk ke Warta edisi $_edisi.' : '. Belum dipilih masuk Warta; Anda dapat memilihnya di edisi ini.'}'}';
    _u.add(_Umum(j, _ui.text.trim(), p, status, masuk));
    _uj.clear();
    _ui.clear();
    _uAkhir.clear();
    _uUntuk = '';
    _v = 'warta';
    _pesan = teks;
    _catat(teks);
  });

  void _langkah(String st, String teks) => setState(() {
    _st = st;
    _pesan = '';
    _catat('$teks · $_pelaku');
  });

  void _balik(_Umum u) {
    if (_st != 'Draf') return;
    setState(() {
      final on = u.masuk;
      u.masuk = !on;
      _pesan = '';
      _catat(
        'Pengumuman “${u.j}” ${on ? 'dikeluarkan dari' : 'dipilih masuk ke'} edisi $_edisi · Olvie Pangemanan',
      );
    });
  }

  void _catatNama() => setState(() {
    final al = _alasan.text.trim();
    _v = 'warta';
    _nama = true;
    _alasan.clear();
    _pesan = 'Pengecualian tampilan nama tercatat; anggota diberi tahu. Edisi berikutnya kembali memakai “Tanpa nama”.';
    _catat(
      'Pengecualian tampilan nama · Kel. Mamahit — Kolom 4 · alasan: $al · $_pelaku',
    );
  });

  void _terbitRalat() => setState(() {
    final rl = _ralat.text.trim();
    _v = 'warta';
    _ralatTeks = rl;
    _ralat.clear();
    _pesan = '';
    _catat('Ralat edisi $_edisi diterbitkan sebagai revisi: $rl');
  });

  void _ubah(String _) => setState(() {});

  @override
  Widget build(BuildContext context) {
    final isi = switch (_v) {
      'umum' => _viewUmum(),
      'nama' => _viewNama(),
      'ralat' => _viewRalat(),
      _ => _viewWarta(),
    };
    return Material(
      type: MaterialType.transparency,
      child: LayarPonsel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const KepalaPonsel(
              judul: 'Alur · Warta mingguan',
              anakJudul: 'Dari pengumuman sampai edisi 22/11/2026 terbit',
              kembaliKe: 'WartaArsip',
              labelKembali: 'Kembali ke Warta Jemaat',
            ),
            Expanded(
              child: SingleChildScrollView(
                // A new view starts at the top (spec 19, shared rules).
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
      ),
    );
  }

  // ---- parts ----

  TextStyle get _keterangan =>
      TextStyle(fontSize: 13, color: context.warna.tinta3);
  TextStyle get _polos => TextStyle(fontSize: 14, color: context.warna.tinta2);

  Widget _kartu(List<Widget> anak) => Kartu(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, w) in anak.indexed) ...[
          if (i > 0) const SizedBox(height: 6),
          w,
        ],
      ],
    ),
  );

  Widget _kepala(String judul, String ket) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(judul, style: const TextStyle(fontWeight: FontWeight.w700)),
      Text(ket, style: _keterangan),
    ],
  );

  Widget _tinta(String label, VoidCallback onTap) =>
      Tombol(label, onPressed: onTap, jenis: JenisTombol.tinta);
  Widget _teks(String label, VoidCallback onTap) => Tombol(
    label,
    onPressed: onTap,
    jenis: JenisTombol.teks,
    ukuran: UkuranTombol.kecil,
  );
  Widget _teksAwal(String label, VoidCallback onTap) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: Tombol(
      label,
      onPressed: onTap,
      jenis: JenisTombol.teks,
      ukuran: UkuranTombol.kecil,
      lebarPenuh: false,
    ),
  );
  Widget _kedua(String label, VoidCallback onTap) => Tombol(
    label,
    onPressed: onTap,
    jenis: JenisTombol.kedua,
    ukuran: UkuranTombol.sedang,
  );

  Widget _lencana(String label, BentukLencana b) =>
      LencanaStatus(label, bentuk: b);

  Widget _kuat(String awal, String kuat) => Text.rich(
    TextSpan(
      children: [
        TextSpan(text: awal),
        TextSpan(
          text: kuat,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: context.warna.tinta,
          ),
        ),
      ],
    ),
    style: _polos,
  );

  Widget _barisUmum(_Umum u) {
    final c = context.warna;
    final on = u.masuk;
    final label = on ? 'Masuk edisi ini' : 'Tidak masuk';
    final teks = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${u.j} · ${u.s}',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        Text(
          'Ditujukan untuk: ${u.p}${on && u.p != 'Semua anggota' ? ' · perhatikan: Warta dibaca semua anggota' : ''}',
          style: _keterangan,
        ),
      ],
    );
    // CSS wrap: text `flex: 1 1 180px`, chip `flex: none` (its label + padding
    // 0 14 + the 1.5 line on both sides).
    final lebarChip =
        _lebar(
          label,
          const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ) +
        31;
    return Container(
      padding: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.garis)),
      ),
      child: BarisLentur(
        jarak: 12,
        jarakBaris: 6,
        rata: CrossAxisAlignment.center,
        anak: [
          Lentur(dasar: 180, child: teks),
          Lentur(
            dasar: lebarChip,
            tumbuh: 0,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: ChipSatu(teks: label, dipilih: on, onTap: () => _balik(u)),
            ),
          ),
        ],
      ),
    );
  }

  /// Laid-out width of [t] in the body font (CSS max-content).
  double _lebar(String t, TextStyle gaya) => (TextPainter(
    text: TextSpan(
      text: t,
      style: const TextStyle(
        fontFamily: PalakatText.sans,
        fontSize: 16,
      ).merge(gaya),
    ),
    textDirection: TextDirection.ltr,
    textScaler: MediaQuery.textScalerOf(context),
  )..layout()).width;

  /// The board's key–value row with CSS `flex-shrink: 1` on both spans: when
  /// they do not fit, each shrinks in proportion to its own width (the
  /// shared BarisInfo keeps the label rigid; see sharedNeeds).
  Widget _info(String label, String nilai, {bool mono = false}) {
    final c = context.warna;
    final gl = TextStyle(fontSize: 14, color: c.tinta2);
    final gn = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: c.tinta,
      fontFamily: mono ? PalakatText.mono : null,
    );
    int lentur(double w) => (w * 10).ceil().clamp(1, 1 << 30);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: lentur(_lebar(label, gl)),
          child: Text(label, style: gl),
        ),
        const SizedBox(width: 16),
        Flexible(
          flex: lentur(_lebar(nilai, gn)),
          child: Text(nilai, textAlign: TextAlign.right, style: gn),
        ),
      ],
    );
  }

  // ---- views ----

  List<Widget> _viewWarta() {
    final stDraf = _st == 'Draf';
    final bentuk = switch (_st) {
      'Sudah diperiksa' => BentukLencana.lautGaris,
      'Disetujui' => BentukLencana.laut,
      'Diterbitkan' => BentukLencana.tinta,
      _ => BentukLencana.draf,
    };
    return [
      KepalaKartu(judul: 'Edisi $_edisi', ujung: _lencana(_st, bentuk)),
      if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
      _kartu([
        _kepala(
          'Pengumuman',
          'Sekretaris Jemaat memilih dari pengumuman yang Diterbitkan',
        ),
        for (final u in _u)
          if (u.status == 'Diterbitkan') _barisUmum(u),
        if (stDraf) _teksAwal('Tulis pengumuman', () => _ke('umum')),
      ]),
      _kartu([
        _kepala(
          'Peristiwa jemaat',
          'hanya yang Diverifikasi; nama mengikuti Tampilan nama',
        ),
        _kuat('Syukur HUT pernikahan: ', 'Keluarga Wenas-Lasut — Kolom 7'),
        _kuat(
          'Sampul syukur: ',
          _nama
              ? 'Kel. Mamahit — Kolom 4 (pengecualian tercatat)'
              : 'Tanpa nama, Kolom 4',
        ),
        if (stDraf && !_nama)
          _teksAwal('Tampilkan nama (pengecualian)', () => _ke('nama')),
        Text(
          'Tidak masuk: Baptisan · Gabriel Wenas, masih Diajukan.',
          style: _keterangan,
        ),
      ]),
      _kartu([
        _kepala('Ringkasan keuangan', 'dari bulan yang Sudah ditutup'),
        _info('Pendapatan Oktober 2026', 'Rp14.820.000', mono: true),
        _info('Belanja Oktober 2026', 'Rp11.455.000', mono: true),
      ]),
      if (stDraf)
        BarisTombol(
          anak: [
            _tinta(
              'Tandai sudah diperiksa',
              () => _langkah(
                'Sudah diperiksa',
                'Edisi $_edisi ditandai Sudah diperiksa',
              ),
            ),
          ],
        ),
      if (_st == 'Sudah diperiksa')
        BarisTombol(
          anak: [
            _tinta(
              'Setujui untuk diterbitkan',
              () => _langkah(
                'Disetujui',
                'Edisi $_edisi Disetujui untuk diterbitkan',
              ),
            ),
            _teks('Kembali ke Draf', _keDraf),
          ],
        ),
      if (_st == 'Disetujui')
        BarisTombol(
          anak: [
            Tombol(
              'Terbitkan',
              jenis: JenisTombol.utama,
              onPressed: () => _langkah(
                'Diterbitkan',
                'Edisi $_edisi Diterbitkan untuk semua anggota',
              ),
            ),
            _teks('Kembali ke Draf', _keDraf),
          ],
        ),
      if (_st == 'Diterbitkan') ...[
        Text(
          'Diterbitkan untuk semua anggota. Edisi ini tidak berubah lagi; ralat menjadi revisi yang tertaut.',
          style: _polos,
        ),
        BarisTombol(
          anak: [
            _kedua(
              'Buat ralat',
              () => setState(() {
                _v = 'ralat';
                _ralat.clear();
                _pesan = '';
              }),
            ),
          ],
        ),
      ],
      if (_st == 'Sudah diperiksa' || _st == 'Disetujui')
        Text(
          'Untuk mengubah isinya, kembalikan edisi ke Draf lebih dulu.',
          style: _keterangan,
        ),
      if (_ralatTeks.isNotEmpty)
        _kartu([
          KepalaKartu(
            judul: 'Ralat (revisi edisi $_edisi)',
            ujung: _lencana('Diterbitkan', BentukLencana.tinta),
          ),
          Text(_ralatTeks, style: _polos),
          Text(
            'Tertaut ke edisi asli, yang tetap tampil apa adanya.',
            style: _keterangan,
          ),
        ]),
      if (_riw.isNotEmpty) RiwayatAlur(baris: List.of(_riw)),
    ];
  }

  void _keDraf() => _langkah('Draf', 'Edisi $_edisi dikembalikan ke Draf');

  List<Widget> _viewUmum() {
    final aU = _aU();
    final mulai =
        _uj.text.isNotEmpty ||
        _ui.text.isNotEmpty ||
        _uUntuk.isNotEmpty ||
        _uAkhir.text.isNotEmpty;
    return [
      IsianAlur(
        label: 'Judul',
        controller: _uj,
        onChanged: _ubah,
        petunjuk: 'Judul pengumuman',
      ),
      IsianAlur(label: 'Isi', controller: _ui, onChanged: _ubah, baris: 3),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ditujukan untuk', style: _polos),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final n in _penerima)
                ChipSatu(
                  teks: n,
                  dipilih: _uUntuk == n,
                  onTap: () => setState(() {
                    _uUntuk = n;
                    _pesan = '';
                  }),
                ),
            ],
          ),
        ],
      ),
      IsianAlur(
        label: 'Berakhir pada',
        controller: _uAkhir,
        onChanged: _ubah,
        petunjuk: 'hh/bb/tttt',
        keterangan:
            'Boleh kosong. Setelah tanggal ini pengumuman diarsipkan sendiri.',
      ),
      Text(
        'Hanya Sekretaris Jemaat yang menerbitkan. Sekretaris Jemaat juga yang memilih pengumuman mana yang masuk ke tiap edisi Warta.',
        style: _keterangan,
      ),
      if (mulai && aU.isNotEmpty)
        Penolakan(
          tindakan: 'Terbitkan',
          sebab: aU,
          jalan: const [],
          ukuranTeks: 14,
        ),
      BarisTombol(
        anak: [
          TombolBersyarat(
            label: 'Terbitkan',
            tindakan: 'Terbitkan',
            alasan: aU,
            periksa: _aU,
            sudahMulai: false,
            onPressed: () => _simpan('Diterbitkan'),
          ),
          _kedua('Simpan sebagai draf', () => _simpan('Draf')),
          _teks('Batalkan', () => _ke('warta')),
        ],
      ),
    ];
  }

  List<Widget> _viewNama() => [
    _kartu([
      _info('Edisi', 'Warta Jemaat 22/11/2026'),
      _info('Pilihan anggota', 'Tanpa nama'),
      _info('Akan diterbitkan sebagai', 'Kel. Mamahit — Kolom 4'),
      Text(
        'Tampilan nama pilihan anggota wajib diikuti. Pengecualian hanya untuk keperluan resmi, tata kelola, hukum atau pertanggungjawaban.',
        style: _keterangan,
      ),
    ]),
    IsianAlur(
      label: 'Alasan · wajib',
      controller: _alasan,
      onChanged: _ubah,
      baris: 3,
    ),
    // sebabN is `al && !al` on the board: the refusal line never shows.
    BarisTombol(
      anak: [
        TombolBersyarat(
          label: 'Catat pengecualian',
          tindakan: 'Catat pengecualian',
          alasan: _aN(),
          periksa: _aN,
          sudahMulai: false,
          onPressed: _catatNama,
        ),
        _teks('Batalkan', () => _ke('warta')),
      ],
    ),
  ];

  List<Widget> _viewRalat() => [
    _kartu([
      KepalaKartu(
        judul: 'Warta Jemaat · edisi $_edisi',
        ujung: _lencana('Diterbitkan', BentukLencana.tinta),
      ),
      Text(
        'Edisi asli tidak diubah. Ralat diterbitkan sebagai revisi yang tertaut.',
        style: _keterangan,
      ),
    ]),
    IsianAlur(
      label: 'Yang diralat · wajib',
      controller: _ralat,
      onChanged: _ubah,
      baris: 3,
    ),
    // sebabR is `rl && !rl` on the board: the refusal line never shows.
    BarisTombol(
      anak: [
        TombolBersyarat(
          label: 'Terbitkan ralat',
          tindakan: 'Terbitkan ralat',
          alasan: _aR(),
          periksa: _aR,
          sudahMulai: false,
          onPressed: _terbitRalat,
        ),
        _teks('Batalkan', () => _ke('warta')),
      ],
    ),
  ];
}
