import 'dart:async';

import 'package:flutter/material.dart';

import '../../mock/format.dart';
import '../../motion/kerangka.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tombol.dart';

/// Board state shared by AIFoto and WebAIFoto (one instance per screen):
/// `{ tahap: 'belum' | 'proses' | 'ada', pakai }`.
class KeadaanAIFoto extends ChangeNotifier {
  String tahap = 'belum';
  bool pakai = false;
  Timer? _t;

  /// "Buat usulan dari foto ini": 1400 ms stands for the AI reading the photo.
  void buat() {
    tahap = 'proses';
    _t?.cancel();
    _t = Timer(const Duration(milliseconds: 1400), () {
      tahap = 'ada';
      notifyListeners();
    });
    notifyListeners();
  }

  /// Pakai and Ubah (the board binds both to `pakai`).
  void pakaiUsulan() {
    pakai = true;
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
    super.dispose();
  }
}

const _usul = [
  ('Jumlah (Rp)', 'Rp1.250.000', false),
  ('Dibayar kepada', 'Toko Sinar', false),
  ('Tanggal nota', '6 Oktober 2026', false),
  (
    'Bagian 1',
    'Belanja 5.01.02.00 Listrik, air dan telepon · Rp1.000.000',
    true,
  ),
  ('Bagian 2', 'Belanja 5.02.01.00 Alat tulis dan fotokopi · Rp250.000', true),
];

Widget _kolom(List<Widget> anak, double jarak) => Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  mainAxisSize: MainAxisSize.min,
  children: [
    for (final (i, a) in anak.indexed) ...[
      if (i > 0) SizedBox(height: jarak),
      a,
    ],
  ],
);

/// The "BANTUAN AI · PILIHAN" panel: `lautLembut`, radius 16, padding 14 16.
class PanelAIFoto extends StatelessWidget {
  const PanelAIFoto(this.k, {super.key});
  final KeadaanAIFoto k;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final titik = _GarisTitik(c.garisTegas);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: c.lautLembut,
        borderRadius: BorderRadius.circular(16),
      ),
      child: _kolom([
        Text(
          'BANTUAN AI · PILIHAN',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: c.lautTua,
            letterSpacing: .3,
          ),
        ),
        Row(
          children: [
            // 72 × 92 content box plus the 1 px border (no box-sizing reset).
            Container(
              width: 74,
              height: 94,
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                color: c.permukaan,
                shape: GarisBorder.penuh(c.laut, tebal: 1, radius: 8),
              ),
              child: Text(
                '[Foto nota]',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: c.tinta2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DefaultTextStyle.merge(
                style: const TextStyle(fontSize: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'nota-toko-sinar.jpg',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Terlampir sebagai dokumen pendukung · Diunggah, belum diverifikasi',
                      style: TextStyle(color: c.tinta2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (k.tahap == 'belum' && !k.pakai)
          Tombol(
            'Buat usulan dari foto ini',
            onPressed: k.buat,
            jenis: JenisTombol.garisLaut,
            ukuran: UkuranTombol.kecil,
            warnaTeks: c.lautTua,
          ),
        if (k.tahap == 'proses')
          _Status(
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Membaca foto…',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: c.lautTua,
                  ),
                ),
              ),
            ),
          ),
        if (k.tahap == 'ada') ...[
          Gerak(
            Kerangka.muncul,
            key: const ValueKey('usulan'),
            lama: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: ShapeDecoration(
                color: c.permukaan,
                shape: GarisBorder.titik(c.laut, radius: 12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 6),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: ShapeDecoration(
                          shape: GarisBorder.titik(c.laut, radius: 6),
                        ),
                        child: Text(
                          'Usulan AI · dari foto',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.2,
                            fontWeight: FontWeight.w700,
                            color: c.lautTua,
                          ),
                        ),
                      ),
                    ),
                  ),
                  for (final (kunci, nilai, ragu) in _usul) ...[
                    titik,
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            kunci,
                            style: TextStyle(fontSize: 13, color: c.tinta2),
                          ),
                          Text(
                            nilai,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                              color: c.lautTua,
                            ),
                          ),
                          if (ragu)
                            const Text(
                              'AI kurang yakin, mohon dicek',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  titik,
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Kas/Bank, peruntukan dan Lingkup tidak diusulkan. Pilih sendiri.',
                      style: TextStyle(fontSize: 13, color: c.tinta3),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              for (final (i, (t, f, j)) in [
                ('Pakai', k.pakaiUsulan, JenisTombol.utama),
                ('Ubah', k.pakaiUsulan, JenisTombol.kedua),
                ('Abaikan', k.abaikan, JenisTombol.kedua),
              ].indexed) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: Tombol(
                    t,
                    onPressed: f,
                    jenis: j,
                    ukuran: UkuranTombol.ringkas,
                    paddingH: 0,
                  ),
                ),
              ],
            ],
          ),
        ],
        Text(
          'Hasil baca AI bukan verifikasi. Dokumen pendukung tetap perlu diverifikasi orang.',
          style: TextStyle(fontSize: 13, color: c.tinta2),
        ),
      ], 10),
    );
  }
}

