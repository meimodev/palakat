import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../mock/format.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/perangkat_prototipe.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/kecil.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/riwayat_alur.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';

/// Web · Alur · Akun saya (screens/16-alurmasuk.md): Olvie Pangemanan's own
/// account. Six views change in place; no timers, no motion.
class WebAkunSayaScreen extends StatefulWidget {
  const WebAkunSayaScreen({super.key});

  @override
  State<WebAkunSayaScreen> createState() => _WebAkunSayaState();
}

const _nama = 'Olvie Pangemanan', _jabatan = 'Sekretaris Jemaat';
const _hpAwal = '081355512204', _emAwal = 'olvie@contoh.id';
const _kodeBenar = '123456';

enum _V { akun, ganti, kodeBaru, email, kodeEmail, keluar }

class _WebAkunSayaState extends State<WebAkunSayaScreen> {
  final _hpBaru = TextEditingController(),
      _kode = TextEditingController(),
      _emBaru = TextEditingController();
  _V _v = _V.akun;
  String _pesan = '', _hp = '';
  String? _em;
  int _salah = 0;
  List<String> _riw = const [];
  List<String> _dev = const ['Ponsel lain · Samsung A15 · terakhir 12/11/2026'];

  // Scroll on view change: jump to top (CONVENTIONS). HalamanWeb owns the
  // scroll view, so it is reached from a context inside it.
  final _isiKunci = GlobalKey();
  _V _vLalu = _V.akun;

  @override
  void dispose() {
    _hpBaru.dispose();
    _kode.dispose();
    _emBaru.dispose();
    super.dispose();
  }

  String get _hpKini => _hp.isEmpty ? _hpAwal : _hp;
  String get _emKini => _em ?? _emAwal;

  void _catat(String t) => _riw = ['$hariTeks · $t', ..._riw];

  void _ke(_V v) => setState(() {
    _v = v;
    _pesan = '';
  });

  void _mulaiKode() {
    _kode.clear();
    _salah = 0;
  }

  // First unmet reasons, read from the latest input.
  String _alasanHp() {
    final t = _hpBaru.text;
    if (t.isEmpty) return 'nomor baru belum diisi.';
    if (!hpSah(t)) return 'nomor ponsel tidak dikenali. Contoh: 081298765432.';
    if (t == _hpKini) return 'nomor baru sama dengan nomor sekarang.';
    return '';
  }

  String _alasanKode() {
    if (_salah >= 3) return 'terlalu banyak percobaan. Minta kode baru.';
    if (_kode.text.length < 6) return 'kode belum lengkap.';
    return '';
  }

  String _alasanEm() {
    final t = _emBaru.text;
    if (t.isEmpty) return 'email belum diisi.';
    if (!emailSah(t)) return 'email tidak dikenali. Contoh: nama@contoh.id.';
    if (t == _emKini) return 'email itu sudah menjadi email cadangan Anda.';
    return '';
  }

  /// The refusal line of the code views: never "kode belum lengkap.".
  String _sebabKode() {
    if (_salah >= 3) return _alasanKode();
    if (_salah > 0 && _kode.text.isEmpty) {
      return 'kode tidak cocok. Sisa percobaan: ${3 - _salah}.';
    }
    return '';
  }

  void _keGanti() => setState(() {
    _v = _V.ganti;
    _pesan = '';
    _hpBaru.clear();
    _mulaiKode();
  });

  void _keEmail() => setState(() {
    _v = _V.email;
    _pesan = '';
    _emBaru.clear();
    _mulaiKode();
  });

  void _kirim() => setState(() {
    _v = _V.kodeBaru;
    _mulaiKode();
  });

  void _kirimEm() => setState(() {
    _v = _V.kodeEmail;
    _mulaiKode();
  });

  void _salahKode() {
    _salah++;
    _kode.clear();
  }

  void _gantiNomor() => setState(() {
    if (_kode.text != _kodeBenar) return _salahKode();
    _v = _V.akun;
    _hp = _hpBaru.text;
    _dev = const [];
    _pesan =
        'Nomor ponsel diganti. Perangkat lain dikeluarkan dan harus masuk '
        'lagi dengan nomor baru.';
    _catat(
      'Nomor ponsel diganti menjadi ${samarHp(_hpBaru.text)} · oleh $_nama',
    );
  });

  void _simpanEm() => setState(() {
    if (_kode.text != _kodeBenar) return _salahKode();
    final ada = _emKini.isNotEmpty;
    _v = _V.akun;
    _em = _emBaru.text.trim();
    _pesan = 'Email cadangan disimpan.';
    _catat('Email cadangan ${ada ? 'diganti' : 'ditambahkan'} · oleh $_nama');
  });

