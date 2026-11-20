import 'package:flutter/widgets.dart';

import '../../core/format.dart';
import '../../motion/kerangka.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/isian_alasan.dart';
import '../../widgets/kartu_persetujuan.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';

/// One approval record of the board's `rec` list; [id] keeps each history
/// card's entrance to its own appearance.
typedef _Rek = ({
  int id,
  String nama,
  String jab,
  String tgl,
  String cara,
  String oleh,
  bool berlaku,
  String cat,
});

/// 29 · Persetujuan: ganti catatan, gugur karena perubahan (spec 08-cari.md,
/// Persetujuan). A wrong record is replaced, never edited; changing the
/// amount voids the approval.
class PersetujuanScreen extends StatefulWidget {
  const PersetujuanScreen({super.key});

  @override
  State<PersetujuanScreen> createState() => _PersetujuanScreenState();
}

class _PersetujuanScreenState extends State<PersetujuanScreen> {
  int _jm = 2500000;
  String? _form; // null, 'ganti', 'catat'
  bool _peringatan = false;
  int _idBaru = 1;
  List<_Rek> _rec = [
    (
      id: 0,
      nama: 'Pdt. Lidya Rondonuwu',
      jab: 'Ketua BPMJ',
      tgl: '08/11/2026',
      cara: 'notulen rapat',
      oleh: '16/11/2026 11.20',
      berlaku: true,
      cat: '',
    ),
  ];
  final _nama = TextEditingController();
  final _jab = TextEditingController(text: 'Ketua BPMJ');
  final _alasan = TextEditingController();

  @override
  void dispose() {
    _nama.dispose();
    _jab.dispose();
    _alasan.dispose();
    super.dispose();
  }

  bool get _ganti => _form == 'ganti';
  bool get _okNama => _nama.text.trim().isNotEmpty;
  bool get _ok => _okNama && (!_ganti || _alasan.text.trim().isNotEmpty);

  /// Every valid record becomes old with the note [cat].
  List<_Rek> _gugurkan(String cat) => [
    for (final r in _rec)
      r.berlaku
          ? (
              id: r.id,
              nama: r.nama,
              jab: r.jab,
              tgl: r.tgl,
              cara: r.cara,
              oleh: r.oleh,
              berlaku: false,
              cat: cat,
            )
          : r,
  ];

  void _buka(String form) => setState(() {
    _form = form;
    _nama.clear();
    _alasan.clear();
  });

  void _batal() => setState(() {
    _form = null;
    _peringatan = false;
  });

  void _simpan() {
    if (!_ok) return;
    setState(() {
      _rec = [
        (
          id: _idBaru++,
          nama: _nama.text.trim(),
          jab: _jab.text,
          tgl: '16/11/2026',
          cara: 'notulen rapat',
          oleh: '16/11/2026 11.45',
          berlaku: true,
          cat: '',
        ),
        ..._gugurkan(
          'Digantikan 16/11/2026 11.45 · alasan: ${_alasan.text.trim()}',
        ),
      ];
      _form = null;
    });
  }

  void _ubah() => setState(() {
    _rec = _gugurkan(
      'Tidak berlaku lagi sejak 16/11/2026 11.50 · jumlah diubah dari '
      'Rp2.500.000 menjadi Rp2.750.000',
    );
    _jm = 2750000;
    _peringatan = false;
  });

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final cur = _rec.where((r) => r.berlaku).firstOrNull;
    final lama = _rec.where((r) => !r.berlaku).toList();
    final tanpaForm = _form == null && !_peringatan;
    final s14 = TextStyle(fontSize: 14, color: c.tinta2);

    Widget muncul(Key key, Widget child) => Gerak(
      Kerangka.muncul,
      key: key,
      lama: const Duration(milliseconds: 300),
      child: child,
    );

    Widget tombol(
      String label,
      VoidCallback onPressed, {
      JenisTombol jenis = JenisTombol.kedua,
    }) => Tombol(
      label,
      onPressed: onPressed,
      jenis: jenis,
      ukuran: UkuranTombol.ringkas,
      lebarPenuh: false,
    );

    Widget deret(List<Widget> anak, {Key? key}) =>
        Wrap(key: key, spacing: 8, runSpacing: 8, children: anak);

