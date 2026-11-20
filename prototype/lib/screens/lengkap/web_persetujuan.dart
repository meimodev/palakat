import 'package:flutter/material.dart';

import '../../mock/format.dart';
import '../../motion/kerangka.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/isian_alasan.dart';
import '../../widgets/kartu_persetujuan.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';

/// One approval record of the board's `rec` list; [id] keys its history card.
class _Rec {
  _Rec(this.id, this.nama, this.jab, this.tgl, this.oleh);
  final int id;
  final String nama, jab, tgl, oleh;
  final String cara = 'notulen rapat';
  bool berlaku = true;
  String cat = '';
}

/// Web · Persetujuan: ganti catatan dan perubahan (spec 08, WebPersetujuan).
class WebPersetujuanScreen extends StatefulWidget {
  const WebPersetujuanScreen({super.key});

  @override
  State<WebPersetujuanScreen> createState() => _WebPersetujuanScreenState();
}

class _WebPersetujuanScreenState extends State<WebPersetujuanScreen> {
  int _jm = 2500000;
  String? _form; // null, 'ganti' or 'catat'
  bool _peringatan = false;
  int _id = 1;
  final _nama = TextEditingController();
  final _jab = TextEditingController(text: 'Ketua BPMJ');
  final _alasan = TextEditingController();
  final _rec = [
    _Rec(
      0,
      'Pdt. Lidya Rondonuwu',
      'Ketua BPMJ',
      '08/11/2026',
      '16/11/2026 11.20',
    ),
  ];

  @override
  void dispose() {
    _nama.dispose();
    _jab.dispose();
    _alasan.dispose();
    super.dispose();
  }

  _Rec? get _cur => _rec.where((r) => r.berlaku).firstOrNull;
  bool get _ganti => _form == 'ganti';

