import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/perangkat_prototipe.dart';
import '../../shell/tautan.dart';
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

const _hariT = '16/11/2026';
const _operator = 'Operator';
const _penatua = 'Penatua Kolom 7';
const _menunggu = 'Menunggu Penatua Kolom 7';
const _dipulihkan = 'Dipulihkan';
const _tidakDipastikan = 'Tidak dipastikan';

/// Web · Alur · Memulihkan akun anggota (spec 16, WebAlurPulihkan).
class WebAlurPulihkanScreen extends StatefulWidget {
  const WebAlurPulihkanScreen({super.key});

  @override
  State<WebAlurPulihkanScreen> createState() => _WebAlurPulihkanState();
}

class _WebAlurPulihkanState extends State<WebAlurPulihkanScreen> {
  final _nama = TextEditingController();
  final _hp = TextEditingController();
  String _akt = _operator, _cari = '', _st = '', _pesan = '';
  bool _kenal = false;
  List<String> _riw = const [];

  @override
  void dispose() {
    _nama.dispose();
    _hp.dispose();
    super.dispose();
  }

  void _set(VoidCallback f) => setState(f);

  void _catat(String t) => _riw = ['$_hariT · $t', ..._riw];

  static String _samar(String n) =>
      '${n.substring(0, 4)} ···· ${n.substring(n.length - 4)}';

  /// The board's `a`: first unmet reason of "Minta kepastian Penatua Kolom".
  String _sebab() {
    final hp = _hp.text;
    if (_cari != 'ya') return 'orangnya belum ditemukan.';
    if (hp.isEmpty) return 'nomor ponsel baru belum diisi.';
    if (!RegExp(r'^08\d{8,11}$').hasMatch(hp)) {
      return 'nomor ponsel tidak dikenali. Contoh: 081298765432.';
    }
    return '';
  }

  void _pick(String a) => _set(() {
    _akt = a;
    _pesan = '';
  });

  void _cariOrang() => _set(
    () => _cari = RegExp('novita', caseSensitive: false).hasMatch(_nama.text)
        ? 'ya'
        : 'tidak',
  );

  void _minta() => _set(() {
    _st = _menunggu;
    _pesan = 'Penatua Kolom 7 diberi tahu lewat Pemberitahuan.';
    _catat(
      'Pemulihan akun Novita Wenas diminta · nomor baru ${_samar(_hp.text)} · Yanti Sumual, Operator',
    );
  });

  void _pasti() => _set(() {
    _st = _dipulihkan;
    _kenal = false;
    _pesan = 'Identitas dipastikan. Nomor baru dipasang.';
    _catat(
      'Identitas Novita Wenas dipastikan · akun dipulihkan · Pnt. Hendrik Rumagit, Penatua Kolom 7',
    );
  });

  void _tolak() => _set(() {
    _st = _tidakDipastikan;
    _kenal = false;
    _pesan = 'Pemulihan tidak dijalankan.';
    _catat(
      'Identitas tidak dipastikan · pemulihan akun Novita Wenas tidak dijalankan · Pnt. Hendrik Rumagit, Penatua Kolom 7',
    );
  });

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final opr = _akt == _operator;
    final oIsi = opr && _st.isEmpty;

    final judul = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Inline link in a 15/1.45 line: the 44 target overhangs the line box.
        MarginNegatif(
          atas: 11,
          bawah: 11,
          child: Tautan(
            ke: 'WebCariOrang',
            cara: Cara.naik,
            child: const Center(
              widthFactor: 1,
              heightFactor: 1,
              child: TautanTeks('Cari orang', ukuran: 14),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Semantics(
          header: true,
          child: Text(
            'Alur · Memulihkan akun anggota',
            style: PalakatText.judulHalaman.copyWith(color: c.tinta),
          ),
        ),
        Text(
          'Untuk orang yang kehilangan nomor ponselnya dan tidak punya email cadangan',
          style: TextStyle(fontSize: 14, color: c.tinta2),
        ),
      ],
    );

    final blok = <Widget>[
      if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
      if (oIsi) _formOperator(c),
      if (opr && _st.isNotEmpty) _kartuStatus(c),
      if (!opr && _st == _menunggu) ..._antrePenatua(),
      if (!opr && _st != _menunggu)
        _kotakPutus('Tidak ada pemulihan akun yang menunggu Anda'),
      if (_riw.isNotEmpty) RiwayatAlur(baris: _riw),
    ];

    return AlatPrototipe(
      stem: 'WebAlurPulihkan',
      alat: [
        DilihatSebagai(
          pilihan: const [_operator, _penatua],
          terpilih: _akt,
          onPilih: _pick,
        ),
        if (oIsi) const Text('Di prototipe ini: Novita Wenas.'),
      ],
      child: HalamanWeb(
        nav: const NavSamping(
          item: navPlatform,
          aktif: 5,
          pengguna: PenggunaNav(tebal: 'Yanti Sumual', biasa: ' · Operator'),
        ),
        isi: [
          judul,
          Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < blok.length; i++) ...[
                    if (i > 0) const SizedBox(height: 16),
                    blok[i],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kolom(List<Widget> anak) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < anak.length; i++) ...[
        if (i > 0) const SizedBox(height: 12),
        anak[i],
      ],
    ],
  );

  Widget _kartu(List<Widget> anak) => Kartu(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: anak,
    ),
  );

  Widget _kotakPutus(String teks) => Kartu(
    status: GarisStatus.draf,
    child: Text(teks, style: const TextStyle(fontWeight: FontWeight.w700)),
  );

