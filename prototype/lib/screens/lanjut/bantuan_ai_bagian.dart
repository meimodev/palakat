import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../motion/kerangka.dart';
import '../../motion/ulang.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';

/// The logic class shared by BantuanAI and WebBantuanAI (same state, same
/// handlers): `{ kalimat, tahap, dasar, dipakai }`.
class KeadaanBantuanAI extends ChangeNotifier {
  static const _awal = 'Bayar PLN Rp1.250.000 dari BNI tanggal 6 Oktober';

  final kalimat = TextEditingController(text: _awal);
  String tahap = 'belum', dasar = '';
  bool dipakai = false;
  Timer? _t;

  KeadaanBantuanAI() {
    kalimat.addListener(notifyListeners);
  }

  bool get basi => tahap == 'ada' && kalimat.text != dasar;

  void buat() {
    final d = kalimat.text;
    tahap = 'proses';
    _t?.cancel();
    _t = Timer(const Duration(milliseconds: 1300), () {
      tahap = 'ada';
      dasar = d;
      notifyListeners();
    });
    notifyListeners();
  }

  void pakai() {
    if (basi) return;
    dipakai = true;
    tahap = 'belum';
    notifyListeners();
  }

  void abaikan() {
    tahap = 'belum';
    notifyListeners();
  }

  @override
  void dispose() {
    _t?.cancel();
    kalimat.dispose();
    super.dispose();
  }
}

const _usul = [
  ('Jumlah (Rp)', 'Rp1.250.000', false),
  ('Kas/Bank', 'Bank BNI ··4821', false),
  ('Dibayar kepada', 'PLN', false),
  ('Tanggal transaksi', '6 Oktober 2026', false),
  ('Mata Anggaran', 'Belanja 5.01.02.00 Listrik, air dan telepon', true),
];

String simpanTeks(KeadaanBantuanAI s) =>
    s.dipakai ? 'Tersimpan · Draf' : 'Belum tersimpan';

/// The AI panel (`aiHidup`) or the AI-off box (`aiMati`) for [keadaanAI].
class PanelBantuanAI extends StatelessWidget {
  const PanelBantuanAI({
    super.key,
    required this.s,
    required this.keadaanAI,
    this.web = false,
  });

  final KeadaanBantuanAI s;
  final String keadaanAI;