  /// The first unmet condition, '' when the submit may run.
  String get _alasanTolak => _nama.text.trim().isEmpty
      ? 'Pemberi persetujuan belum diisi'
      : _ganti && _alasan.text.trim().isEmpty
      ? 'Alasan mengganti belum diisi'
      : '';

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
    if (_alasanTolak.isNotEmpty) return;
    setState(() {
      for (final r in _rec.where((r) => r.berlaku)) {
        r
          ..berlaku = false
          ..cat =
              'Digantikan 16/11/2026 11.45 · alasan: ${_alasan.text.trim()}';
      }
      _rec.insert(
        0,
        _Rec(
          _id++,
          _nama.text.trim(),
          _jab.text,
          '16/11/2026',
          '16/11/2026 11.45',
        ),
      );
      _form = null;
    });
  }

  void _ubah() => setState(() {
    for (final r in _rec.where((r) => r.berlaku)) {
      r
        ..berlaku = false
        ..cat =
            'Tidak berlaku lagi sejak 16/11/2026 11.50 · jumlah diubah dari '
            'Rp2.500.000 menjadi Rp2.750.000';
    }
    _jm = 2750000;
    _peringatan = false;
  });

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final cur = _cur;
    final lama = _rec.where((r) => !r.berlaku).toList();

    Widget muncul(Key key, Widget child) => Gerak(
      Kerangka.muncul,
      key: key,
      lama: const Duration(milliseconds: 300),
      child: child,
    );

    Widget tombol(String label, VoidCallback onTap, JenisTombol jenis) =>
        Tombol(
          label,
          onPressed: onTap,
          jenis: jenis,
          ukuran: UkuranTombol.ringkas,
          lebarPenuh: false,
        );

    Widget kolom(double jarak, List<Widget> anak) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: jarak,
      children: anak,
    );

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
        style: TextStyle(fontSize: 14, color: c.tinta2),
      ),
    );

    final tolak = _alasanTolak;
    final ok = tolak.isEmpty;
    final judulForm = _ganti
        ? 'Ganti catatan persetujuan'
        : 'Catat persetujuan';

    final draf = Kartu(
      status: GarisStatus.draf,
      radius: 16,
      padding: const EdgeInsets.all(18),
      child: kolom(6, [
        const Align(
          alignment: Alignment.centerLeft,
          child: LencanaStatus(
            'Draf · belum masuk saldo',
            bentuk: BentukLencana.draf,
          ),
        ),
        Text(
          rp(-_jm),
          style: TextStyle(
            fontFamily: PalakatText.mono,
            fontSize: 30,
            fontWeight: FontWeight.w500,
            color: c.tinta2,
          ),
        ),
        const Text(
          'Perbaikan sound system',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        Text(
          'Bank BNI ··4821 · Belanja 5.08.02.00 Pemeliharaan gedung · '
          '16 November 2026',
          style: TextStyle(fontSize: 13, color: c.tinta3),
        ),
        Text(
          'Aturan: persetujuan wajib untuk Belanja Rp2.000.000 ke atas',
          style: TextStyle(fontSize: 13, color: c.tinta3),
        ),
      ]),
    );

    final kanan = kolom(14, [
      if (cur != null)
        KartuPersetujuan.sudah(
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
            child: kolom(0, [
              Text(
                'Persetujuan di luar aplikasi',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
              Text(
                'Persetujuan belum dicatat',
                style: TextStyle(fontWeight: FontWeight.w700, color: c.bata),
              ),
              Text(
                'Draf ini belum dapat dibukukan sampai persetujuan untuk '
                'jumlah yang baru dicatat.',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ]),
          ),
        ),
      if (_peringatan)
        muncul(
          const ValueKey('peringatan'),
          Kartu(
            status: GarisStatus.terpilih,
            padding: const EdgeInsets.all(16),
            child: kolom(10, [
              const Text(
                'Mengubah jumlah membuat persetujuan tidak berlaku',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              Text(
                'Persetujuan dicatat untuk Rp2.500.000. Perubahan pada jumlah, '
                // Word joiner: Chrome does not break after this slash.
                'pihak yang dibayar, Kas/⁠Bank, peruntukan, Mata Anggaran, '
                'tanggal atau uraian mengembalikannya ke belum dicatat.',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  tombol('Ubah menjadi Rp2.750.000', _ubah, JenisTombol.tinta),
                  tombol('Kembali', _batal, JenisTombol.kedua),
                ],
              ),
            ]),
          ),
        ),
      if (_form != null)
        muncul(
          ValueKey('form-$_form'),
          // TextField would otherwise add Material's 0.5 letter spacing to
          // the typed text and the hint; the board's inputs inherit none.
          DefaultTextStyle.merge(
            style: const TextStyle(letterSpacing: 0),
            child: Kartu(
              padding: const EdgeInsets.all(16),
              child: kolom(10, [
                kolom(0, [
                  Text(
                    judulForm,
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
                    style: TextStyle(fontSize: 14, color: c.tinta2),
                  ),
                ]),
                kolom(0, [
                  label('Pemberi persetujuan', wajib: true),
                  IsianTeks(
                    controller: _nama,
                    labelSemantik: 'Pemberi persetujuan',
                    onChanged: (_) => setState(() {}),
                  ),
                ]),
                kolom(0, [
                  label('Jabatan'),
                  IsianTeks(
                    controller: _jab,
                    labelSemantik: 'Jabatan',
                    onChanged: (_) => setState(() {}),
                  ),
                ]),
                if (_ganti)
                  // The inline-block textarea leaves the line box's descender gap
                  // (4.75 px) below it in its div, as on the board.
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.75),
                    child: IsianAlasan(
                      controller: _alasan,
                      onChanged: (_) => setState(() {}),
                      label: 'Alasan mengganti',
                      contoh: 'Contoh: nama pemberi persetujuan keliru',
                    ),
                  ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Board: no refusal sentence, the "· wajib" labels are the
                    // cue; the reason is the Semantics hint (spec Notes).
                    TekanAria(
                      onTap: _simpan,
                      aktif: ok,
                      petunjuk: ok ? null : tolak,
                      radius: 12,
                      child: RupaTombol(
                        label: judulForm,
                        isi: ok ? c.laut : c.garis,
                        warnaTeks: ok ? c.diLaut : c.tinta3,
                        radius: 12,
                        tinggi: 46,
                        paddingH: 20,
                        lebarPenuh: false,
                      ),
                    ),
                    tombol('Kembali', _batal, JenisTombol.kedua),
                  ],
                ),
              ]),
            ),
          ),
        ),
      if (_form == null && !_peringatan)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (cur != null)
              tombol(
                'Ganti catatan persetujuan',
                () => _buka('ganti'),
                JenisTombol.kedua,
              ),
            if (cur == null)
              tombol(
                'Catat persetujuan',
                () => _buka('catat'),
                JenisTombol.utama,
              ),
            if (_jm == 2500000)
              tombol(
                'Ubah jumlah',
                () => setState(() {
                  _peringatan = true;
                  _form = null;
                }),
                JenisTombol.kedua,
              ),
          ],
        ),
      if (lama.isNotEmpty)
        kolom(8, [
          const Text(
            'Riwayat persetujuan',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          for (final r in lama)
            muncul(
              ValueKey('lama-${r.id}'),
              Kartu(
                status: GarisStatus.draf,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: kolom(0, [
                  Text(
                    '${r.nama}, ${r.jab} · ${r.tgl} · dicatat ${r.oleh}',
                    style: TextStyle(fontSize: 14, color: c.tinta2),
                  ),
                  Text(
                    r.cat,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ]),
              ),
            ),
        ]),
    ]);

    // CSS puts half the leading above and half below each line; Flutter's
    // default (proportional) sets glyphs lower than the board does.
    return DefaultTextHeightBehavior(
      textHeightBehavior: const TextHeightBehavior(
        leadingDistribution: TextLeadingDistribution.even,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: HalamanWeb(
          jabatanKosong: true,
          nav: NavSamping(
            item: navKeuangan,
            aktif: 1,
            pengguna: const PenggunaKeuangan(),
          ),
          isi: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // The 44 px target hangs below the line; the inline link sits in
                // the 15 / 1.45 line box of its div, as on the board.
                MarginNegatif(
                  bawah: 44 - 15 * 1.45,
                  child: Tautan(
                    ke: 'WebTransaksi',
                    cara: Cara.naik,
                    child: const TautanTeks('Transaksi', ukuran: 14),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Semantics(
                    header: true,
                    child: const Text(
                      'Persetujuan di luar aplikasi',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Text(
                  'Catatan yang keliru digantikan catatan baru, tidak diubah. '
                  'Perubahan pada transaksi membuat persetujuan perlu dicatat '
                  'lagi.',
                  style: TextStyle(fontSize: 14, color: c.tinta2),
                ),
              ],
            ),
            BarisLentur(
              jarak: 24,
              anak: [
                Lentur(dasar: 360, child: draf),
                Lentur(dasar: 440, tumbuh: 999, child: kanan),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
