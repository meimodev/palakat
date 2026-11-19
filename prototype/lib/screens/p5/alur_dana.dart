import 'package:flutter/material.dart';

import '../../mock/format.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/perangkat_prototipe.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/input_format.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/riwayat_alur.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import 'alur_dana_bagian.dart';

const _hari = '16/11/2026';
const _komisi = 'Ketua Komisi Diakonia';
const _ketua = 'Ketua Jemaat';
const _bendahara = 'Bendahara Jemaat';
const _menunggu = 'Menunggu persetujuan';
const _disetujui = 'Disetujui';
const _dibukukan = 'Dibukukan';
const _ditolak = 'Tidak disetujui';

/// 95 · Alur · Permintaan dana (screens/23-alurunit.md, AlurDana).
class AlurDanaScreen extends StatefulWidget {
  const AlurDanaScreen({super.key});

  @override
  State<AlurDanaScreen> createState() => _AlurDanaScreenState();
}

class _AlurDanaScreenState extends State<AlurDanaScreen> {
  final _gulir = ScrollController();
  final _perlu = TextEditingController();
  final _jml = TextEditingController();
  final _alasan = TextEditingController();

  String _pesan = '', _v = 'utama', _akt = _komisi, _st = '', _tolak = '';
  final List<String> _riw = [];

  @override
  void dispose() {
    for (final c in [_gulir, _perlu, _jml, _alasan]) {
      c.dispose();
    }
    super.dispose();
  }

  String get _digit => hanyaAngka(_jml.text, simpanNol: true);

  /// The board's `a`: first unmet reason of "Ajukan permintaan".
  String _sebab() => _perlu.text.trim().isEmpty
      ? 'keperluan belum diisi.'
      : ((int.tryParse(_digit) ?? 0) <= 0 ? 'jumlah belum diisi.' : '');

  /// The board's dead `al && !al` refusal: only the hint is announced.
  String _sebabTolak() =>
      _alasan.text.trim().isEmpty ? 'Alasan · wajib belum diisi' : '';

  void _ubah(VoidCallback f, {bool keAtas = false}) {
    setState(f);
    if (keAtas && _gulir.hasClients) _gulir.jumpTo(0);
  }

  void _catat(String t) => _riw.insert(0, '$_hari · $t');

  void _pilihAktor(String a) => _ubah(() {
    _akt = a;
    _pesan = '';
  }, keAtas: true);

  void _ajukan() => _ubah(() {
    _st = _menunggu;
    _pesan = 'Ketua Jemaat diberi tahu lewat Pemberitahuan.';
    _catat(
      'Permintaan dana ${rpDigit(_digit)} · ${_perlu.text.trim()} diajukan · '
      'Pnt. Hendrik Rumagit, Ketua Komisi Diakonia',
    );
  });

  void _setuju() => _ubah(() {
    _st = _disetujui;
    _pesan = '';
    _catat('Permintaan dana Disetujui oleh Pdt. Lidya Rondonuwu, Ketua Jemaat');
  });

  void _keTolak() => _ubah(() {
    _v = 'tolak';
    _pesan = '';
    _alasan.clear();
  }, keAtas: true);

  void _pulang() => _ubah(() {
    _v = 'utama';
    _pesan = '';
  }, keAtas: true);

  void _tolakkan() {
    final al = _alasan.text.trim();
    _ubah(() {
      _st = _ditolak;
      _v = 'utama';
      _tolak = al;
      _alasan.clear();
      _pesan = '';
      _catat(
        'Permintaan dana tidak disetujui · alasan: $al · Pdt. Lidya Rondonuwu',
      );
    }, keAtas: true);
  }

  void _bayar() => _ubah(() {
    _st = _dibukukan;
    _pesan = '';
    _catat(
      'Uang Muka diberikan ${rpDigit(_digit)} dibukukan · '
      'Meiske Lumentut, Bendahara Jemaat',
    );
  });

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final pem = _akt == _komisi, ket = _akt == _ketua, ben = _akt == _bendahara;
    final tunggu = _st == _menunggu,
        setuju = _st == _disetujui,
        bayar = _st == _dibukukan;
    final sebab = _sebab();

