import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../mock/format.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/riwayat_alur.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';

const _hari = '16/11/2026';
const _hariAngka = 20261116;
const _kolom = 'Ibadah Kolom 7';
const _seluruh = 'Ibadah seluruh Jemaat';
const _diperiksa = 'Sudah diperiksa';
const _ditetapkan = 'Ditetapkan';
const _ditutup = 'Ditutup';

/// Digits rule without separators: digits only, leading zeros dropped (a lone
/// "0" stays), at most 11.
final _angka = TextInputFormatter.withFunction((_, baru) {
  final t = hanyaAngka(baru.text, simpanNol: true);
  return TextEditingValue(
    text: t,
    selection: TextSelection.collapsed(offset: t.length),
  );
});

/// The board's `tgl(t)`: yyyymmdd, or null when not exactly dd/mm/yyyy.
int? _bacaTanggal(String t) {
  final m = RegExp(r'^(\d\d)/(\d\d)/(\d{4})$').firstMatch(t.trim());
  if (m == null) return null;
  final d = int.parse(m[1]!), b = int.parse(m[2]!);
  if (b < 1 || b > 12 || d < 1 || d > 31) return null;
  return int.parse(m[3]!) * 10000 + b * 100 + d;
}

/// 96 · Alur · Ibadah dan kehadiran (screens/23-alurunit.md, AlurIbadah).
class AlurIbadahScreen extends StatefulWidget {
  const AlurIbadahScreen({super.key});

  @override
  State<AlurIbadahScreen> createState() => _AlurIbadahScreenState();
}

class _AlurIbadahScreenState extends State<AlurIbadahScreen> {
  final _gulir = ScrollController();
  final _tgl = TextEditingController();
  final _jam = TextEditingController();
  final _tempat = TextEditingController();
  final _l = TextEditingController();
  final _p = TextEditingController();
  final _a = TextEditingController();
  final _kor = TextEditingController();
  final _alasan = TextEditingController();

  String _v = 'jadwal', _jenis = '', _st = '', _hst = '';
  String? _korSah;
  final List<String> _riw = [];

  @override
  void dispose() {
    for (final c in [_gulir, _tgl, _jam, _tempat, _l, _p, _a, _kor, _alasan]) {
      c.dispose();
    }
    super.dispose();
  }

  int _n(TextEditingController c) => int.tryParse(c.text) ?? 0;

  int get _total =>
      _korSah != null ? int.parse(_korSah!) : _n(_l) + _n(_p) + _n(_a);

  String _sebab() {
    final t = _bacaTanggal(_tgl.text);
    if (_jenis.isEmpty) return 'ibadah belum dipilih.';
    if (_jenis == _seluruh) {
      return 'ibadah seluruh Jemaat dijadwalkan Sekretaris Jemaat dan '
          'disetujui Ketua Jemaat.';
    }
    if (t == null) return 'tanggal tidak dikenali. Contoh: 19/11/2026.';
    if (t < _hariAngka) return 'tanggal sudah lewat.';
    if (!RegExp(r'^([01]\d|2[0-3])\.[0-5]\d$').hasMatch(_jam.text.trim())) {
      return 'jam tidak dikenali. Contoh: 19.00.';
    }
    if (_tempat.text.trim().isEmpty) return 'tempat belum diisi.';
    return '';
  }

  String _sebabHitung() => _total > 0 ? '' : 'jumlah kehadiran masih nol.';

  String _sebabKoreksi() => !(_n(_kor) > 0)
      ? 'jumlah yang benar belum diisi.'
      : (_alasan.text.trim().isEmpty ? 'alasan belum diisi.' : '');

  void _ubah(VoidCallback f) => setState(f);

  void _ke(String v, [VoidCallback? lagi]) {
    setState(() {
      _v = v;
      lagi?.call();
    });
    if (_gulir.hasClients) _gulir.jumpTo(0);
  }

  void _catat(String t) => _riw.insert(0, '$_hari · $t');

  void _jadwalkan() => _ubah(() {
    _st = 'Dijadwalkan';
    _catat(
      '$_jenis ${_tgl.text.trim()} ${_jam.text.trim()} dijadwalkan · '
      'Disetujui oleh Pnt. Hendrik Rumagit',
    );
  });

  void _periksa() => _ubah(() {
    _catat('Jumlah kehadiran $_total orang ditandai Sudah diperiksa');
    _hst = _diperiksa;
  });