/// Jumlah display, the six-field card and the saved line, gap 16
/// (AIFoto 2b–2d; WebAIFoto's left column).
class IsianAIFoto extends StatelessWidget {
  const IsianAIFoto(this.k, {super.key});
  final KeadaanAIFoto k;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final p = k.pakai;
    final isian = [
      ('Dibayar kepada', p ? 'Toko Sinar' : ''),
      ('Tanggal nota', p ? '6 Oktober 2026' : ''),
      (
        'Mata Anggaran',
        p ? 'Dibagi ke 2 baris · total sama dengan Jumlah' : '',
      ),
      ('Kas/Bank', ''),
      ('Diambil dari peruntukan', ''),
      ('Lingkup', ''),
    ];
    return _kolom([
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Jumlah (Rp)', style: TextStyle(fontSize: 14, color: c.tinta2)),
          Container(
            padding: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: c.tinta, width: 2)),
            ),
            child: Text(
              p ? rp(1250000) : rp(0),
              style: TextStyle(
                fontFamily: PalakatText.mono,
                fontSize: 34,
                fontWeight: FontWeight.w500,
                letterSpacing: -1,
                // CSS splits the line-height leading evenly above and below.
                leadingDistribution: TextLeadingDistribution.even,
                color: p ? c.tinta : c.tinta3,
              ),
            ),
          ),
        ],
      ),
      Kartu(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, (kunci, nilai)) in isian.indexed) ...[
              if (i > 0) GarisLurus(warna: c.garis),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: DefaultTextStyle.merge(
                  style: const TextStyle(fontSize: 14),
                  child: _BarisIsian(
                    kunci,
                    nilai.isEmpty ? 'Belum diisi' : nilai,
                    nilai.isEmpty ? c.tinta3 : c.tinta,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      if (p)
        Gerak(
          Kerangka.muncul,
          lama: const Duration(milliseconds: 300),
          child: _Status(
            Text(
              'Tersimpan sebagai Draf · belum masuk saldo. Semua isian masih dapat diubah.',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ),
        ),
    ], 16);
  }
}

/// `display: flex; justify-content: space-between; gap: 16px`: both texts
/// shrink from their max-content width in proportion to it, never below
/// their min-content width (CSS flex-shrink with `min-width: auto`).
class _BarisIsian extends StatelessWidget {
  const _BarisIsian(this.kunci, this.nilai, this.warna);
  final String kunci, nilai;
  final Color warna;

  @override
  Widget build(BuildContext context) {
    final gaya = DefaultTextStyle.of(context).style;
    final gayaNilai = gaya.copyWith(fontWeight: FontWeight.w600, color: warna);
    final skala = MediaQuery.textScalerOf(context);
    double ukur(String t, TextStyle s, {bool min = false}) {
      final tp = TextPainter(
        text: TextSpan(text: t, style: s),
        textDirection: TextDirection.ltr,
        textScaler: skala,
      )..layout();
      final w = min ? tp.minIntrinsicWidth : tp.maxIntrinsicWidth;
      tp.dispose();
      return w;
    }

    return LayoutBuilder(
      builder: (context, k) {
        final gayaKunci = gaya.copyWith(color: context.warna.tinta2);
        final a = ukur(kunci, gayaKunci), b = ukur(nilai, gayaNilai);
        var wa = a, wb = b;
        final lebih = a + b + 16 - k.maxWidth;
        if (lebih > 0) {
          final minA = ukur(kunci, gayaKunci, min: true);
          final minB = ukur(nilai, gayaNilai, min: true);
          wa = a - lebih * a / (a + b);
          wb = b - lebih * b / (a + b);
          if (wa < minA) {
            wa = minA;
            wb = k.maxWidth - 16 - wa;
          } else if (wb < minB) {
            wb = minB;
            wa = k.maxWidth - 16 - wb;
          }
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: wa,
              child: Text(kunci, style: gayaKunci),
            ),
            SizedBox(
              width: wb,
              child: Text(nilai, style: gayaNilai, textAlign: TextAlign.right),
            ),
          ],
        );
      },
    );
  }
}

/// `border-top: 1px dotted`: 1 px dots on a 2 px pitch, snapped to whole
/// pixels as Chrome draws them (the shared GarisLurus smears them to grey at
/// fractional offsets).
class _GarisTitik extends StatelessWidget {
  const _GarisTitik(this.warna);
  final Color warna;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 1,
    child: CustomPaint(painter: _TitikPainter(warna)),
  );
}

class _TitikPainter extends CustomPainter {
  _TitikPainter(this.warna);
  final Color warna;

  @override
  void paint(Canvas canvas, Size size) {
    final m = canvas.getTransform();
    double snap(double t) => t.roundToDouble() - t;
    final y = snap(m[13]);
    final cat = Paint()..color = warna;
    for (var x = snap(m[12]); x + 1 <= size.width + .5; x += 2) {
      canvas.drawRect(Rect.fromLTWH(x, y, 1, 1), cat);
    }
  }

  @override
  bool shouldRepaint(_TitikPainter old) => old.warna != warna;
}

/// `role="status"`.
class _Status extends StatelessWidget {
  const _Status(this.child);
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Semantics(container: true, liveRegion: true, child: child);
}
