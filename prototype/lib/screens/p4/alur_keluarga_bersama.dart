import 'package:flutter/widgets.dart';

import '../../shell/perangkat_prototipe.dart';
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

/// [anak] with a [jarak] gap between each (a CSS flex column `gap`).
Widget kolomAlur(List<Widget> anak, double jarak) => Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    for (var i = 0; i < anak.length; i++) ...[
      if (i > 0) SizedBox(height: jarak),
      anak[i],
    ],
  ],
);

/// The logic class of AlurKeluarga / WebAlurKeluarga (identical on both
/// boards) and the blocks both draw; each screen only arranges them.
mixin AlurKeluargaLogika<T extends StatefulWidget> on State<T> {
  static const _hari = 20261116, _hariT = '16/11/2026';
  static const _aktor = ['Operator', 'Penatua Kolom 7'];
  static const _formulir = 'Formulir konfirmasi bertanda tangan';

  final lahir = TextEditingController();
  String pesan = '', akt = 'Operator', ganda = '', file = '', st = '';
  bool izinF = false;
  List<String> riw = const [];

  @override
  void dispose() {
    lahir.dispose();
    super.dispose();
  }

  static int? _tgl(String t) {
    final m = RegExp(r'^(\d\d)/(\d\d)/(\d{4})$').firstMatch(t.trim());
    if (m == null) return null;
    final d = int.parse(m[1]!), b = int.parse(m[2]!);
    if (b < 1 || b > 12 || d < 1 || d > 31) return null;
    return int.parse(m[3]!) * 10000 + b * 100 + d;
  }

  bool get op => akt == 'Operator';
  bool get _lahirLolos {
    final t = _tgl(lahir.text);
    return t != null && t < _hari;
  }

  String get _n => ganda == 'Gabungkan'
      ? '3 orang (Novita Wenas digabung dengan data yang sudah ada)'
      : '3 orang';

  String get _alasan1 {
    final s = lahir.text, t = _tgl(s);
    if (s.trim().isEmpty) return 'tanggal lahir Agustina Lasut belum lengkap.';
    if (t == null) return 'tanggal lahir tidak dikenali. Contoh: 12/12/1974.';
    if (t >= _hari) return 'tanggal lahir harus sebelum hari ini.';
    if (ganda.isEmpty) return 'kemungkinan data ganda belum diputuskan.';
    return '';
  }

  String get _alasan2 => file != 'ada'
      ? 'formulir bertanda tangan belum terlampir.'
      : !izinF
      ? 'formulir harus memuat izin penggunaan data pribadi.'
      : '';

  void _catat(String t) => riw = ['$_hariT · $t', ...riw];

  void _impor() => setState(() {
    st = 'Belum dikonfirmasi';
    file = '';
    pesan = '';
    _catat('Buku anggota Kolom 7 diimpor: $_n · Yanti Sumual, Operator');
  });

  void _kirim() => setState(() {
    st = 'Menunggu verifikasi';
    pesan = 'Penatua Kolom 7 diberi tahu lewat Pemberitahuan.';
    _catat(
      'Formulir konfirmasi Keluarga Wenas-Lasut dimasukkan · Yanti Sumual, Operator',
    );
  });

  void _verif() => setState(() {
    st = 'Aktif';
    pesan = '';
    _catat(
      'Keluarga Wenas-Lasut Diverifikasi dan Aktif · Pnt. Hendrik Rumagit, Penatua Kolom 7',
    );
  });

  /// "Dilihat sebagai" goes to the Keadaan panel (CONVENTIONS).
  Widget denganAlat(String stem, Widget child) => AlatPrototipe(
    stem: stem,
    alat: [
      DilihatSebagai(
        pilihan: _aktor,
        terpilih: akt,
        onPilih: (a) => setState(() {
          akt = a;
          pesan = '';
        }),
      ),
    ],
    child: child,
  );

  Widget? get banner => pesan.isEmpty ? null : Pesan(Text(pesan));

  Widget _kartu(
    List<Widget> anak, {
    GarisStatus status = GarisStatus.dibukukan,
  }) => Kartu(status: status, child: kolomAlur(anak, 6));

  // ponytail: the 226 cap only bites under the 1em-per-glyph test font
  // (routes_test overflow); real badges here are under 190 wide.
  Widget _kepala(String judul, String label, BentukLencana b) => KepalaKartu(
    judul: judul,
    ujung: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 226),
      child: LencanaStatus(label, bentuk: b),
    ),
  );

  Widget _kecil(String t) =>
      Text(t, style: TextStyle(fontSize: 13, color: context.warna.tinta3));

  // Operator, before import.
  List<Widget> get bukuKiri => [
    const BarisInfo('Sumber', 'Buku anggota Kolom 7 · 2019–2026'),
    _kartu([
      _kepala('Ferry Wenas', 'Lolos pengecekan', BentukLencana.garis),
      _kecil(
        'Di buku: WENAS FERRY, lhr 3-8-71, Kol 7 · dibaca sebagai 03/08/1971',
      ),
    ]),
    _kartu([
      _lahirLolos
          ? _kepala('Agustina Lasut', 'Lolos pengecekan', BentukLencana.garis)
          : _kepala('Agustina Lasut', 'Perlu dilengkapi', BentukLencana.bata),
      _kecil('Di buku: LASUT AGUSTINA (istri), 12-12-74 · tahun tidak lengkap'),
      IsianAlur(
        label: 'Tanggal lahir',
        controller: lahir,
        onChanged: (_) => setState(() {}),
        petunjuk: 'hh/bb/tttt',
        keterangan: 'Ketik lengkap sesuai keterangan keluarga.',
      ),
    ]),
    _kartu([
      _kepala('Novita Wenas', 'Kemungkinan data ganda', BentukLencana.bata),
      _kecil(
        'Sudah ada dari Permohonan menjadi anggota: Novita Wenas, 14/03/1996, Kolom 7. Tidak pernah digabung sendiri.',
      ),
      ChipPilihan<String>(
        label: 'Keputusan Anda',
        jarakLabel: 6,
        jarakBaris: 0,
        pilihan: const [
          (nilai: 'Gabungkan', teks: 'Gabungkan'),
          (nilai: 'Bukan orang yang sama', teks: 'Bukan orang yang sama'),
        ],
        terpilih: ganda.isEmpty ? null : ganda,
        onPilih: (g) => setState(() {
          ganda = g;
          pesan = '';
        }),
      ),
    ]),
  ];

  List<Widget> get bukuKanan {
    final sebab = lahir.text.isNotEmpty || ganda.isNotEmpty ? _alasan1 : '';
    return [
      _kecil(
        'Belum ada yang tersimpan sebagai data jemaat sampai Anda mengimpor.',
      ),
      if (sebab.isNotEmpty)
        Penolakan(
          tindakan: 'Impor',
          sebab: sebab,
          jalan: const [],
          ukuranTeks: 14,
        ),
      BarisTombol(
        anak: [
          TombolBersyarat(
            label: 'Impor 3 baris',
            tindakan: 'Impor',
            alasan: _alasan1,
            periksa: () => _alasan1,
            onPressed: _impor,
            sudahMulai: false,
          ),
        ],
      ),
    ];
  }

  // Operator, after import.
  List<Widget> get konfKiri {
    final c = context.warna;
    return [
      Kartu(
        status: GarisStatus.draf,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: 'Masuk sebagai Belum dikonfirmasi.',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(
                text: ' Hanya Penatua Kolom 7 dan Operator yang melihatnya. Tidak ada yang tampil di publikasi sampai keluarganya mengonfirmasi dan memberi izin.',
                style: TextStyle(color: c.tinta2),
              ),
            ],
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ),
      _kartu([
        _kepala('Keluarga Wenas-Lasut', st, switch (st) {
          'Aktif' => BentukLencana.laut,
          'Menunggu verifikasi' => BentukLencana.garis,
          _ => BentukLencana.draf,
        }),
        Text(switch (st) {
          'Aktif' =>
            'Diverifikasi Pnt. Hendrik Rumagit, $_hariT. Nama keluarga dapat tampil sesuai Tampilan nama yang dipilih.',
          'Menunggu verifikasi' =>
            'Formulir kertas dimasukkan $_hariT · menunggu Penatua Kolom 7',
          _ => 'Kolom 7 · $_n · diimpor $_hariT',
        }, style: TextStyle(fontSize: 14, color: c.tinta2)),
      ]),
    ];
  }

  List<Widget> get konfKanan {
    if (st == 'Belum dikonfirmasi') {
      final ada = file == 'ada';
      final sebab = file.isNotEmpty || izinF ? _alasan2 : '';
      return [
        _kartu(status: GarisStatus.draf, [
          ada
              ? _kepala(_formulir, 'Terlampir', BentukLencana.garis)
              : _kepala(_formulir, 'Wajib, belum ada', BentukLencana.bata),
          if (file.isEmpty)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Tombol(
                'Pilih file',
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.sedang,
                lebarPenuh: false,
                onPressed: () => setState(() => file = 'ada'),
              ),
            ),
          if (ada) _kecil('1 file terlampir'),
        ]),
        KotakCentang(
          nilai: izinF,
          onUbah: (_) => setState(() => izinF = !izinF),
          label: const Text(
            'Formulir memuat izin penggunaan data pribadi, naskah versi 1.',
          ),
        ),
        if (sebab.isNotEmpty)
          Penolakan(
            tindakan: 'Kirim untuk diverifikasi',
            sebab: sebab,
            jalan: const [],
            ukuranTeks: 14,
          ),
        BarisTombol(
          anak: [
            TombolBersyarat(
              label: 'Kirim untuk diverifikasi',
              tindakan: 'Kirim untuk diverifikasi',
              alasan: _alasan2,
              periksa: () => _alasan2,
              onPressed: _kirim,
              sudahMulai: false,
            ),
          ],
        ),
      ];
    }
    if (st == 'Menunggu verifikasi') {
      return [
        const Penolakan(
          tindakan: 'Verifikasi data',
          sebab: 'yang memasukkan formulir tidak memverifikasinya sendiri.',
          jalan: [],
          ukuranTeks: 15,
        ),
        _kecil('Menunggu Pnt. Hendrik Rumagit, Penatua Kolom 7.'),
      ];
    }
    return const [];
  }

  // Penatua Kolom 7.
  List<Widget> get penatua {
    if (st == 'Menunggu verifikasi') {
      return [
        _kartu([
          _kepala(
            'Konfirmasi keluarga · Wenas-Lasut',
            'Menunggu verifikasi',
            BentukLencana.garis,
          ),
          BarisInfo('Anggota keluarga', _n),
          const BarisInfo('Formulir', 'Terlampir · memuat izin data pribadi'),
          const BarisInfo('Dimasukkan oleh', 'Yanti Sumual, Operator'),
        ]),
        BarisTombol(
          anak: [
            Tombol(
              'Verifikasi data',
              jenis: JenisTombol.tinta,
              onPressed: _verif,
            ),
          ],
        ),
      ];
    }
    return [
      _kartu(status: GarisStatus.draf, [
        const Text(
          'Tidak ada data yang menunggu verifikasi',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        Text(
          st == 'Aktif' ? 'Keluarga Wenas-Lasut sudah Aktif.' : 'Keluarga dari buku anggota muncul di sini setelah mengonfirmasi datanya.',
          style: TextStyle(fontSize: 14, color: context.warna.tinta2),
        ),
      ]),
    ];
  }

  Widget? get riwayat => riw.isEmpty ? null : RiwayatAlur(baris: riw);
}