  Widget _formOperator(PalakatWarna c) {
    final sebab = _sebab();
    final tampilSebab =
        (_nama.text.isNotEmpty || _hp.text.isNotEmpty) && sebab.isNotEmpty;
    return BarisLentur(
      jarak: 28,
      jarakBaris: 20,
      anak: [
        Lentur(
          dasar: 420,
          tumbuh: 1.3,
          child: _kolom([
            IsianAlur(
              label: 'Nama orangnya',
              controller: _nama,
              petunjuk: 'Nama lengkap',
              onChanged: (_) => _set(() => _cari = ''),
            ),
            BarisTombol(
              anak: [
                Tombol(
                  'Cari orang',
                  onPressed: _cariOrang,
                  jenis: JenisTombol.kedua,
                  ukuran: UkuranTombol.sedang,
                ),
              ],
            ),
            if (_cari == 'ya')
              _kartu([
                const KepalaKartu(
                  judul: 'Novita Wenas',
                  ujung: LencanaStatus('Aktif', bentuk: BentukLencana.laut),
                ),
                const BarisInfo('Kolom', 'Kolom 7'),
                const BarisInfo(
                  'Nomor lama',
                  '0812 ···· 7741',
                  mono: true,
                  berat: FontWeight.w500,
                ),
                const BarisInfo('Email cadangan', 'Belum diisi'),
              ]),
            if (_cari == 'tidak')
              _kotakPutus('Tidak ada orang dengan nama itu'),
          ]),
        ),
        Lentur(
          dasar: 340,
          child: _kolom([
            IsianAlur(
              label: 'Nomor ponsel baru',
              controller: _hp,
              petunjuk: '08…',
              keterangan: 'Nomor yang dibawa orangnya ke kantor gereja.',
              keyboard: TextInputType.phone,
              formatter: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(13),
              ],
              onChanged: (_) => _set(() {}),
            ),
            if (tampilSebab)
              Penolakan(
                tindakan: 'Minta kepastian Penatua Kolom',
                sebab: sebab,
                jalan: const [],
                ukuranTeks: 14,
              ),
            TombolBersyarat(
              label: 'Minta kepastian Penatua Kolom',
              tindakan: 'Minta kepastian Penatua Kolom',
              alasan: sebab,
              periksa: _sebab,
              onPressed: _minta,
              sudahMulai: false,
              baris: const [],
            ),
            Text(
              'Operator tidak memulihkan akun seorang diri, dan tidak memulihkan akunnya sendiri. Bendahara Jemaat dipulihkan lewat Petugas verifikasi bersama BPMJ.',
              style: TextStyle(fontSize: 13, color: c.tinta3),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _kartuStatus(PalakatWarna c) => _kartu([
    KepalaKartu(
      judul: 'Pemulihan akun · Novita Wenas',
      ujung: LencanaStatus(
        _st,
        bentuk: switch (_st) {
          _dipulihkan => BentukLencana.laut,
          _tidakDipastikan => BentukLencana.bata,
          _ => BentukLencana.garis,
        },
      ),
    ),
    Text(switch (_st) {
      _dipulihkan =>
        'Nomor baru dipasang $_hariT. Semua perangkat lama dikeluarkan. Novita Wenas masuk dengan kode ke nomor barunya.',
      _tidakDipastikan => 'Penatua Kolom 7 tidak memastikan identitasnya. Nomor lama tetap berlaku dan tidak ada yang berubah.',
      _ =>
        'Diminta $_hariT · menunggu Pnt. Hendrik Rumagit, Penatua Kolom 7. Nomor lama masih berlaku sampai dipastikan.',
    }, style: TextStyle(fontSize: 14, color: c.tinta2)),
  ]);

  List<Widget> _antrePenatua() {
    const sebab = 'centang dulu bahwa Anda sudah memastikan orangnya.';
    String periksa() => _kenal ? '' : sebab;
    return [
      _kartu([
        const KepalaKartu(
          judul: 'Pemulihan akun · Novita Wenas',
          ujung: LencanaStatus('Menunggu Anda', bentuk: BentukLencana.garis),
        ),
        const BarisInfo('Diminta oleh', 'Yanti Sumual, Operator'),
        BarisInfo(
          'Nomor ponsel baru',
          _samar(_hp.text.isEmpty ? '081298765432' : _hp.text),
          mono: true,
        ),
      ]),
      // The board's box has `margin: 2px 0 0`; the shared row has none, so
      // the row is drawn 2 lower and the sentence 2 back up (layout unchanged:
      // the row keeps its 44 min height, as the board's label).
      Transform.translate(
        offset: const Offset(0, 2),
        child: KotakCentang(
          nilai: _kenal,
          onUbah: (_) => _set(() => _kenal = !_kenal),
          label: Transform.translate(
            offset: const Offset(0, -2),
            child: const Text(
              'Saya sudah bertemu atau berbicara langsung dengan orang ini, dan nomor baru itu memang miliknya.',
            ),
          ),
        ),
      ),
      if (!_kenal)
        const Penolakan(
          tindakan: 'Pastikan identitas',
          sebab: sebab,
          jalan: [],
          ukuranTeks: 14,
        ),
      BarisTombol(
        anak: [
          TombolBersyarat(
            label: 'Pastikan identitas',
            tindakan: 'Pastikan identitas',
            alasan: periksa(),
            periksa: periksa,
            onPressed: _pasti,
            sudahMulai: false,
          ),
          Tombol(
            'Bukan orangnya',
            onPressed: _tolak,
            jenis: JenisTombol.kedua,
            ukuran: UkuranTombol.sedang,
          ),
        ],
      ),
    ];
  }
}