    final isi = <Widget>[
      if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
      if (pem && (_st.isEmpty || _st == _ditolak)) ...[
        IsianAlur(
          label: 'Keperluan',
          controller: _perlu,
          petunjuk: 'Contoh: Kunjungan diakonia Desember',
          onChanged: (_) => setState(() {}),
        ),
        IsianAlur(
          label: 'Jumlah (Rp)',
          controller: _jml,
          petunjuk: '0',
          keterangan: rpDigit(_digit),
          keyboard: TextInputType.number,
          formatter: const [RupiahInputFormatter(sisakanNol: true)],
          onChanged: (_) => setState(() {}),
        ),
        const BarisInfo('Diambil dari peruntukan', 'Diakonia'),
        if (_st == _ditolak) _catatan('Tidak disetujui.', _tolak),
        if ((_perlu.text.isNotEmpty || _jml.text.isNotEmpty) &&
            sebab.isNotEmpty)
          Penolakan(
            tindakan: 'Ajukan',
            sebab: sebab,
            jalan: const [],
            ukuranTeks: 14,
          ),
        BarisTombol(
          anak: [
            TombolBersyarat(
              label: 'Ajukan permintaan',
              tindakan: 'Ajukan',
              alasan: sebab,
              periksa: _sebab,
              sudahMulai: false,
              onPressed: _ajukan,
            ),
          ],
        ),
      ],
      if (_st.isNotEmpty && _st != _ditolak && !(ben && tunggu))
        Kartu(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 6,
            children: [
              KepalaLencanaDana(
                judul: 'Permintaan dana · ${_perlu.text}',
                label: setuju ? 'Disetujui oleh Pdt. Lidya Rondonuwu' : _st,
                bentuk: setuju
                    ? BentukLencana.laut
                    : (bayar ? BentukLencana.tinta : BentukLencana.draf),
              ),
              BarisInfoDana('Jumlah (Rp)', rpDigit(_digit), mono: true),
              const BarisInfoDana(
                'Diajukan oleh',
                'Pnt. Hendrik Rumagit, Ketua Komisi Diakonia',
              ),
              Text(
                bayar
                    ? 'Dibukukan Bendahara Jemaat sebagai Uang Muka diberikan, '
                          '$_hari. Pertanggungjawabannya dicatat pada kasus '
                          'Uang Muka.'
                    : (setuju
                          ? 'Disetujui di aplikasi oleh orang yang masuk '
                                'sendiri, $_hari.'
                          : 'Diajukan $_hari · menunggu Ketua Jemaat'),
                style: TextStyle(fontSize: 13, color: c.tinta3),
              ),
            ],
          ),
        ),
      if (pem && tunggu) ...[
        const Penolakan(
          tindakan: 'Setujui',
          sebab: 'permintaan ini Anda ajukan sendiri.',
          jalan: [],
        ),
        Text(
          'Menunggu Pdt. Lidya Rondonuwu, Ketua Jemaat.',
          style: TextStyle(fontSize: 13, color: c.tinta3),
        ),
      ],
      if (ket && tunggu && _v != 'tolak')
        BarisTombol(
          anak: [
            Tombol('Setujui', jenis: JenisTombol.tinta, onPressed: _setuju),
            Tombol(
              'Tidak disetujui',
              jenis: JenisTombol.kedua,
              ukuran: UkuranTombol.sedang,
              onPressed: _keTolak,
            ),
          ],
        ),
      if (ket && tunggu && _v == 'tolak') ...[
        IsianAlur(
          label: 'Alasan · wajib',
          controller: _alasan,
          baris: 3,
          onChanged: (_) => setState(() {}),
        ),
        BarisTombol(
          anak: [
            TombolBersyarat(
              label: 'Catat tidak disetujui',
              tindakan: 'Tidak disetujui',
              alasan: _sebabTolak(),
              periksa: _sebabTolak,
              sudahMulai: false,
              onPressed: _tolakkan,
            ),
            Tombol(
              'Kembali',
              jenis: JenisTombol.teks,
              ukuran: UkuranTombol.kecil,
              onPressed: _pulang,
            ),
          ],
        ),
      ],
      if (setuju)
        _catatan(
          'Disetujui bukan berarti sudah dibayar.',
          'Uang baru keluar ketika Bendahara Jemaat membukukannya.',
        ),
      if (ben && setuju)
        BarisTombol(
          anak: [
            Tombol(
              'Bukukan sebagai Uang Muka',
              jenis: JenisTombol.tinta,
              onPressed: _bayar,
            ),
          ],
        ),
      if (ben && !setuju && !bayar)
        Kartu(
          status: GarisStatus.draf,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 6,
            children: [
              const Text(
                'Belum ada yang perlu dibukukan',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                'Permintaan dana muncul di sini setelah Disetujui.',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ],
          ),
        ),
      if (_riw.isNotEmpty) RiwayatAlur(baris: _riw),
    ];

    return AlatPrototipe(
      stem: 'AlurDana',
      alat: [
        DilihatSebagai(
          pilihan: const [_komisi, _ketua, _bendahara],
          terpilih: _akt,
          onPilih: _pilihAktor,
        ),
      ],
      child: LayarPonsel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const KepalaPonsel(
              judul: 'Alur · Permintaan dana',
              anakJudul:
                  'Diajukan unit, disetujui Ketua Jemaat, dibukukan '
                  'Bendahara Jemaat',
              kembaliKe: 'PermintaanDana',
              labelKembali: 'Kembali ke Permintaan dana',
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _gulir,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: isi,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Dashed note: 12 14, 14 px, a bold lead, a space, the rest `tinta2`.
  Widget _catatan(String tebal, String biasa) => Kartu(
    status: GarisStatus.draf,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    child: Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: tebal,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const TextSpan(text: ' '),
          TextSpan(
            text: biasa,
            style: TextStyle(color: context.warna.tinta2),
          ),
        ],
      ),
      style: const TextStyle(fontSize: 14),
    ),
  );
}