  void _tetapkan() => _ubah(() {
    _catat('Jumlah kehadiran Ditetapkan: $_total orang · Pnt. Hendrik Rumagit');
    _hst = _ditetapkan;
    _st = _ditutup;
  });

  void _koreksi() {
    final al = _alasan.text.trim();
    _ke('hitung', () {
      _catat(
        'Koreksi jumlah kehadiran: $_total menjadi ${_kor.text} orang · '
        'alasan: $al',
      );
      _korSah = _kor.text;
      _alasan.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final judul = _jenis.isEmpty ? _kolom : _jenis;
    final kapan =
        '${_tgl.text.trim()} · ${_jam.text.trim()} · ${_tempat.text.trim()}';
    final kecil = TextStyle(fontSize: 13, color: c.tinta3);
    void ketik(String _) => setState(() {});

    Widget kembali(String label, VoidCallback f) => Tombol(
      label,
      jenis: JenisTombol.teks,
      ukuran: UkuranTombol.kecil,
      onPressed: f,
    );

    Widget kartu(String badge, BentukLencana bentuk, List<Widget> bawah) =>
        Kartu(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 6,
            children: [
              KepalaKartu(
                judul: judul,
                ujung: LencanaStatus(badge, bentuk: bentuk),
              ),
              Text(kapan, style: TextStyle(fontSize: 14, color: c.tinta2)),
              ...bawah,
            ],
          ),
        );

    final jadwal = <Widget>[
      if (_st.isEmpty) ...[
        ChipPilihan<String>(
          label: 'Ibadah',
          jarakLabel: 6,
          jarakBaris: 0,
          pilihan: const [
            (nilai: _kolom, teks: _kolom),
            (nilai: _seluruh, teks: _seluruh),
          ],
          terpilih: _jenis.isEmpty ? null : _jenis,
          onPilih: (j) => _ubah(() => _jenis = j),
        ),
        IsianAlur(
          label: 'Tanggal',
          controller: _tgl,
          petunjuk: 'hh/bb/tttt',
          keterangan: 'Hari ini atau sesudahnya.',
          onChanged: ketik,
        ),
        IsianAlur(
          label: 'Jam',
          controller: _jam,
          petunjuk: 'jj.mm',
          keterangan: 'Contoh: 19.00',
          onChanged: ketik,
        ),
        IsianAlur(
          label: 'Tempat',
          controller: _tempat,
          petunjuk: 'Contoh: rumah Kel. Wenas-Lasut',
          onChanged: ketik,
        ),
        if ((_jenis.isNotEmpty ||
                _tgl.text.isNotEmpty ||
                _jam.text.isNotEmpty ||
                _tempat.text.isNotEmpty) &&
            _sebab().isNotEmpty)
          Penolakan(
            tindakan: 'Jadwalkan',
            sebab: _sebab(),
            jalan: const [],
            ukuranTeks: 14,
          ),
        BarisTombol(
          anak: [
            TombolBersyarat(
              label: 'Jadwalkan',
              tindakan: 'Jadwalkan',
              alasan: _sebab(),
              periksa: _sebab,
              sudahMulai: false,
              onPressed: _jadwalkan,
            ),
          ],
        ),
      ] else ...[
        kartu(
          _st,
          _st == _ditutup ? BentukLencana.tinta : BentukLencana.lautGaris,
          [
            Text(
              _st == _ditutup
                  ? 'Jumlah kehadiran Ditetapkan: $_total orang.'
                  : 'Disetujui oleh Pnt. Hendrik Rumagit, Penatua Kolom 7. '
                        'Masuk ke Warta Jemaat bila ditujukan untuk semua '
                        'anggota.',
              style: kecil,
            ),
          ],
        ),
        if (_st == 'Dijadwalkan')
          BarisTombol(
            anak: [
              Tombol(
                'Catat jumlah kehadiran',
                jenis: JenisTombol.tinta,
                onPressed: () => _ke('hitung'),
              ),
            ],
          ),
      ],
    ];

    final hitung = <Widget>[
      kartu(
        _hst.isEmpty ? 'Sedang dihitung' : _hst,
        _hst == _ditetapkan
            ? BentukLencana.tinta
            : (_hst == _diperiksa
                  ? BentukLencana.lautGaris
                  : BentukLencana.draf),
        const [],
      ),
      if (_hst.isEmpty)
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            for (final (label, ctl) in [
              ('Laki-laki', _l),
              ('Perempuan', _p),
              ('Anak', _a),
            ])
              IsianAlur(
                label: label,
                controller: ctl,
                petunjuk: '0',
                keyboard: TextInputType.number,
                formatter: [_angka],
                onChanged: ketik,
              ),
          ],
        ),
      Kartu(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 6,
          children: [
            KepalaKartu(
              judul: 'Jumlah kehadiran',
              ujung: Text(
                '$_total',
                style: const TextStyle(
                  fontFamily: PalakatText.mono,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              'Jumlah saja. Tidak ada nama, tidak ada daftar yang tidak hadir.',
              style: kecil,
            ),
          ],
        ),
      ),
      if (_hst.isEmpty) ...[
        if ((_l.text.isNotEmpty || _p.text.isNotEmpty || _a.text.isNotEmpty) &&
            _total <= 0)
          const Penolakan(
            tindakan: 'Tandai sudah diperiksa',
            sebab: 'jumlah kehadiran masih nol.',
            jalan: [],
            ukuranTeks: 14,
          ),
        BarisTombol(
          anak: [
            TombolBersyarat(
              label: 'Tandai sudah diperiksa',
              tindakan: 'Tandai sudah diperiksa',
              alasan: _sebabHitung(),
              periksa: _sebabHitung,
              sudahMulai: false,
              onPressed: _periksa,
            ),
            kembali('Kembali', () => _ke('jadwal')),
          ],
        ),
      ],
      if (_hst == _diperiksa)
        BarisTombol(
          anak: [
            Tombol('Tetapkan', jenis: JenisTombol.tinta, onPressed: _tetapkan),
            kembali('Ubah angka', () => _ubah(() => _hst = '')),
          ],
        ),
      if (_hst == _ditetapkan) ...[
        Text(
          'Angka yang Ditetapkan tidak diubah; perbaikan dicatat sebagai '
          'koreksi dengan alasan.',
          style: kecil,
        ),
        BarisTombol(
          anak: [
            Tombol(
              'Koreksi',
              jenis: JenisTombol.kedua,
              ukuran: UkuranTombol.sedang,
              onPressed: () => _ke('koreksi', () {
                _kor.clear();
                _alasan.clear();
              }),
            ),
            kembali('Kembali', () => _ke('jadwal')),
          ],
        ),
      ],
    ];

    final sebabK = _sebabKoreksi();
    final koreksi = <Widget>[
      Kartu(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 6,
          children: [
            const KepalaKartu(
              judul: 'Koreksi jumlah kehadiran',
              ujung: LencanaStatus(_ditetapkan, bentuk: BentukLencana.tinta),
            ),
            BarisInfo('Angka sekarang', '$_total', mono: true),
          ],
        ),
      ),
      IsianAlur(
        label: 'Jumlah yang benar',
        controller: _kor,
        petunjuk: '0',
        keyboard: TextInputType.number,
        formatter: [_angka],
        onChanged: ketik,
      ),
      IsianAlur(
        label: 'Alasan · wajib',
        controller: _alasan,
        baris: 3,
        onChanged: ketik,
      ),
      if ((_kor.text.isNotEmpty || _alasan.text.trim().isNotEmpty) &&
          sebabK.isNotEmpty)
        Penolakan(
          tindakan: 'Catat koreksi',
          sebab: sebabK,
          jalan: const [],
          ukuranTeks: 14,
        ),
      BarisTombol(
        anak: [
          TombolBersyarat(
            label: 'Catat koreksi',
            tindakan: 'Catat koreksi',
            alasan: sebabK,
            periksa: _sebabKoreksi,
            sudahMulai: false,
            onPressed: _koreksi,
          ),
          kembali('Batal', () => _ke('hitung')),
        ],
      ),
    ];

    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Alur · Ibadah dan kehadiran',
            anakJudul: 'Dari menjadwalkan sampai Jumlah kehadiran Ditetapkan',
            kembaliKe: 'Ibadah',
            labelKembali: 'Kembali ke Ibadah dan kegiatan',
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _gulir,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  ...switch (_v) {
                    'hitung' => hitung,
                    'koreksi' => koreksi,
                    _ => jadwal,
                  },
                  if (_riw.isNotEmpty) RiwayatAlur(baris: _riw),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