  /// WebBantuanAI styles `input` but not `textarea`, so its sentence shows in
  /// the browser default: monospace 13.33 px, line height normal.
  final bool web;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final batas = keadaanAI == 'batas biaya tercapai';
    if (batas || keadaanAI == 'sedang tidak tersedia') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: ShapeDecoration(
          shape: GarisBorder.penuh(c.garisTegas, tebal: 1, radius: 14),
        ),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: batas
                    ? 'Batas biaya AI per bulan tercapai.'
                    : 'AI sedang tidak tersedia.',
                style: TextStyle(fontWeight: FontWeight.w700, color: c.tinta),
              ),
              TextSpan(
                text: batas
                    ? ' Bantuan AI berhenti sampai Desember 2026. Mencatat, membukukan dan tutup buku berjalan seperti biasa.'
                    : ' Mencatat, membukukan dan tutup buku berjalan seperti biasa.',
              ),
            ],
          ),
          style: TextStyle(fontSize: 14, color: c.tinta2),
        ),
      );
    }

    final judul = Text(
      'BANTUAN AI · PILIHAN',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: c.lautTua,
        letterSpacing: .3,
      ),
    );
    final label = keadaanAI == 'biaya 70%'
        ? _BarisSusut(
            jarak: 8,
            tengah: true,
            kiri: judul,
            kanan: Text(
              'Biaya AI bulan ini 70% dari batas',
              style: TextStyle(fontSize: 13, color: c.tinta),
            ),
          )
        : Align(alignment: Alignment.centerLeft, child: judul);

    final anak = <Widget>[
      label,
      _Kalimat(controller: s.kalimat, web: web),
      if (s.tahap == 'belum')
        Tombol(
          'Buat usulan dari kalimat ini',
          onPressed: s.buat,
          jenis: JenisTombol.garisLaut,
          ukuran: UkuranTombol.kecil,
          warnaTeks: c.lautTua,
        ),
      if (s.tahap == 'proses')
        Semantics(
          liveRegion: true,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Row(
              children: [
                Text(
                  'Menyusun usulan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: c.lautTua,
                  ),
                ),
                const SizedBox(width: 8),
                const TitikAI(),
              ],
            ),
          ),
        ),
      if (s.tahap == 'ada') ...[
        Gerak(
          Kerangka.muncul,
          key: const ValueKey('ada'),
          lama: const Duration(milliseconds: 300),
          child: _KartuUsulan(),
        ),
        if (s.basi)
          const Text(
            'Usulan lama — draf sudah berubah. Buat usulan baru bila masih perlu.',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        Row(
          children: [
            for (final (i, (t, f, j)) in [
              ('Pakai', s.pakai, JenisTombol.utama),
              ('Ubah', s.pakai, JenisTombol.kedua),
              ('Abaikan', s.abaikan, JenisTombol.kedua),
            ].indexed) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                // The board disables Ubah too but keeps its normal look.
                child: i == 1 && s.basi
                    ? TekanAria(
                        onTap: () {},
                        aktif: false,
                        radius: 12,
                        child: RupaTombol(
                          label: t,
                          isi: c.permukaan,
                          garis: GarisBorder.penuh(c.tinta, radius: 12),
                          warnaTeks: c.tinta,
                          radius: 12,
                          tinggi: 46,
                          paddingH: 6,
                        ),
                      )
                    : Tombol(
                        t,
                        onPressed: f,
                        jenis: j,
                        ukuran: UkuranTombol.ringkas,
                        paddingH: 6,
                        nonaktif: i == 0 && s.basi,
                      ),
              ),
            ],
          ],
        ),
        Text(
          'Usulan belum mengisi apa pun. Pakai mengisi draf; Ubah mengisi lalu membuka isian untuk diperbaiki. Tidak perlu alasan.',
          style: TextStyle(fontSize: 13, color: c.tinta2),
        ),
      ],
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: c.lautLembut,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, w) in anak.indexed) ...[
            if (i > 0) const SizedBox(height: 10),
            w,
          ],
        ],
      ),
    );
  }
}

/// `textarea#kal`, 2 rows, padding 10 12, radius 12, 1 px `laut`.
class _Kalimat extends StatefulWidget {
  const _Kalimat({required this.controller, required this.web});
  final TextEditingController controller;
  final bool web;

  @override
  State<_Kalimat> createState() => _KalimatState();
}

class _KalimatState extends State<_Kalimat> {
  final _fokus = FocusNode();

  @override
  void initState() {
    super.initState();
    _fokus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _fokus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final gaya = widget.web
        ? TextStyle(
            fontFamily: PalakatText.mono,
            // The textarea's UA font: monospace 13.33 px, so "tanggal"
            // wraps where the board wraps it (390 wide).
            fontSize: 40 / 3,
            height: 15 / (40 / 3),
            color: c.tinta,
          )
        : DefaultTextStyle.of(context).style;
    return Semantics(
      label: 'BANTUAN AI · PILIHAN',
      child: CincinFokus(
        tampil: _fokus.hasFocus,
        radius: 12,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: ShapeDecoration(
            color: c.permukaan,
            shape: GarisBorder.penuh(c.laut, tebal: 1, radius: 12),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: TextField(
              controller: widget.controller,
              focusNode: _fokus,
              minLines: 2,
              maxLines: 2,
              style: gaya,
              cursorColor: c.laut,
              decoration: const InputDecoration.collapsed(hintText: null),
            ),
          ),
        ),
      ),
    );
  }
}

