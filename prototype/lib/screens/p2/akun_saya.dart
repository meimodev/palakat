import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../mock/format.dart';
import '../../mock/mock.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/perangkat_prototipe.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/pratinjau_layar_kunci.dart';
import '../../widgets/riwayat_alur.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';

const _nama = 'Pnt. Hendrik Rumagit';
const _jabatan = 'Penatua Kolom 7 · Ketua Komisi Diakonia';
const _modul = ['Data jemaat', 'Ibadah dan kegiatan', 'Keuangan unit'];

enum _V { akun, ganti, kodeBaru, email, kodeEmail, keluar }

/// 59 · Alur · Akun saya (spec 16-alurmasuk.md): six views in place under
/// one header; the board's state object lives here.
class AkunSayaScreen extends StatefulWidget {
  const AkunSayaScreen({super.key});

  @override
  State<AkunSayaScreen> createState() => _AkunSayaScreenState();
}

class _AkunSayaScreenState extends State<AkunSayaScreen> {
  final _gulir = ScrollController();
  final _hpBaru = TextEditingController();
  final _kode = TextEditingController();
  final _emBaru = TextEditingController();

  var _v = _V.akun;
  var _pesan = '';
  var _riw = <String>[];
  var _izin = ''; // '' | 'minta' | 'tolak' | 'ya'
  var _mati = <String>[];
  var _dev = [akunSaya.perangkatLain];
  var _hp = '';
  var _salah = 0;
  String? _em;

  String get _hpKini => _hp.isEmpty ? akunSaya.ponsel : _hp;
  String get _emKini => _em ?? akunSaya.emailCadangan;

  String _alasanHp() {
    final b = _hpBaru.text;
    if (b.isEmpty) return 'nomor baru belum diisi.';
    if (!hpSah(b)) return 'nomor ponsel tidak dikenali. Contoh: 081298765432.';
    if (b == _hpKini) return 'nomor baru sama dengan nomor sekarang.';
    return '';
  }

  String _alasanKode() {
    if (_salah >= 3) return 'terlalu banyak percobaan. Minta kode baru.';
    if (_kode.text.length < 6) return 'kode belum lengkap.';
    return '';
  }

  String _alasanEm() {
    final e = _emBaru.text;
    if (e.isEmpty) return 'email belum diisi.';
    if (!emailSah(e)) return 'email tidak dikenali. Contoh: nama@contoh.id.';
    if (e == _emKini) return 'email itu sudah menjadi email cadangan Anda.';
    return '';
  }

  /// The code refusal line: locked, or "kode tidak cocok" while empty.
  String get _sebabKode => _salah >= 3
      ? _alasanKode()
      : (_salah > 0 && _kode.text.isEmpty
            ? 'kode tidak cocok. Sisa percobaan: ${3 - _salah}.'
            : '');

  void _ke(_V v) {
    setState(() {
      _v = v;
      _pesan = '';
    });
    if (_gulir.hasClients) _gulir.jumpTo(0);
  }

  void _keGanti() {
    _hpBaru.clear();
    _kode.clear();
    _salah = 0;
    _ke(_V.ganti);
  }

  void _keEmail() {
    _emBaru.clear();
    _kode.clear();
    _salah = 0;
    _ke(_V.email);
  }

  void _kirimKode(_V v) {
    _kode.clear();
    _salah = 0;
    _ke(v);
  }

  void _salahKode() => setState(() {
    _salah++;
    _kode.clear();
  });

  void _gantiNomor() {
    if (_kode.text != alurMasuk.kode) return _salahKode();
    _hp = _hpBaru.text;
    _dev = [];
    _riw = catat(
      _riw,
      'Nomor ponsel diganti menjadi ${samarHp(_hp)} · oleh $_nama',
    );
    _ke(_V.akun);
    _pesan = 'Nomor ponsel diganti. Perangkat lain dikeluarkan dan harus masuk lagi dengan nomor baru.';
  }

