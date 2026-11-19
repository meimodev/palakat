import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../mock/format.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/perangkat_prototipe.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/riwayat_alur.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';

/// 60 · Alur · Memulihkan akun anggota (screens/16-alurmasuk.md): the
/// Operator asks, the Penatua Kolom 7 confirms. One view; four branches by
/// (`akt`, `st`). No timers, no motion.
class AlurPulihkanScreen extends StatefulWidget {
  const AlurPulihkanScreen({super.key});

  @override
  State<AlurPulihkanScreen> createState() => _AlurPulihkanState();
}

const _operator = 'Operator', _penatua = 'Penatua Kolom 7';
const _menunggu = 'Menunggu Penatua Kolom 7',
    _dipulihkan = 'Dipulihkan',
    _tidakDipastikan = 'Tidak dipastikan';

class _AlurPulihkanState extends State<AlurPulihkanScreen> {
  final _nama = TextEditingController(), _hp = TextEditingController();
  String _pesan = '', _akt = _operator, _cari = '', _st = '';
  bool _kenal = false;
  List<String> _riw = const [];

  @override
  void dispose() {
    _nama.dispose();
    _hp.dispose();
    super.dispose();
  }

  void _set(VoidCallback f) => setState(f);

  void _catat(String t) => _riw = ['$hariTeks · $t', ..._riw];

  /// "Minta kepastian Penatua Kolom": first unmet reason, from the latest input.
  String _alasan() {
    final hp = _hp.text;
    if (_cari != 'ya') return 'orangnya belum ditemukan.';
    if (hp.isEmpty) return 'nomor ponsel baru belum diisi.';
    if (!hpSah(hp)) return 'nomor ponsel tidak dikenali. Contoh: 081298765432.';
    return '';
  }

  String _alasan2() =>
      _kenal ? '' : 'centang dulu bahwa Anda sudah memastikan orangnya.';

  void _pick(String a) => _set(() {
    _akt = a;
    _pesan = '';
  });

  void _cariOrang() => _set(
    () => _cari = _nama.text.toLowerCase().contains('novita') ? 'ya' : 'tidak',
  );

  void _minta() => _set(() {
    _st = _menunggu;
    _pesan = 'Penatua Kolom 7 diberi tahu lewat Pemberitahuan.';
    _catat(
      'Pemulihan akun Novita Wenas diminta · nomor baru ${samarHp(_hp.text)} · '
      'Yanti Sumual, Operator',
    );
  });

  void _pasti() => _set(() {
    _st = _dipulihkan;
    _kenal = false;
    _pesan = 'Identitas dipastikan. Nomor baru dipasang.';
    _catat(
      'Identitas Novita Wenas dipastikan · akun dipulihkan · '
      'Pnt. Hendrik Rumagit, Penatua Kolom 7',
    );
  });

  void _tolak() => _set(() {
    _st = _tidakDipastikan;
    _kenal = false;
    _pesan = 'Pemulihan tidak dijalankan.';
    _catat(
      'Identitas tidak dipastikan · pemulihan akun Novita Wenas tidak '
      'dijalankan · Pnt. Hendrik Rumagit, Penatua Kolom 7',
    );
  });

