import 'package:flutter/widgets.dart';

import '../theme/palakat_tema.dart';
import 'tata_letak.dart';
import 'tombol.dart';

enum GayaAlasan {
  /// **"Tidak dapat dilakukan: {tindakan}."** `bata` 700, then the reason in `tinta` (flow boards).
  penolakan,

  /// "Tidak dapat dilakukan: {alasan}" 14/600 `bata` (Main Periksa, TabCatat, WebCatat).
  kalimatBata,

  /// "Belum dapat disimpan: {alasan}" 14 `tinta2` (KasusBaru, WebKasusBaru).
  pendamping,
}

/// One button that looks disabled until its condition is met, never swapped,
/// never `onPressed: null`: it stays focusable and reads the reason as a hint.
/// The first unmet reason shows above it, only once input has started.
class TombolBersyarat extends StatelessWidget {
  const TombolBersyarat({
    super.key,
    required this.label,
    required this.tindakan,
    required this.alasan,
    required this.onPressed,
    this.periksa,
    this.sudahMulai = true,
    this.warnaSiap = JenisTombol.tinta,
    this.teksBelumRedup = false,
    this.gayaAlasan = GayaAlasan.penolakan,
    this.tinggi = 52,
    this.radius = 14,
    this.paddingH = 16,
    this.jarak = 8,
    this.baris,
  });

  /// 'Buat pelimpahan'.
  final String label;

  /// Verb in the sentence: 'Buat pelimpahan'.
  final String tindakan;

  /// First unmet reason, '' when met, computed by the screen from the latest input.
  final String alasan;

  /// Runs only when the condition holds at the moment of the press.
  final VoidCallback onPressed;

  /// Re-check at press time (the board's `if (self.vals()[ok]) mentah()`):
  /// returns the first unmet reason from the latest controller values.
  /// Without it [alasan] from the last build decides.
  final String Function()? periksa;

  /// false while the form is untouched: no sentence shown.
  final bool sudahMulai;

  /// `tinta` (flow boards) or `utama` (finance boards, `laut`).
  final JenisTombol warnaSiap;

  /// true: unmet text `tinta3` (finance boards); false: `tinta2`.
  final bool teksBelumRedup;
  final GayaAlasan gayaAlasan;

  /// 52 / radius 14 / padding 0 16; TabCatat 46 / 12 / 0 20, KasusBaru 0 20.
  final double tinggi, radius, paddingH;

  /// Gap between the sentence and the button.
  final double jarak;

  /// Flow boards: the button sits in a wrap row (`flex: 1 1 150px;
  /// max-width: 340px`, gap 8) with these widgets after it ('Batalkan').
  /// Pass `const []` for the button alone in that row; null = full width.
  final List<Widget>? baris;

  bool get _siap => alasan.isEmpty;

  void _tekan() {
    if ((periksa?.call() ?? alasan).isEmpty) onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final tombol = TekanAria(
      onTap: _tekan,
      aktif: _siap,
      petunjuk: _siap ? null : alasan,
      radius: radius,
      child: RupaTombol(
        label: label,
        isi: _siap
            ? (warnaSiap == JenisTombol.utama ? c.laut : c.tinta)
            : c.garis,
        warnaTeks: _siap
            ? (warnaSiap == JenisTombol.utama ? c.diLaut : c.permukaan)
            : (teksBelumRedup ? c.tinta3 : c.tinta2),
        radius: radius,
        tinggi: tinggi,
        paddingH: paddingH,
      ),
    );
    final kalimat = switch (gayaAlasan) {
      GayaAlasan.penolakan => Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Tidak dapat dilakukan: $tindakan.',
              style: TextStyle(fontWeight: FontWeight.w700, color: c.bata),
            ),
            TextSpan(text: ' $alasan'),
          ],
        ),
        style: TextStyle(fontSize: 14, color: c.tinta),
      ),
      GayaAlasan.kalimatBata => Text(
        'Tidak dapat dilakukan: $alasan',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: c.bata,
        ),
      ),
      GayaAlasan.pendamping => Text(
        'Belum dapat disimpan: $alasan',
        style: TextStyle(fontSize: 14, color: c.tinta2),
      ),
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (sudahMulai && !_siap) ...[
          Semantics(container: true, liveRegion: true, child: kalimat),
          SizedBox(height: jarak),
        ],
        if (baris == null)
          tombol
        else
          BarisLentur(
            jarak: 8,
            anak: [
              for (final w in [tombol, ...baris!])
                Lentur(dasar: 150, maks: 340, child: w),
            ],
          ),
      ],
    );
  }
}
