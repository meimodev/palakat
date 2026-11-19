import 'package:flutter/material.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
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

/// One entry of the board's `U`: [judul, waktu-or-isi, penerima, status, masuk].
class _Umum {
  _Umum(this.judul, this.isi, this.untuk, this.status, this.masuk);
  final String judul, isi, untuk, status;
  bool masuk;
}

const _hariT = '16/11/2026';
const _hari = 20261116;
const _aktor = ' · Olvie Pangemanan, Sekretaris Jemaat';
const _untukPil = ['Semua anggota', 'Pelayan dan pengurus', 'Kolom 7'];

/// The board's `tgl`: exactly dd/mm/yyyy, month 1–12, day 1–31, as yyyymmdd.
int? _tgl(String t) {
  final m = RegExp(r'^(\d\d)/(\d\d)/(\d{4})$').firstMatch(t.trim());
  if (m == null) return null;
  final d = int.parse(m[1]!), b = int.parse(m[2]!);
  if (b < 1 || b > 12 || d < 1 || d > 31) return null;
  return int.parse(m[3]!) * 10000 + b * 100 + d;
}

class WebAlurWartaScreen extends StatefulWidget {
  const WebAlurWartaScreen({super.key});

  @override
  State<WebAlurWartaScreen> createState() => _WebAlurWartaScreenState();
}

class _WebAlurWartaScreenState extends State<WebAlurWartaScreen> {
  final _atas = GlobalKey();
  final _uj = TextEditingController(),
      _ui = TextEditingController(),
      _uAkhir = TextEditingController(),
      _alasan = TextEditingController(),
      _ralat = TextEditingController();

  String _pesan = '', _v = 'warta', _st = 'Draf', _uUntuk = '', _ralatTeks = '';
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
  bool _nama = false;

  @override
  void dispose() {
    for (final c in [_uj, _ui, _uAkhir, _alasan, _ralat]) {
      c.dispose();
    }
    super.dispose();
  }

  void _catat(String t) => _riw.insert(0, '$_hariT · $t');

  void _ke(String v) => setState(() {
    if (v == 'ralat') _ralat.clear();
    _v = v;
    _pesan = '';
    _keAtas();
  });

  /// Scroll jumps to the top on every view change (shared rule of spec 19).
  void _keAtas() => WidgetsBinding.instance.addPostFrameCallback((_) {
    final ctx = _atas.currentContext;
    if (ctx != null) Scrollable.maybeOf(ctx)?.position.jumpTo(0);
  });

  void _langkah(String st, String teks) => setState(() {
    _st = st;
    _pesan = '';
    _catat('$teks$_aktor');
  });

  String _sebabU() {
    final ta = _tgl(_uAkhir.text);
    if (_uj.text.trim().isEmpty) return 'judul belum diisi.';
    if (_ui.text.trim().isEmpty) return 'isi belum diisi.';
    if (_uUntuk.isEmpty) return 'penerima belum dipilih.';
    if (_uAkhir.text.trim().isNotEmpty && ta == null) {
      return 'tanggal berakhir tidak dikenali. Contoh: 30/11/2026.';
    }
    if (_uAkhir.text.trim().isNotEmpty && ta! <= _hari) {
      return 'tanggal berakhir harus setelah hari ini ($_hariT).';
    }
    return '';
  }

  String _sebabN() => _alasan.text.trim().isEmpty ? 'Alasan belum diisi.' : '';
  String _sebabR() =>
      _ralat.text.trim().isEmpty ? 'Yang diralat belum diisi.' : '';

  void _simpan(String status) => setState(() {
    final j = _uj.text.trim(), p = _uUntuk;
    final masuk = status == 'Diterbitkan' && p == 'Semua anggota';
    final teks =
        'Pengumuman “$j” ${status == 'Draf' ? 'disimpan sebagai Draf; belum terlihat anggota.' : 'diterbitkan untuk $p${masuk ? ' dan dipilih masuk ke Warta edisi 22/11/2026.' : '. Belum dipilih masuk Warta; Anda dapat memilihnya di edisi ini.'}'}';
    _u.add(_Umum(j, _ui.text.trim(), p, status, masuk));
    for (final c in [_uj, _ui, _uAkhir]) {
      c.clear();
    }
    _uUntuk = '';
    _v = 'warta';
    _pesan = teks;
    _catat(teks);
    _keAtas();
  });