  void _keluarkan(int i) => setState(() {
    _dev = [..._dev]..removeAt(i);
    _pesan = 'Perangkat itu dikeluarkan. Ia harus masuk lagi dengan kode baru.';
  });

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final kodeTampil = _v == _V.kodeBaru || _v == _V.kodeEmail;
    if (_v != _vLalu) {
      _vLalu = _v;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final k = _isiKunci.currentContext;
        if (k != null) Scrollable.maybeOf(k)?.position.jumpTo(0);
      });
    }
    final blok = switch (_v) {
      _V.akun => _akun(),
      _V.ganti => _ganti(),
      _V.kodeBaru => _kodeView(
        ket: _hpBaru.text,
        tindakan: 'Ganti nomor ponsel',
        catatan: true,
        onPressed: _gantiNomor,
      ),
      _V.email => _email(),
      _V.kodeEmail => _kodeView(
        ket: _emBaru.text,
        tindakan: 'Simpan email cadangan',
        catatan: false,
        onPressed: _simpanEm,
      ),
      _V.keluar => _keluar(),
    };
    return AlatPrototipe(
      stem: 'WebAkunSaya',
      alat: [
        if (kodeTampil)
          const Text('Di prototipe ini kode yang benar adalah 123456.'),
      ],
      child: HalamanWeb(
        nav: const NavSamping(
          item: navPlatform,
          aktif: 0,
          pengguna: PenggunaNav(tebal: _nama, biasa: ' · $_jabatan'),
        ),
        isi: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MarginNegatif(
                atas: 11,
                bawah: 11,
                child: Tautan(
                  ke: 'WebBerandaJabatan',
                  cara: Cara.naik,
                  child: SizedBox(
                    height: 44,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: 1,
                      child: TautanTeks('Beranda', ukuran: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Semantics(
                header: true,
                child: const Text(
                  'Alur · Akun saya',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                'Nomor ponsel, perangkat, pemberitahuan dorong, keluar',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ],
          ),
          Align(
            key: _isiKunci,
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: _Kolom(blok, jarak: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _keterangan(String t) =>
      Text(t, style: TextStyle(fontSize: 13, color: context.warna.tinta3));

  Widget _baris(String t) =>
      Text(t, style: TextStyle(fontSize: 14, color: context.warna.tinta2));

  Widget _batalkan([String label = 'Batalkan']) => Tombol(
    label,
    onPressed: () => _ke(_V.akun),
    jenis: JenisTombol.teks,
    ukuran: UkuranTombol.kecil,
  );

  Widget _kedua(String label, VoidCallback onPressed, {bool penuh = true}) =>
      Tombol(
        label,
        onPressed: onPressed,
        jenis: JenisTombol.kedua,
        ukuran: UkuranTombol.sedang,
        lebarPenuh: penuh,
      );

  Widget _syarat(
    String label,
    String Function() periksa,
    VoidCallback onPressed,
  ) => TombolBersyarat(
    label: label,
    tindakan: label,
    alasan: periksa(),
    periksa: periksa,
    sudahMulai: false,
    onPressed: onPressed,
  );

  Widget _tolak(String tindakan, String sebab) => Penolakan(
    tindakan: tindakan,
    sebab: sebab,
    jalan: const [],
    ukuranTeks: 14,
  );

  List<Widget> _akun() {
    final c = context.warna;
    final identitas = Kartu(
      child: _Kolom([
        const Text(_nama, style: TextStyle(fontWeight: FontWeight.w700)),
        BarisInfo(
          'Nomor ponsel',
          samarHp(_hpKini),
          mono: true,
          berat: FontWeight.w500,
        ),
        BarisInfo('Email cadangan', samarEmail(_emKini)),
        const BarisInfo('Jabatan', _jabatan),
        _keterangan(
          'Nomor ponsel dipakai untuk masuk. Email cadangan tidak wajib; '
          'dipakai hanya untuk pemulihan akun bila nomor hilang. Tanpa email, '
          'akun dipulihkan Operator setelah Penatua Kolom memastikan '
          'identitas Anda.',
        ),
        _keterangan(
          'Jabatan ditugaskan oleh Pimpinan Jemaat yang berwenang; tidak '
          'diubah dari sini.',
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _kedua('Ganti nomor ponsel', _keGanti, penuh: false),
            _kedua(
              _emKini.isNotEmpty
                  ? 'Ganti email cadangan'
                  : 'Tambah email cadangan',
              _keEmail,
              penuh: false,
            ),
          ],
        ),
      ]),
    );
    final perangkat = Kartu(
      child: _Kolom([
        const Text(
          'Perangkat yang masuk',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const BarisInfo('Perangkat ini', 'sedang dipakai'),
        for (final (i, d) in _dev.indexed)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      d,
                      style: TextStyle(fontSize: 14, color: c.tinta2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Tombol(
                'Keluarkan',
                onPressed: () => _keluarkan(i),
                jenis: JenisTombol.teks,
                ukuran: UkuranTombol.kecil,
                lebarPenuh: false,
              ),
            ],
          ),
      ]),
    );
    final kanan = <Widget>[
      Kartu(
        child: _Kolom([
          const Text(
            'Pemberitahuan dorong',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          _baris(
            'Diatur dari aplikasi di ponsel Anda. Di laptop, pekerjaan baru '
            'tampil di Beranda dan Pemberitahuan.',
          ),
        ]),
      ),
      if (_riw.isNotEmpty) RiwayatAlur(baris: _riw, jarak: 12),
    ];
    return [
      if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
      BarisLentur(
        jarak: 28,
        jarakBaris: 20,
        anak: [
          Lentur(
            dasar: 420,
            tumbuh: 1.3,
            child: _Kolom([
              identitas,
              perangkat,
              BarisTombol(anak: [_kedua('Keluar', () => _ke(_V.keluar))]),
            ], jarak: 12),
          ),
          Lentur(dasar: 340, child: _Kolom(kanan, jarak: 12)),
        ],
      ),
    ];
  }

  List<Widget> _ganti() {
    final sebab = _hpBaru.text.isEmpty ? '' : _alasanHp();
    return [
      Kartu(
        child: _Kolom([
          BarisInfo(
            'Nomor sekarang',
            samarHp(_hpKini),
            mono: true,
            berat: FontWeight.w500,
          ),
          _keterangan(
            'Kode dikirim ke nomor yang baru, supaya terbukti nomor itu milik '
            'Anda.',
          ),
        ]),
      ),
      IsianAlur(
        label: 'Nomor ponsel baru',
        controller: _hpBaru,
        petunjuk: '08…',
        keterangan: 'Contoh: 081298765432',
        keyboard: TextInputType.phone,
        formatter: _angka(13),
        onChanged: (_) => setState(() {}),
      ),
      if (sebab.isNotEmpty) _tolak('Kirim kode ke nomor baru', sebab),
      BarisTombol(
        anak: [
          _syarat('Kirim kode ke nomor baru', _alasanHp, _kirim),
          _batalkan(),
        ],
      ),
    ];
  }

  List<Widget> _kodeView({
    required String ket,
    required String tindakan,
    required bool catatan,
    required VoidCallback onPressed,
  }) {
    final sebab = _sebabKode();
    return [
      _baris(
        'Kode 6 angka dikirim ke $ket. Kode hanya berlaku sebentar dan sekali '
        'pakai.',
      ),
      IsianAlur(
        label: 'Kode 6 angka',
        controller: _kode,
        petunjuk: '••••••',
        keyboard: TextInputType.number,
        formatter: _angka(6),
        onChanged: (_) => setState(() {}),
      ),
      if (sebab.isNotEmpty) _tolak(tindakan, sebab),
      if (catatan)
        _keterangan(
          'Setelah diganti, nomor lama tidak dapat dipakai untuk masuk dan '
          'perangkat lain dikeluarkan.',
        ),
      BarisTombol(
        anak: [_syarat(tindakan, _alasanKode, onPressed), _batalkan()],
      ),
    ];
  }

  List<Widget> _email() {
    final sebab = _emBaru.text.isEmpty ? '' : _alasanEm();
    return [
      Kartu(
        child: _Kolom([
          BarisInfo('Email cadangan sekarang', samarEmail(_emKini)),
          _keterangan(
            'Kode dikirim ke email itu, supaya terbukti email itu milik Anda.',
          ),
        ]),
      ),
      IsianAlur(
        label: 'Email cadangan',
        controller: _emBaru,
        petunjuk: 'nama@contoh.id',
        keterangan: 'Tidak wajib. Dipakai hanya untuk pemulihan akun.',
        keyboard: TextInputType.emailAddress,
        onChanged: (_) => setState(() {}),
      ),
      if (sebab.isNotEmpty) _tolak('Kirim kode ke email', sebab),
      BarisTombol(
        anak: [
          _syarat('Kirim kode ke email', _alasanEm, _kirimEm),
          _batalkan(),
        ],
      ),
    ];
  }

  List<Widget> _keluar() => [
    Kartu(
      child: _Kolom([
        const Text(
          'Keluar dari perangkat ini?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        _baris(
          'Isian yang belum tersimpan di layar akan hilang. Data yang sudah '
          'tersimpan tidak berubah.',
        ),
      ]),
    ),
    // The board's `<a>` is content-box: flex 1 1 150px and max-width 340px
    // plus its 0 16 padding make 182 and 372 outer, unlike the buttons.
    BarisLentur(
      jarak: 8,
      rata: CrossAxisAlignment.center,
      anak: [
        const Lentur(
          dasar: 182,
          maks: 372,
          child: Tombol(
            'Keluar',
            onPressed: null,
            jenis: JenisTombol.tinta,
            ke: 'WebAlurMasuk',
            cara: Cara.ganti,
          ),
        ),
        Lentur(dasar: 150, maks: 340, child: _batalkan('Batal')),
      ],
    ),
  ];
}

/// Digits only, at most [n] (`replace(/\D/g, '').slice(0, n)`).
List<TextInputFormatter> _angka(int n) => [
  FilteringTextInputFormatter.digitsOnly,
  LengthLimitingTextInputFormatter(n),
];

/// A column with a fixed gap (6 inside cards).
class _Kolom extends StatelessWidget {
  const _Kolom(this.anak, {this.jarak = 6});
  final List<Widget> anak;
  final double jarak;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      for (final (i, a) in anak.indexed) ...[
        if (i > 0) SizedBox(height: jarak),
        a,
      ],
    ],
  );
}
