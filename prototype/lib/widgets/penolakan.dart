import 'package:flutter/widgets.dart';

import '../theme/palakat_tema.dart';
import 'tata_letak.dart';

/// A refusal: **"Tidak dapat dilakukan: {tindakan}."** in `bata` 700, a space,
/// the cause in `tinta`; then the steps that are really available, in the
/// boards' wrap row (`flex: 1 1 150px; max-width: 340px`, gap 8).
class Penolakan extends StatelessWidget {
  const Penolakan({
    super.key,
    required this.tindakan,
    required this.sebab,
    required this.jalan,
    this.ukuranTeks = 15,
    this.jarak = 10,
  });

  /// 'Bukukan'.
  final String tindakan;

  /// '{bulan} {tahun} sudah ditutup.'
  final String sebab;

  /// `Tombol(jenis: kedua, ukuran: sedang)` 'Pindah tanggal', 'Batalkan'.
  /// Empty when the board offers the steps as the screen's own buttons (Draf).
  final List<Widget> jalan;

  /// 15 (preview, Draf), 14 (flow boards).
  final double ukuranTeks;

  /// Gap between the sentence and the steps (preview 10).
  final double jarak;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Semantics(
        container: true,
        liveRegion: true,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Tidak dapat dilakukan: $tindakan.',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: context.warna.bata,
                ),
              ),
              TextSpan(text: ' $sebab'),
            ],
          ),
          style: TextStyle(fontSize: ukuranTeks, color: context.warna.tinta),
        ),
      ),
      if (jalan.isNotEmpty) ...[
        SizedBox(height: jarak),
        BarisLentur(
          jarak: 8,
          anak: [
            for (final w in jalan) Lentur(dasar: 150, maks: 340, child: w),
          ],
        ),
      ],
    ],
  );
}
