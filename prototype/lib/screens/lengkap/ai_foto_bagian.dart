import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../providers/actor.dart';
import '../../domain/finance/finance.dart';
import '../../motion/kerangka.dart';
import '../../providers/keuangan/ai.dart';
import '../../providers/keuangan/transaksi.dart';
import '../../providers/repositories_keuangan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/kecil.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tombol.dart';
import '../lanjut/bantuan_ai_bagian.dart' show KotakBatasAI;
import 'ai_bersama.dart';

/// Board state shared by AIFoto and WebAIFoto (one instance per screen):
/// `{ tahap: 'belum' | 'proses' | 'ada', pakai }`, plus the proposal the
/// repository returned and the draft "Pakai" saved.
class KeadaanAIFoto extends ChangeNotifier {
  static const berkas = 'nota-toko-sinar.jpg';

  String tahap = 'belum';
  AiProposal? usulan;

  /// The draft "Pakai" saved; the field card reads it.
  String? drafId;
  Refusal? tolak;
  bool _selesai = false;

  bool get pakai => drafId != null;

  void _ubah(void Function() f) {
    if (_selesai) return;
    f();
    notifyListeners();
  }

  /// "Buat usulan dari foto ini": the repository's 1400 ms timer stands for
  /// the AI reading the photo.
  Future<void> buat(WidgetRef ref) async {
    if (tahap == 'proses') return;
    _ubah(() {
      tahap = 'proses';
      tolak = null;
    });
    final r = await mintaUsulan(
      ref,
      AiKind.receiptPhoto,
      const AiInput(fileName: berkas),
    );
    _ubah(() {
      switch (r) {
        case Ok(:final value):
          usulan = value;
          tahap = 'ada';
        case Refused(:final refusal):
          tolak = refusal;
          tahap = 'belum';
      }
    });
  }

  /// Pakai and Ubah (the board binds both to `pakai`).
  Future<void> pakaiUsulan(WidgetRef ref, AiDisposition d) async {
    final p = usulan;
    if (p == null) return;
    final r = await isiDrafDariUsulan(ref, p, d, drafId: drafId);
    _ubah(() {
      switch (r) {
        case Ok(:final value):
          drafId = value.id;
          usulan = null;
          tahap = 'belum';
        case Refused(:final refusal):
          tolak = refusal;
      }
    });
  }

  Future<void> abaikan(WidgetRef ref) async {
    final p = usulan;
    _ubah(() {
      tahap = 'belum';
      usulan = null;
    });
    if (p != null) await abaikanUsulan(ref, p);
  }

  @override
  void dispose() {
    _selesai = true;
    super.dispose();
  }
}

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
class PanelAIFoto extends ConsumerWidget {
  const PanelAIFoto(this.k, {super.key});
  final KeadaanAIFoto k;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    final titik = _GarisTitik(c.garisTegas);
    final h = k.usulan?.result;
    final master = ref.watch(masterRepositoryProvider);
    final hari = ref.watch(hariIniProvider);
    // Every split line is a guess: "AI kurang yakin, mohon dicek".
    final usul = h == null
        ? const <(String, String, bool)>[]
        : [
            ('Jumlah (Rp)', rp(h.amount ?? 0), false),
            ('Dibayar kepada', h.payee ?? '', false),
            ('Tanggal nota', tglPanjang((h.date ?? hari).awal), false),
            for (final (i, l) in h.lines.indexed)
              (
                'Bagian ${i + 1}',
                '${labelMataAnggaran(master, l.masterCode, h.date ?? hari)}'
                    ' · ${rp(l.amount ?? h.amount ?? 0)}',
                true,
              ),
          ];
    final habis = ref.watch(anggaranAiProvider).usedUp;
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
                      KeadaanAIFoto.berkas,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      // No evidence row yet (upload is M3): no "Diunggah".
                      'Foto untuk usulan · belum dilampirkan sebagai dokumen pendukung',
                      style: TextStyle(color: c.tinta2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (k.tahap == 'belum' && !k.pakai && habis)
          KotakBatasAI(sampai: ref.watch(bulanAiLanjutProvider))
        else if (k.tahap == 'belum' && !k.pakai)
          Tombol(
            'Buat usulan dari foto ini',
            onPressed: () => k.buat(ref),
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
                  for (final (kunci, nilai, ragu) in usul) ...[
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
                (
                  'Pakai',
                  () => k.pakaiUsulan(ref, AiDisposition.accepted),
                  JenisTombol.utama,
                ),
                (
                  'Ubah',
                  () => k.pakaiUsulan(ref, AiDisposition.edited),
                  JenisTombol.kedua,
                ),
                ('Abaikan', () => k.abaikan(ref), JenisTombol.kedua),
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
        if (k.tolak case final t?)
          Penolakan(
            tindakan: t.action,
            sebab: t.because,
            jalan: const [],
            ukuranTeks: 14,
          ),
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
class IsianAIFoto extends ConsumerWidget {
  const IsianAIFoto(this.k, {super.key});
  final KeadaanAIFoto k;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    final d = k.drafId == null
        ? null
        : ref.watch(isianDrafAiProvider(k.drafId!));
    final p = d != null;
    final ma = d?.mataAnggaran ?? const [];
    final isian = [
      ('Dibayar kepada', d?.pihak ?? ''),
      ('Tanggal nota', d == null ? '' : tglPanjang(d.tanggal.awal)),
      (
        'Mata Anggaran',
        ma.length > 1
            ? 'Dibagi ke ${ma.length} baris · total sama dengan Jumlah'
            : ma.firstOrNull ?? '',
      ),
      ('Kas/Bank', d?.kasBank ?? ''),
      ('Diambil dari peruntukan', d?.peruntukan ?? ''),
      ('Lingkup', d?.lingkup ?? ''),
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
              rp(d?.jumlah ?? 0),
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