  void _simpanEm() {
    if (_kode.text != alurMasuk.kode) return _salahKode();
    final ada = _emKini.isNotEmpty;
    _em = _emBaru.text.trim();
    _riw = catat(
      _riw,
      'Email cadangan ${ada ? 'diganti' : 'ditambahkan'} · oleh $_nama',
    );
    _ke(_V.akun);
    _pesan = 'Email cadangan disimpan.';
  }

  void _izinkan(String v) => setState(() => _izin = v);

  @override
  void dispose() {
    _gulir.dispose();
    _hpBaru.dispose();
    _kode.dispose();
    _emBaru.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kodeView = _v == _V.kodeBaru || _v == _V.kodeEmail;
    return AlatPrototipe(
      stem: 'AkunSaya',
      alat: [
        if (kodeView)
          const Text('Di prototipe ini kode yang benar adalah 123456.'),
        if (_v == _V.akun && _izin == 'minta') ...[
          _tombolTeks('Contoh: diizinkan', () => _izinkan('ya')),
          _tombolTeks('Contoh: ditolak', () => _izinkan('tolak')),
        ],
      ],
      child: LayarPonsel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const KepalaPonsel(
              judul: 'Alur · Akun saya',
              anakJudul:
                  'Nomor ponsel, perangkat, pemberitahuan dorong, keluar',
              kembaliKe: 'BerandaJabatan',
              labelKembali: 'Kembali ke Beranda',
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _gulir,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: switch (_v) {
                    _V.akun => _akun(context),
                    _V.ganti => _ganti(context),
                    _V.kodeBaru => _kodeBaru(context),
                    _V.email => _email(context),
                    _V.kodeEmail => _kodeEmail(context),
                    _V.keluar => _keluar(context),
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tombolTeks(String label, VoidCallback onTap) => Tombol(
    label,
    onPressed: onTap,
    jenis: JenisTombol.teks,
    ukuran: UkuranTombol.kecil,
    lebarPenuh: false,
  );

  Widget _kedua(String label, VoidCallback onTap, {bool lebarPenuh = false}) =>
      Tombol(
        label,
        onPressed: onTap,
        jenis: JenisTombol.kedua,
        ukuran: UkuranTombol.sedang,
        lebarPenuh: lebarPenuh,
      );

  Widget _kecil(BuildContext context, String t) =>
      Text(t, style: TextStyle(fontSize: 13, color: context.warna.tinta3));

  Widget _biasa(BuildContext context, String t) =>
      Text(t, style: TextStyle(fontSize: 14, color: context.warna.tinta2));

  Widget _kartu(List<Widget> anak, {String? judul}) => Kartu(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        if (judul != null)
          Text(judul, style: const TextStyle(fontWeight: FontWeight.w700)),
        ...anak,
      ],
    ),
  );

  Widget _infoHp(String label) =>
      BarisInfo(label, samarHp(_hpKini), mono: true, berat: FontWeight.w500);

  Widget _penolakan(String tindakan, String sebab) => Penolakan(
    tindakan: tindakan,
    sebab: sebab,
    jalan: const [],
    ukuranTeks: 14,
  );

  /// The conditional button and its "Batalkan", in one button row.
  Widget _baris(String label, String Function() alasan, VoidCallback aksi) =>
      BarisTombol(
        anak: [
          TombolBersyarat(
            label: label,
            tindakan: label,
            alasan: alasan(),
            periksa: alasan,
            sudahMulai: false,
            onPressed: aksi,
          ),
          _tombolTeks('Batalkan', () => _ke(_V.akun)),
        ],
      );

  Widget _isianKode() => IsianAlur(
    label: 'Kode 6 angka',
    controller: _kode,
    onChanged: (_) => setState(() {}),
    petunjuk: '••••••',
    keyboard: TextInputType.number,
    formatter: [_AngkaSaja(6)],
  );

  List<Widget> _akun(BuildContext context) {
    final c = context.warna;
    final em = _emKini;
    return [
      if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
      _kartu(judul: _nama, [
        _infoHp('Nomor ponsel'),
        BarisInfo('Email cadangan', samarEmail(em)),
        const BarisInfo('Jabatan', _jabatan),
        _kecil(
          context,
          'Nomor ponsel dipakai untuk masuk. Email cadangan tidak wajib; '
          'dipakai hanya untuk pemulihan akun bila nomor hilang. Tanpa email, '
          'akun dipulihkan Operator setelah Penatua Kolom memastikan identitas Anda.',
        ),
        _kecil(
          context,
          'Jabatan ditugaskan oleh Pimpinan Jemaat yang berwenang; tidak diubah dari sini.',
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _kedua('Ganti nomor ponsel', _keGanti),
            _kedua(
              em.isNotEmpty ? 'Ganti email cadangan' : 'Tambah email cadangan',
              _keEmail,
            ),
          ],
        ),
      ]),
      _kartu(judul: 'Perangkat yang masuk', [
        const BarisInfo('Perangkat ini', 'sedang dipakai'),
        for (final (i, d) in _dev.indexed)
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: Text(d, style: TextStyle(fontSize: 14, color: c.tinta2)),
              ),
              _tombolTeks(
                'Keluarkan',
                () => setState(() {
                  _dev = [..._dev]..removeAt(i);
                  _pesan = 'Perangkat itu dikeluarkan. Ia harus masuk lagi dengan kode baru.';
                }),
              ),
            ],
          ),
      ]),
      BarisTombol(
        anak: [_kedua('Keluar', () => _ke(_V.keluar), lebarPenuh: true)],
      ),
      _kartu(judul: 'Pemberitahuan dorong', [
        if (_izin == '' || _izin == 'minta') ...[
          _biasa(
            context,
            'Supaya Anda tahu ada pekerjaan baru tanpa membuka aplikasi.',
          ),
          BarisTombol(
            anak: [
              Tombol(
                'Izinkan pemberitahuan',
                onPressed: () => _izinkan('minta'),
                jenis: JenisTombol.tinta,
              ),
            ],
          ),
        ],
        if (_izin == 'tolak')
          Kartu(
            status: GarisStatus.draf,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Pemberitahuan dorong mati di pengaturan ponsel.',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: c.tinta,
                    ),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text:
                        'Pekerjaan tetap tampil di Beranda dan Pemberitahuan.',
                    style: TextStyle(color: c.tinta2),
                  ),
                ],
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        if (_izin == 'ya') ...[
          for (final m in _modul) _barisModul(context, m),
          const PratinjauLayarKunci(
            modul: 'Data jemaat',
            jumlah: 1,
            jenis: 'data menunggu verifikasi',
          ),
        ],
      ]),
      _kecil(
        context,
        'Bila pemberitahuan dorong gagal terkirim, pekerjaan di aplikasi tetap berjalan.',
      ),
      if (_riw.isNotEmpty) RiwayatAlur(baris: _riw),
    ];
  }

  Widget _barisModul(BuildContext context, String m) {
    final on = !_mati.contains(m);
    return Container(
      padding: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.warna.garis)),
      ),
      child: Row(
        spacing: 12,
        children: [
          Expanded(child: Text(m, style: const TextStyle(fontSize: 15))),
          Tekan(
            onTap: () => setState(
              () => _mati = on
                  ? [..._mati, m]
                  : [
                      for (final x in _mati)
                        if (x != m) x,
                    ],
            ),
            peran: PeranTekan.sakelar,
            tercentang: on,
            label: m,
            radius: 22,
            child: ChipSatu(
              teks: on ? 'Aktif' : 'Mati',
              dipilih: on,
              onTap: null,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _ganti(BuildContext context) {
    final a = _alasanHp();
    return [
      _kartu([
        _infoHp('Nomor sekarang'),
        _kecil(
          context,
          'Kode dikirim ke nomor yang baru, supaya terbukti nomor itu milik Anda.',
        ),
      ]),
      IsianAlur(
        label: 'Nomor ponsel baru',
        controller: _hpBaru,
        onChanged: (_) => setState(() {}),
        petunjuk: '08…',
        keterangan: 'Contoh: 081298765432',
        keyboard: TextInputType.phone,
        formatter: [_AngkaSaja(13)],
      ),
      if (_hpBaru.text.isNotEmpty && a.isNotEmpty)
        _penolakan('Kirim kode ke nomor baru', a),
      _baris(
        'Kirim kode ke nomor baru',
        _alasanHp,
        () => _kirimKode(_V.kodeBaru),
      ),
    ];
  }

  List<Widget> _kodeBaru(BuildContext context) => [
    _biasa(
      context,
      'Kode 6 angka dikirim ke ${_hpBaru.text}. Kode hanya berlaku sebentar dan sekali pakai.',
    ),
    _isianKode(),
    if (_sebabKode.isNotEmpty) _penolakan('Ganti nomor ponsel', _sebabKode),
    _kecil(
      context,
      'Setelah diganti, nomor lama tidak dapat dipakai untuk masuk dan perangkat lain dikeluarkan.',
    ),
    _baris('Ganti nomor ponsel', _alasanKode, _gantiNomor),
  ];

  List<Widget> _email(BuildContext context) {
    final a = _alasanEm();
    return [
      _kartu([
        BarisInfo('Email cadangan sekarang', samarEmail(_emKini)),
        _kecil(
          context,
          'Kode dikirim ke email itu, supaya terbukti email itu milik Anda.',
        ),
      ]),
      IsianAlur(
        label: 'Email cadangan',
        controller: _emBaru,
        onChanged: (_) => setState(() {}),
        petunjuk: 'nama@contoh.id',
        keterangan: 'Tidak wajib. Dipakai hanya untuk pemulihan akun.',
        keyboard: TextInputType.emailAddress,
      ),
      if (_emBaru.text.isNotEmpty && a.isNotEmpty)
        _penolakan('Kirim kode ke email', a),
      _baris('Kirim kode ke email', _alasanEm, () => _kirimKode(_V.kodeEmail)),
    ];
  }

  List<Widget> _kodeEmail(BuildContext context) => [
    _biasa(
      context,
      'Kode 6 angka dikirim ke ${_emBaru.text}. Kode hanya berlaku sebentar dan sekali pakai.',
    ),
    _isianKode(),
    if (_sebabKode.isNotEmpty) _penolakan('Simpan email cadangan', _sebabKode),
    _baris('Simpan email cadangan', _alasanKode, _simpanEm),
  ];

  List<Widget> _keluar(BuildContext context) => [
    _kartu([
      const Text(
        'Keluar dari perangkat ini?',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
      _biasa(
        context,
        'Isian yang belum tersimpan di layar akan hilang. Data yang sudah tersimpan tidak berubah.',
      ),
    ]),
    BarisTombol(
      anak: [
        const Tombol(
          'Keluar',
          onPressed: null,
          jenis: JenisTombol.tinta,
          ke: 'AlurMasuk',
          cara: Cara.ganti,
        ),
        _tombolTeks('Batal', () => _ke(_V.akun)),
      ],
    ),
  ];
}

/// The board's `value.replace(/\D/g, '').slice(0, maks)`: digits only, then
/// the end is cut, so typing into a full field keeps the new digit (Flutter's
/// LengthLimitingTextInputFormatter would refuse it).
class _AngkaSaja extends TextInputFormatter {
  _AngkaSaja(this.maks);

  final int maks;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue lama,
    TextEditingValue baru,
  ) {
    final t = baru.text.replaceAll(RegExp(r'\D'), '');
    final s = t.length > maks ? t.substring(0, maks) : t;
    if (s == baru.text) return baru;
    final ujung = baru.selection.end.clamp(0, baru.text.length);
    final kursor = baru.text
        .substring(0, ujung)
        .replaceAll(RegExp(r'\D'), '')
        .length
        .clamp(0, s.length);
    return TextEditingValue(
      text: s,
      selection: TextSelection.collapsed(offset: kursor),
    );
  }
}