    Widget label(String teks, {bool wajib = false}) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: teks),
            if (wajib)
              TextSpan(
                text: ' · wajib',
                style: TextStyle(color: c.tinta, fontWeight: FontWeight.w700),
              ),
          ],
        ),
        style: s14,
      ),
    );

    final isi = <Widget>[
      Kartu(
        key: const ValueKey('draf'),
        status: GarisStatus.draf,
        radius: 16,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LencanaStatus(
              'Draf · belum masuk saldo',
              bentuk: BentukLencana.draf,
            ),
            const SizedBox(height: 6),
            Text(
              rp(-_jm),
              style: TextStyle(
                fontFamily: PalakatText.mono,
                fontSize: 30,
                fontWeight: FontWeight.w500,
                color: c.tinta2,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Perbaikan sound system',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'Bank BNI ··4821 · Belanja 5.08.02.00 Pemeliharaan gedung · '
              '16 November 2026',
              style: TextStyle(fontSize: 13, color: c.tinta3),
            ),
            const SizedBox(height: 6),
            Text(
              'Aturan: persetujuan wajib untuk Belanja Rp2.000.000 ke atas',
              style: TextStyle(fontSize: 13, color: c.tinta3),
            ),
          ],
        ),
      ),
      if (cur != null)
        KartuPersetujuan.sudah(
          key: const ValueKey('ada'),
          kepala: 'Persetujuan di luar aplikasi',
          pemberi: cur.nama,
          jabatan: cur.jab,
          tanggal: cur.tgl,
          cara: cur.cara,
          dicatatOleh: 'Meiske L.',
          dicatatPada: cur.oleh,
        )
      else
        muncul(
          const ValueKey('belum'),
          Kartu(
            status: GarisStatus.draf,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Persetujuan di luar aplikasi', style: s14),
                Text(
                  'Persetujuan belum dicatat',
                  style: TextStyle(fontWeight: FontWeight.w700, color: c.bata),
                ),
                Text(
                  'Draf ini belum dapat dibukukan sampai persetujuan untuk '
                  'jumlah yang baru dicatat.',
                  style: s14,
                ),
              ],
            ),
          ),
        ),
      if (_peringatan)
        muncul(
          const ValueKey('peringatan'),
          Kartu(
            status: GarisStatus.terpilih,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Mengubah jumlah membuat persetujuan tidak berlaku',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Text(
                  'Persetujuan dicatat untuk Rp2.500.000. Perubahan pada '
                  'jumlah, pihak yang dibayar, Kas/Bank, peruntukan, Mata '
                  'Anggaran, tanggal atau uraian mengembalikannya ke belum '
                  'dicatat.',
                  style: s14,
                ),
                const SizedBox(height: 10),
                deret([
                  tombol(
                    'Ubah menjadi Rp2.750.000',
                    _ubah,
                    jenis: JenisTombol.tinta,
                  ),
                  tombol('Kembali', _batal),
                ]),
              ],
            ),
          ),
        ),
      if (_form != null)
        muncul(
          ValueKey('form-$_form'),
          Kartu(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _ganti ? 'Ganti catatan persetujuan' : 'Catat persetujuan',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _ganti
                      ? 'Catatan lama tidak diubah. Ia tetap ada di Riwayat '
                            'dengan tanda digantikan.'
                      : 'Anda mencatat persetujuan yang diberikan di luar '
                            'aplikasi.',
                  style: s14,
                ),
                const SizedBox(height: 10),
                label('Pemberi persetujuan', wajib: true),
                IsianTeks(
                  controller: _nama,
                  labelSemantik: 'Pemberi persetujuan · wajib',
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                label('Jabatan'),
                IsianTeks(
                  controller: _jab,
                  labelSemantik: 'Jabatan',
                  onChanged: (_) => setState(() {}),
                ),
                if (_ganti) ...[
                  const SizedBox(height: 10),
                  // The board's textarea is inline-block inside a div: the
                  // line's half-leading and descent (Plus Jakarta Sans
                  // descent 0.222 em, content 1.26 em) sit under it.
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 16 * (1.4 - 1.26) / 2 + 16 * 0.222,
                    ),
                    child: IsianAlasan(
                      controller: _alasan,
                      onChanged: (_) => setState(() {}),
                      label: 'Alasan mengganti',
                      contoh: 'Contoh: nama pemberi persetujuan keliru',
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                deret([
                  // No refusal sentence on the board; the hint names it.
                  Semantics(
                    hint: _ok
                        ? null
                        : !_okNama
                        ? 'Pemberi persetujuan belum diisi'
                        : 'Alasan mengganti belum diisi',
                    child: Tombol(
                      _ganti
                          ? 'Ganti catatan persetujuan'
                          : 'Catat persetujuan',
                      onPressed: _simpan,
                      nonaktif: !_ok,
                      ukuran: UkuranTombol.ringkas,
                      lebarPenuh: false,
                    ),
                  ),
                  tombol('Kembali', _batal),
                ]),
              ],
            ),
          ),
        ),
      if (tanpaForm)
        deret(key: const ValueKey('aksi'), [
          if (cur != null)
            tombol('Ganti catatan persetujuan', () => _buka('ganti'))
          else
            tombol(
              'Catat persetujuan',
              () => _buka('catat'),
              jenis: JenisTombol.utama,
            ),
          if (_jm == 2500000)
            tombol(
              'Ubah jumlah',
              () => setState(() {
                _peringatan = true;
                _form = null;
              }),
            ),
        ]),
      if (lama.isNotEmpty)
        Column(
          key: const ValueKey('riwayat'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: const Text(
                'Riwayat persetujuan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
            for (final r in lama) ...[
              const SizedBox(height: 8),
              muncul(
                ValueKey(r.id),
                Kartu(
                  status: GarisStatus.draf,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '${r.nama}, ${r.jab} · ${r.tgl} · dicatat ${r.oleh}',
                        style: s14,
                      ),
                      Text(
                        r.cat,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
    ];

    return LayarPonsel(
      layarKeuangan: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Persetujuan',
            anakJudul: 'Catatan yang keliru digantikan, tidak diubah',
            kembaliKe: Layar.keuangan,
            labelKembali: 'Kembali ke Beranda',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < isi.length; i++) ...[
                    if (i > 0) const SizedBox(height: 16),
                    isi[i],
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