  void _catatNama() => setState(() {
    final a = _alasan.text.trim();
    _v = 'warta';
    _nama = true;
    _alasan.clear();
    _pesan = 'Pengecualian tampilan nama tercatat; anggota diberi tahu. Edisi berikutnya kembali memakai “Tanpa nama”.';
    _catat(
      'Pengecualian tampilan nama · Kel. Mamahit — Kolom 4 · alasan: $a$_aktor',
    );
    _keAtas();
  });

  void _terbitRalat() => setState(() {
    final r = _ralat.text.trim();
    _v = 'warta';
    _ralatTeks = r;
    _ralat.clear();
    _pesan = '';
    _catat('Ralat edisi 22/11/2026 diterbitkan sebagai revisi: $r');
    _keAtas();
  });

  void _balik(_Umum u) {
    if (_st != 'Draf') return;
    setState(() {
      final on = u.masuk;
      u.masuk = !on;
      _pesan = '';
      _catat(
        'Pengumuman “${u.judul}” ${on ? 'dikeluarkan dari' : 'dipilih masuk ke'} edisi 22/11/2026 · Olvie Pangemanan',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final tampilan = switch (_v) {
      'umum' => _viewUmum(c),
      'nama' => _viewNama(c),
      'ralat' => _viewRalat(c),
      _ => _viewWarta(c),
    };
    return HalamanWeb(
      nav: const NavSamping(
        item: navPlatform,
        aktif: 4,
        pengguna: PenggunaNav(
          tebal: 'Olvie Pangemanan',
          biasa: ' · Sekretaris Jemaat',
        ),
      ),
      isi: [
        Column(
          key: _atas,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Inline link: the 44 target hangs below the 14/1.45 line.
            MarginNegatif(
              bawah: 44 - 14 * 1.45,
              child: Tautan(
                ke: 'WebWartaArsip',
                cara: Cara.naik,
                child: const TautanTeks('Warta Jemaat', ukuran: 14),
              ),
            ),
            const SizedBox(height: 2),
            Semantics(
              header: true,
              child: Text(
                'Alur · Warta mingguan',
                style: PalakatText.judulHalaman.copyWith(color: c.tinta),
              ),
            ),
            Text(
              'Dari pengumuman sampai edisi 22/11/2026 terbit',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ],
        ),
        Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: _kolom(tampilan),
          ),
        ),
      ],
    );
  }

  /// A column with the board's gap between every child.
  static Widget _kolom(List<Widget> anak, [double jarak = 16]) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < anak.length; i++) ...[
        if (i > 0) SizedBox(height: jarak),
        anak[i],
      ],
    ],
  );

  /// `flex-wrap: wrap; gap: 20px 28px`, left 1.3 1 420, right 1 1 340.
  static Widget _duaKolom(List<Widget> kiri, List<Widget> kanan) => BarisLentur(
    jarak: 28,
    jarakBaris: 20,
    anak: [
      Lentur(dasar: 420, tumbuh: 1.3, child: _kolom(kiri, 12)),
      Lentur(dasar: 340, child: _kolom(kanan, 12)),
    ],
  );

  static Widget _kepala(PalakatWarna c, String judul, String ket) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(judul, style: const TextStyle(fontWeight: FontWeight.w700)),
      Text(ket, style: TextStyle(fontSize: 13, color: c.tinta3)),
    ],
  );

  static Widget _kartu(List<Widget> anak) => Kartu(child: _kolom(anak, 6));

  static Widget _teksBtn(String l, VoidCallback f) => Tombol(
    l,
    onPressed: f,
    jenis: JenisTombol.teks,
    ukuran: UkuranTombol.kecil,
  );

  static Widget _diterbitkan() =>
      const LencanaStatus('Diterbitkan', bentuk: BentukLencana.tinta);

  List<Widget> _viewWarta(PalakatWarna c) {
    final kecil = TextStyle(fontSize: 13, color: c.tinta3);
    final baris14 = TextStyle(fontSize: 14, color: c.tinta2);
    final tebal = TextStyle(fontWeight: FontWeight.w700, color: c.tinta);
    final draf = _st == 'Draf';
    final kiri = [
      _kartu([
        _kepala(
          c,
          'Pengumuman',
          'Sekretaris Jemaat memilih dari pengumuman yang Diterbitkan',
        ),
        for (final u in _u.where((u) => u.status == 'Diterbitkan'))
          _BarisUmum(u: u, onTap: () => _balik(u)),
        if (draf)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Tombol(
              'Tulis pengumuman',
              onPressed: () => _ke('umum'),
              jenis: JenisTombol.teks,
              ukuran: UkuranTombol.kecil,
              lebarPenuh: false,
            ),
          ),
      ]),
      _kartu([
        _kepala(
          c,
          'Peristiwa jemaat',
          'hanya yang Diverifikasi; nama mengikuti Tampilan nama',
        ),
        Text.rich(
          TextSpan(
            text: 'Syukur HUT pernikahan: ',
            children: [
              TextSpan(text: 'Keluarga Wenas-Lasut — Kolom 7', style: tebal),
            ],
          ),
          style: baris14,
        ),
        Text.rich(
          TextSpan(
            text: 'Sampul syukur: ',
            children: [
              TextSpan(
                text: _nama
                    ? 'Kel. Mamahit — Kolom 4 (pengecualian tercatat)'
                    : 'Tanpa nama, Kolom 4',
                style: tebal,
              ),
            ],
          ),
          style: baris14,
        ),
        if (draf && !_nama)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Tombol(
              'Tampilkan nama (pengecualian)',
              onPressed: () => _ke('nama'),
              jenis: JenisTombol.teks,
              ukuran: UkuranTombol.kecil,
              lebarPenuh: false,
            ),
          ),
        Text(
          'Tidak masuk: Baptisan · Gabriel Wenas, masih Diajukan.',
          style: kecil,
        ),
      ]),
      _kartu([
        _kepala(c, 'Ringkasan keuangan', 'dari bulan yang Sudah ditutup'),
        const _Info('Pendapatan Oktober 2026', 'Rp14.820.000', mono: true),
        const _Info('Belanja Oktober 2026', 'Rp11.455.000', mono: true),
      ]),
    ];
    final keDraf = _teksBtn(
      'Kembali ke Draf',
      () => _langkah('Draf', 'Edisi 22/11/2026 dikembalikan ke Draf'),
    );
    final kanan = [
      if (draf)
        BarisTombol(
          anak: [
            Tombol(
              'Tandai sudah diperiksa',
              onPressed: () => _langkah(
                'Sudah diperiksa',
                'Edisi 22/11/2026 ditandai Sudah diperiksa',
              ),
              jenis: JenisTombol.tinta,
            ),
          ],
        ),
      if (_st == 'Sudah diperiksa')
        BarisTombol(
          anak: [
            Tombol(
              'Setujui untuk diterbitkan',
              onPressed: () => _langkah(
                'Disetujui',
                'Edisi 22/11/2026 Disetujui untuk diterbitkan',
              ),
              jenis: JenisTombol.tinta,
            ),
            keDraf,
          ],
        ),
      if (_st == 'Disetujui')
        BarisTombol(
          anak: [
            Tombol(
              'Terbitkan',
              onPressed: () => _langkah(
                'Diterbitkan',
                'Edisi 22/11/2026 Diterbitkan untuk semua anggota',
              ),
            ),
            keDraf,
          ],
        ),
      if (_st == 'Diterbitkan') ...[
        Text(
          'Diterbitkan untuk semua anggota. Edisi ini tidak berubah lagi; ralat menjadi revisi yang tertaut.',
          style: baris14,
        ),
        BarisTombol(
          anak: [
            Tombol(
              'Buat ralat',
              onPressed: () => _ke('ralat'),
              jenis: JenisTombol.kedua,
              ukuran: UkuranTombol.sedang,
            ),
          ],
        ),
      ],
      if (_st == 'Sudah diperiksa' || _st == 'Disetujui')
        Text(
          'Untuk mengubah isinya, kembalikan edisi ke Draf lebih dulu.',
          style: kecil,
        ),
      if (_ralatTeks.isNotEmpty)
        _kartu([
          KepalaKartu(
            judul: 'Ralat (revisi edisi 22/11/2026)',
            ujung: _diterbitkan(),
          ),
          Text(_ralatTeks, style: baris14),
          Text(
            'Tertaut ke edisi asli, yang tetap tampil apa adanya.',
            style: kecil,
          ),
        ]),
      if (_riw.isNotEmpty) RiwayatAlur(baris: _riw, jarak: 12),
    ];
    return [
      KepalaKartu(
        judul: 'Edisi 22/11/2026',
        ujung: LencanaStatus(
          _st,
          bentuk: switch (_st) {
            'Sudah diperiksa' => BentukLencana.lautGaris,
            'Disetujui' => BentukLencana.laut,
            'Diterbitkan' => BentukLencana.tinta,
            _ => BentukLencana.draf,
          },
        ),
      ),
      if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
      _duaKolom(kiri, kanan),
    ];
  }

  List<Widget> _viewUmum(PalakatWarna c) {
    final sebab = _sebabU();
    final mulai =
        _uj.text.isNotEmpty ||
        _ui.text.isNotEmpty ||
        _uUntuk.isNotEmpty ||
        _uAkhir.text.isNotEmpty;
    void ubah(String _) => setState(() {});
    return [
      _duaKolom(
        [
          IsianAlur(
            label: 'Judul',
            controller: _uj,
            onChanged: ubah,
            petunjuk: 'Judul pengumuman',
          ),
          IsianAlur(label: 'Isi', controller: _ui, onChanged: ubah, baris: 3),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ditujukan untuk',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final p in _untukPil)
                    ChipSatu(
                      teks: p,
                      dipilih: _uUntuk == p,
                      onTap: () => setState(() {
                        _uUntuk = p;
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
            onChanged: ubah,
            petunjuk: 'hh/bb/tttt',
            keterangan: 'Boleh kosong. Setelah tanggal ini pengumuman diarsipkan sendiri.',
          ),
        ],
        [
          Text(
            'Hanya Sekretaris Jemaat yang menerbitkan. Sekretaris Jemaat juga yang memilih pengumuman mana yang masuk ke tiap edisi Warta.',
            style: TextStyle(fontSize: 13, color: c.tinta3),
          ),
          if (mulai && sebab.isNotEmpty)
            Penolakan(
              tindakan: 'Terbitkan',
              sebab: sebab,
              jalan: const [],
              ukuranTeks: 14,
            ),
          BarisTombol(
            anak: [
              TombolBersyarat(
                label: 'Terbitkan',
                tindakan: 'Terbitkan',
                alasan: sebab,
                periksa: _sebabU,
                sudahMulai: false,
                onPressed: () => _simpan('Diterbitkan'),
              ),
              Tombol(
                'Simpan sebagai draf',
                onPressed: () => _simpan('Draf'),
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.sedang,
              ),
              _teksBtn('Batalkan', () => _ke('warta')),
            ],
          ),
        ],
      ),
    ];
  }

  List<Widget> _viewNama(PalakatWarna c) => [
    _duaKolom(
      [
        _kartu([
          const _Info('Edisi', 'Warta Jemaat 22/11/2026'),
          const _Info('Pilihan anggota', 'Tanpa nama'),
          const _Info('Akan diterbitkan sebagai', 'Kel. Mamahit — Kolom 4'),
          Text(
            'Tampilan nama pilihan anggota wajib diikuti. Pengecualian hanya untuk keperluan resmi, tata kelola, hukum atau pertanggungjawaban.',
            style: TextStyle(fontSize: 13, color: c.tinta3),
          ),
        ]),
      ],
      [
        IsianAlur(
          label: 'Alasan · wajib',
          controller: _alasan,
          onChanged: (_) => setState(() {}),
          baris: 3,
        ),
        // The board's refusal line here is `al && !al`: it never shows.
        BarisTombol(
          anak: [
            TombolBersyarat(
              label: 'Catat pengecualian',
              tindakan: 'Catat pengecualian',
              alasan: _sebabN(),
              periksa: _sebabN,
              sudahMulai: false,
              onPressed: _catatNama,
            ),
            _teksBtn('Batalkan', () => _ke('warta')),
          ],
        ),
      ],
    ),
  ];

  List<Widget> _viewRalat(PalakatWarna c) => [
    _kartu([
      KepalaKartu(
        judul: 'Warta Jemaat · edisi 22/11/2026',
        ujung: _diterbitkan(),
      ),
      Text(
        'Edisi asli tidak diubah. Ralat diterbitkan sebagai revisi yang tertaut.',
        style: TextStyle(fontSize: 13, color: c.tinta3),
      ),
    ]),
    IsianAlur(
      label: 'Yang diralat · wajib',
      controller: _ralat,
      onChanged: (_) => setState(() {}),
      baris: 3,
    ),
    // The board's refusal line here is `rl && !rl`: it never shows.
    BarisTombol(
      anak: [
        TombolBersyarat(
          label: 'Terbitkan ralat',
          tindakan: 'Terbitkan ralat',
          alasan: _sebabR(),
          periksa: _sebabR,
          sudahMulai: false,
          onPressed: _terbitRalat,
        ),
        _teksBtn('Batalkan', () => _ke('warta')),
      ],
    ),
  ];
}

/// One announcement row: a 1 `garis` top rule, padding-top 8; text `flex: 1
/// 1 180px` and the toggle chip in a wrap (gap 6 × 12): the chip drops under
/// the text when 180 + 12 + its width does not fit.
class _BarisUmum extends StatelessWidget {
  const _BarisUmum({required this.u, required this.onTap});

  final _Umum u;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final on = u.masuk;
    final label = on ? 'Masuk edisi ini' : 'Tidak masuk';
    final teks = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${u.judul} · ${u.isi}',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        Text(
          'Ditujukan untuk: ${u.untuk}${on && u.untuk != 'Semua anggota' ? ' · perhatikan: Warta dibaca semua anggota' : ''}',
          style: TextStyle(fontSize: 13, color: c.tinta3),
        ),
      ],
    );
    final chip = ChipSatu(teks: label, dipilih: on, onTap: onTap);
    return Container(
      padding: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.garis)),
      ),
      child: LayoutBuilder(
        builder: (context, k) {
          final ukur = TextPainter(
            text: TextSpan(
              text: label,
              style: DefaultTextStyle.of(context).style
                  .copyWith(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            textDirection: TextDirection.ltr,
            textScaler: MediaQuery.textScalerOf(context),
          )..layout();
          // Chip: padding 0 14 and a 1.5 line each side.
          final lebarChip = ukur.width + 28 + 3;
          ukur.dispose();
          if (180 + 12 + lebarChip <= k.maxWidth) {
            return Row(
              children: [
                Expanded(child: teks),
                const SizedBox(width: 12),
                chip,
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [teks, const SizedBox(height: 6), chip],
          );
        },
      ),
    );
  }
}

/// KitAlur's info row, but the label may shrink and wrap as the board's
/// `flex: 0 1 auto` span does (`BarisInfo` keeps it rigid and overflows).
class _Info extends StatelessWidget {
  const _Info(this.label, this.nilai, {this.mono = false});

  final String label, nilai;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return DefaultTextStyle.merge(
      style: const TextStyle(fontSize: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(label, style: TextStyle(color: c.tinta2)),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              nilai,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: c.tinta,
                fontWeight: FontWeight.w600,
                fontFamily: mono ? PalakatText.mono : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