/// The suggestion card: `permukaan`, 1.5 dotted `laut`, radius 12, padding 4 14.
class _KartuUsulan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final titik = SizedBox(
      width: double.infinity,
      height: 1,
      child: CustomPaint(painter: _TitikPainter(c.garisTegas)),
    );
    return Kartu(
      status: GarisStatus.usulanAI,
      radius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Semantics(
        container: true,
        label: 'Usulan AI',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const LencanaStatus(
                    'Usulan AI',
                    bentuk: BentukLencana.usulanAI,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'dari kalimat Anda',
                    style: TextStyle(fontSize: 13, color: c.tinta2),
                  ),
                ],
              ),
            ),
            for (final (k, v, ragu) in _usul) ...[
              titik,
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: _BarisSusut(
                  jarak: 12,
                  kiri: Text(
                    k,
                    style: TextStyle(fontSize: 14, color: c.tinta2),
                  ),
                  kanan: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        v,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                          color: c.lautTua,
                        ),
                      ),
                      if (ragu)
                        Text(
                          'AI kurang yakin, mohon dicek',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: c.tinta,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            titik,
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Peruntukan dan Lingkup tidak diusulkan. Pilih sendiri.',
                style: TextStyle(fontSize: 13, color: c.tinta3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Amount (IsianJumlah display form) and the six-row field card. [turun]:
/// filled values drop in once, staggered 70 ms (BantuanAI only; WebBantuanAI
/// does not declare the keyframe).
class DrafBantuanAI extends StatelessWidget {
  const DrafBantuanAI({super.key, required this.s, required this.turun});

  final KeadaanBantuanAI s;
  final bool turun;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final p = s.dipakai;
    final isi = [
      ('Kas/Bank', p ? 'Bank BNI ··4821' : ''),
      ('Dibayar kepada', p ? 'PLN' : ''),
      ('Tanggal transaksi', p ? '6 Oktober 2026' : '16 November 2026'),
      ('Mata Anggaran', p ? 'Belanja 5.01.02.00 Listrik, air dan telepon' : ''),
      ('Diambil dari peruntukan', ''),
      ('Lingkup', ''),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Jumlah (Rp)', style: TextStyle(fontSize: 14, color: c.tinta2)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: c.tinta, width: 2)),
          ),
          child: Text(
            p ? 'Rp1.250.000' : 'Rp0',
            style: TextStyle(
              fontFamily: PalakatText.mono,
              fontSize: 36,
              fontWeight: FontWeight.w500,
              letterSpacing: -1,
              color: p ? c.tinta : c.tinta3,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: c.permukaan,
            border: Border.all(color: c.garis),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, (k, v)) in isi.indexed)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: i == 0
                      ? null
                      : BoxDecoration(
                          border: Border(top: BorderSide(color: c.garis)),
                        ),
                  child: _BarisSusut(
                    jarak: 16,
                    kiri: Text(
                      k,
                      style: TextStyle(fontSize: 14, color: c.tinta2),
                    ),
                    kanan: _nilai(c, i, v),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _nilai(PalakatWarna c, int i, String v) {
    final ada = v.isNotEmpty;
    final teks = Text(
      ada ? v : 'Belum diisi',
      textAlign: TextAlign.right,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: ada ? c.tinta : c.tinta3,
      ),
    );
    if (!(turun && s.dipakai && ada)) return teks;
    return Gerak(
      Kerangka.turun,
      key: ValueKey('turun$i'),
      lama: const Duration(milliseconds: 400),
      tunda: Duration(milliseconds: i * 70),
      child: teks,
    );
  }
}

/// CSS `display: flex; justify-content: space-between` with two items: each
/// starts at its max-content width and, when they do not fit, both shrink in
/// proportion to it, never below their min-content width (a label wraps as
/// on the board instead of overflowing).
class _BarisSusut extends MultiChildRenderObjectWidget {
  _BarisSusut({
    required this.jarak,
    required Widget kiri,
    required Widget kanan,
    this.tengah = false,
  }) : super(children: [kiri, kanan]);

  final double jarak;

  /// `align-items: center`; else top.
  final bool tengah;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderBarisSusut(jarak, tengah);

  @override
  void updateRenderObject(BuildContext context, _RenderBarisSusut r) => r
    ..jarak = jarak
    ..tengah = tengah;
}

class _DataSusut extends ContainerBoxParentData<RenderBox> {}

class _RenderBarisSusut extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _DataSusut>,
        RenderBoxContainerDefaultsMixin<RenderBox, _DataSusut> {
  _RenderBarisSusut(this._jarak, this._tengah);

  double _jarak;
  bool _tengah;
  set jarak(double v) {
    if (v == _jarak) return;
    _jarak = v;
    markNeedsLayout();
  }

  set tengah(bool v) {
    if (v == _tengah) return;
    _tengah = v;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _DataSusut) child.parentData = _DataSusut();
  }

  (double, double) _lebar(double w) {
    final a = firstChild!, b = lastChild!;
    final ruang = w - _jarak;
    final ma = a.getMaxIntrinsicWidth(double.infinity);
    final mb = b.getMaxIntrinsicWidth(double.infinity);
    if (ma + mb <= ruang) return (ma, mb);
    final lebih = ma + mb - ruang;
    var wa = ma - lebih * ma / (ma + mb), wb = mb - lebih * mb / (ma + mb);
    final na = a.getMinIntrinsicWidth(double.infinity);
    final nb = b.getMinIntrinsicWidth(double.infinity);
    if (wa < na) {
      wa = na;
      wb = ruang - na;
    } else if (wb < nb) {
      wb = nb;
      wa = ruang - nb;
    }
    return (wa.clamp(0, w), wb.clamp(0, w));
  }

  @override
  double computeMinIntrinsicHeight(double width) =>
      computeMaxIntrinsicHeight(width);

  @override
  double computeMaxIntrinsicHeight(double width) {
    final (wa, wb) = _lebar(width);
    final ha = firstChild!.getMaxIntrinsicHeight(wa);
    final hb = lastChild!.getMaxIntrinsicHeight(wb);
    return ha > hb ? ha : hb;
  }

  @override
  void performLayout() {
    final a = firstChild!, b = lastChild!;
    final w = constraints.maxWidth;
    final (wa, wb) = _lebar(w);
    a.layout(BoxConstraints(maxWidth: wa), parentUsesSize: true);
    b.layout(BoxConstraints(maxWidth: wb), parentUsesSize: true);
    final h = a.size.height > b.size.height ? a.size.height : b.size.height;
    size = constraints.constrain(Size(w, h));
    double y(RenderBox r) => _tengah ? (h - r.size.height) / 2 : 0;
    (a.parentData! as _DataSusut).offset = Offset(0, y(a));
    (b.parentData! as _DataSusut).offset = Offset(
      size.width - b.size.width,
      y(b),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}

/// `border-top: 1px dotted`: 1 px dots, 1 px apart, snapped to whole pixels
/// (GarisLurus at a half-pixel x blurs 1 px dots into a solid grey line).
// ponytail: snaps within the current layer only; fine while the card's layer sits at whole pixels.
class _TitikPainter extends CustomPainter {
  _TitikPainter(this.warna);
  final Color warna;

  @override
  void paint(Canvas canvas, Size size) {
    final m = canvas.getTransform();
    final dx = m[12].roundToDouble() - m[12];
    final dy = m[13].roundToDouble() - m[13];
    final p = Paint()..color = warna;
    for (var x = dx; x + 1 <= size.width + .01; x += 2) {
      canvas.drawRect(Rect.fromLTWH(x, dy, 1, 1), p);
    }
  }

  @override
  bool shouldRepaint(_TitikPainter old) => old.warna != warna;
}
