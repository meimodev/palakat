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
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';

const _hariT = '16/11/2026';

/// 100 · Alur · Membentuk Panitia (23-alurunit.md): view `isi` (form) then
/// `ada` (Perencanaan → Aktif). No way back to the form.
class AlurPanitiaBaruScreen extends StatefulWidget {
  const AlurPanitiaBaruScreen({super.key});

  @override
  State<AlurPanitiaBaruScreen> createState() => _AlurPanitiaBaruState();
}

class _AlurPanitiaBaruState extends State<AlurPanitiaBaruScreen> {
  final _nama = TextEditingController();
  final _gulir = ScrollController();
  String _v = 'isi', _ketua = '', _sek = '', _bend = '', _dok = '', _st = '';
  String _pesan = '';
  List<String> _riw = [];

  @override
  void dispose() {
    _nama.dispose();
    _gulir.dispose();
    super.dispose();
  }

  /// The board's `a`: first unmet reason, '' when met.
  String _alasan() {
    final beda =
        'Ketua, Sekretaris dan Bendahara harus tiga orang yang berbeda.';
    if (_nama.text.trim().isEmpty) return 'nama Panitia belum diisi.';
    if (_ketua.isEmpty) return 'Ketua belum dipilih.';
    if (_sek.isEmpty) return 'Sekretaris belum dipilih.';
    if (_sek == _ketua) return beda;
    if (_bend.isEmpty) return 'Bendahara belum dipilih.';
    if (_bend == _ketua || _sek == _bend) return beda;
    if (_dok.isEmpty) return 'keputusan gereja belum dipilih.';
    if (_dok == 'Belum ada dokumen') {
      return 'pembentukan Panitia memerlukan keputusan tertulis gereja di Dokumen gereja.';
    }
    return '';
  }

  void _catat(String t) => _riw = ['$_hariT · $t', ..._riw];

  void _bentuk() {
    final n = _nama.text.trim();
    setState(() {
      _v = 'ada';
      _pesan = '';
      _st = 'Perencanaan';
      _catat(
        '$n dibentuk · Ketua $_ketua, Sekretaris $_sek, Bendahara $_bend · '
        '$_dok · Pdt. Lidya Rondonuwu',
      );
    });
    if (_gulir.hasClients) _gulir.jumpTo(0);
  }

  void _aktifkan() => setState(() {
    _st = 'Aktif';
    _pesan = 'Ketua, Sekretaris dan Bendahara Panitia diberi tahu lewat Pemberitahuan.';
    _catat('${_nama.text.trim()} Aktif · peruntukan dibuat');
  });

  Widget _pil(
    String label,
    List<String> a,
    String nilai,
    void Function(String) set,
  ) => ChipPilihan<String>(
    label: label,
    jarakLabel: 6,
    jarakBawah: 0,
    // Flutter sets "SK BPMJ No. 15/2026" + "Belum ada dokumen" 350.1 wide
    // (Chrome under 350); 0.05 less padding keeps the board's single line.
    padding: 13.95,
    pilihan: [for (final n in a) (nilai: n, teks: n)],
    terpilih: nilai.isEmpty ? null : nilai,
    onPilih: (n) => setState(() {
      _pesan = '';
      set(n);
    }),
  );

  List<Widget> _isi() {
    final a = _alasan();
    final mulai =
        _nama.text.isNotEmpty ||
        _ketua.isNotEmpty ||
        _sek.isNotEmpty ||
        _bend.isNotEmpty ||
        _dok.isNotEmpty;
    return [
      IsianAlur(
        label: 'Nama Panitia',
        controller: _nama,
        petunjuk: 'Contoh: Panitia Paskah 2027',
        onChanged: (_) => setState(() {}),
      ),
      _pil(
        'Ketua',
        const ['Stevi Lengkong', 'Rivo Mandagi'],
        _ketua,
        (n) => _ketua = n,
      ),
      _pil(
        'Sekretaris',
        const ['Natalia Rumengan', 'Stevi Lengkong'],
        _sek,
        (n) => _sek = n,
      ),
      _pil(
        'Bendahara',
        const ['Rivo Mandagi', 'Stevi Lengkong'],
        _bend,
        (n) => _bend = n,
      ),
      _pil(
        'Keputusan gereja',
        const ['SK BPMJ No. 15/2026', 'Belum ada dokumen'],
        _dok,
        (n) => _dok = n,
      ),
      if (mulai && a.isNotEmpty)
        Penolakan(
          tindakan: 'Bentuk Panitia',
          sebab: a,
          jalan: const [],
          ukuranTeks: 14,
        ),
      TombolBersyarat(
        label: 'Bentuk Panitia',
        tindakan: 'Bentuk Panitia',
        alasan: a,
        periksa: _alasan,
        onPressed: _bentuk,
        sudahMulai: false,
        baris: const [],
      ),
    ];
  }

  List<Widget> _ada(BuildContext context) {
    final c = context.warna;
    final aktif = _st == 'Aktif';
    final n = _nama.text.trim();
    return [
      if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
      Kartu(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KepalaKartu(
              judul: _nama.text,
              ujung: LencanaStatus(
                _st,
                bentuk: aktif ? BentukLencana.laut : BentukLencana.draf,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Ketua: $_ketua · Sekretaris: $_sek · Bendahara: $_bend',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
            const SizedBox(height: 6),
            Text(
              aktif
                  ? 'Aktif sejak $_hariT · peruntukan $n dibuat.'
                  : 'Dibentuk $_hariT · keputusan: $_dok',
              style: TextStyle(fontSize: 13, color: c.tinta3),
            ),
          ],
        ),
      ),
      if (_st == 'Perencanaan') ...[
        Text(
          'Selama Perencanaan, Panitia belum dapat membukukan. Peruntukannya dibuat saat diaktifkan.',
          style: TextStyle(fontSize: 13, color: c.tinta3),
        ),
        BarisTombol(
          anak: [
            Tombol(
              'Aktifkan Panitia',
              jenis: JenisTombol.tinta,
              onPressed: _aktifkan,
            ),
          ],
        ),
      ],
      // The board's <a> are content-box: basis 150 + 35 and max 340 + 35, so
      // two never share a 350 line; each takes the full width, 48 + 3 high.
      if (aktif)
        const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TautanKedua('Tetapkan Kas/Bank Panitia', ke: 'KasUnit'),
            SizedBox(height: 8),
            _TautanKedua('Lihat penutupan Panitia', ke: 'AlurPanitia'),
          ],
        ),
      if (_riw.isNotEmpty) RiwayatAlur(baris: _riw),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final blok = _v == 'isi' ? _isi() : _ada(context);
    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Alur · Membentuk Panitia',
            anakJudul: 'Dari keputusan gereja sampai Panitia Aktif',
            kembaliKe: 'Panitia',
            labelKembali: 'Kembali ke Panitia',
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _gulir,
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
    );
  }
}

class _TautanKedua extends StatelessWidget {
  const _TautanKedua(this.label, {required this.ke});

  final String label, ke;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 51),
    child: Tombol(
      label,
      jenis: JenisTombol.kedua,
      ukuran: UkuranTombol.sedang,
      onPressed: null,
      ke: ke,
    ),
  );
}