  @override
  Widget build(BuildContext context) {
    final opr = _akt == _operator;
    final oIsi = opr && _st.isEmpty;
    final blok = <Widget>[
      if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
      if (oIsi) ..._formOperator(),
      if (opr && _st.isNotEmpty) _status(),
      if (!opr && _st == _menunggu) ..._antrean(),
      if (!opr && _st != _menunggu)
        const _KotakPutus('Tidak ada pemulihan akun yang menunggu Anda'),
      if (_riw.isNotEmpty) RiwayatAlur(baris: _riw),
    ];
    return AlatPrototipe(
      stem: 'AlurPulihkan',
      alat: [
        DilihatSebagai(
          pilihan: const [_operator, _penatua],
          terpilih: _akt,
          onPilih: _pick,
        ),
        if (oIsi) const Text('Di prototipe ini: Novita Wenas.'),
      ],
      child: LayarPonsel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const KepalaPonsel(
              judul: 'Alur · Memulihkan akun anggota',
              anakJudul:
                  'Untuk orang yang kehilangan nomor ponselnya dan tidak '
                  'punya email cadangan',
              kembaliKe: 'CariOrang',
              labelKembali: 'Kembali ke Cari orang',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (i, b) in blok.indexed) ...[
                      if (i > 0) const SizedBox(height: 16),
                      b,
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

  List<Widget> _formOperator() {
    final alasan = _alasan();
    return [
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
        Kartu(
          child: _Kolom([
            KepalaKartu(
              judul: 'Novita Wenas',
              ujung: const LencanaStatus('Aktif', bentuk: BentukLencana.laut),
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
        ),
      if (_cari == 'tidak')
        const _KotakPutus('Tidak ada orang dengan nama itu'),
      IsianAlur(
        label: 'Nomor ponsel baru',
        controller: _hp,
        petunjuk: '08…',
        keterangan: 'Nomor yang dibawa orangnya ke kantor gereja.',
        keyboard: TextInputType.phone,
        formatter: _hpFormat,
        onChanged: (_) => _set(() {}),
      ),
      if ((_nama.text.isNotEmpty || _hp.text.isNotEmpty) && alasan.isNotEmpty)
        Penolakan(
          tindakan: 'Minta kepastian Penatua Kolom',
          sebab: alasan,
          jalan: const [],
          ukuranTeks: 14,
        ),
      BarisTombol(
        anak: [
          TombolBersyarat(
            label: 'Minta kepastian Penatua Kolom',
            tindakan: 'Minta kepastian Penatua Kolom',
            alasan: alasan,
            periksa: _alasan,
            sudahMulai: false,
            onPressed: _minta,
          ),
        ],
      ),
      Text(
        'Operator tidak memulihkan akun seorang diri, dan tidak memulihkan '
        'akunnya sendiri. Bendahara Jemaat dipulihkan lewat Petugas '
        'verifikasi bersama BPMJ.',
        style: TextStyle(fontSize: 13, color: context.warna.tinta3),
      ),
    ];
  }

  Widget _status() {
    final (bentuk, ket) = switch (_st) {
      _dipulihkan => (
        BentukLencana.laut,
        'Nomor baru dipasang $hariTeks. Semua perangkat lama dikeluarkan. '
            'Novita Wenas masuk dengan kode ke nomor barunya.',
      ),
      _tidakDipastikan => (
        BentukLencana.bata,
        'Penatua Kolom 7 tidak memastikan identitasnya. Nomor lama tetap '
            'berlaku dan tidak ada yang berubah.',
      ),
      _ => (
        BentukLencana.garis,
        'Diminta $hariTeks · menunggu Pnt. Hendrik Rumagit, Penatua Kolom 7. '
            'Nomor lama masih berlaku sampai dipastikan.',
      ),
    };
    return Kartu(
      child: _Kolom([
        KepalaKartu(
          judul: 'Pemulihan akun · Novita Wenas',
          ujung: LencanaStatus(_st, bentuk: bentuk),
        ),
        Text(ket, style: TextStyle(fontSize: 14, color: context.warna.tinta2)),
      ]),
    );
  }

  List<Widget> _antrean() {
    final alasan2 = _alasan2();
    return [
      Kartu(
        child: _Kolom([
          const KepalaKartu(
            judul: 'Pemulihan akun · Novita Wenas',
            ujung: LencanaStatus('Menunggu Anda', bentuk: BentukLencana.garis),
          ),
          const BarisInfo('Diminta oleh', 'Yanti Sumual, Operator'),
          BarisInfo(
            'Nomor ponsel baru',
            samarHp(_hp.text.isEmpty ? '081298765432' : _hp.text),
            mono: true,
          ),
        ]),
      ),
      KotakCentang(
        nilai: _kenal,
        onUbah: (v) => _set(() => _kenal = v),
        label: Text(
          'Saya sudah bertemu atau berbicara langsung dengan orang ini, dan '
          'nomor baru itu memang miliknya.',
          style: TextStyle(color: context.warna.tinta),
        ),
      ),
      if (alasan2.isNotEmpty)
        Penolakan(
          tindakan: 'Pastikan identitas',
          sebab: alasan2,
          jalan: const [],
          ukuranTeks: 14,
        ),
      BarisTombol(
        anak: [
          TombolBersyarat(
            label: 'Pastikan identitas',
            tindakan: 'Pastikan identitas',
            alasan: alasan2,
            periksa: _alasan2,
            sudahMulai: false,
            onPressed: _pasti,
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

/// Phone number input: digits only, at most 13.
final _hpFormat = <TextInputFormatter>[
  FilteringTextInputFormatter.digitsOnly,
  LengthLimitingTextInputFormatter(13),
];

/// Card content: a column with gap 6.
class _Kolom extends StatelessWidget {
  const _Kolom(this.anak);
  final List<Widget> anak;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      for (final (i, a) in anak.indexed) ...[
        if (i > 0) const SizedBox(height: 6),
        a,
      ],
    ],
  );
}

/// Dashed box holding one 700 line.
class _KotakPutus extends StatelessWidget {
  const _KotakPutus(this.teks);
  final String teks;

  @override
  Widget build(BuildContext context) => Kartu(
    status: GarisStatus.draf,
    child: Text(teks, style: const TextStyle(fontWeight: FontWeight.w700)),
  );
}
