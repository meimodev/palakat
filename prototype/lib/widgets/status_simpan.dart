import 'package:flutter/widgets.dart';

import '../theme/palakat_tema.dart';
import 'tekan.dart';

enum KeadaanSimpan { belum, tersimpan }

/// The honest save state, trailing in the phone header (Main): 13/600.
/// Pass it as `KepalaPonsel.ujung`, which gives the board's 8 px right.
class StatusSimpan extends StatelessWidget {
  const StatusSimpan(this.keadaan, {super.key});

  final KeadaanSimpan keadaan;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final (teks, warna) = switch (keadaan) {
      KeadaanSimpan.belum => ('Belum tersimpan', c.tinta3),
      KeadaanSimpan.tersimpan => ('Tersimpan', c.laut),
    };
    return Text(
      teks,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: warna),
    );
  }
}

/// Draf, WebDraf (`role="alert"`): 1.5 `tinta`, `permukaan`, radius 14,
/// padding 14 16, gap 8, then "Muat versi terbaru" (46 high, padding 0 20,
/// radius 12, `tinta` field, start-aligned).
class PitaDiubahOrangLain extends StatelessWidget {
  const PitaDiubahOrangLain({
    super.key,
    required this.oleh,
    required this.jam,
    required this.onMuat,
  });

  /// The board's `plk`: 'Meiske L.' or 'Yanti Sumual, Operator'.
  final String oleh;

  /// 'dd/mm/yyyy hh.mm'.
  final String jam;
  final VoidCallback onMuat;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: c.permukaan,
          border: Border.all(color: c.tinta, width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Sudah diubah sejak Anda membukanya',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: ' (oleh $oleh, $jam, dari perangkat lain).'),
                ],
              ),
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 8),
            Text(
              'Isian Anda tidak menimpa perubahan itu. Muat versi terbaru, '
              'lalu lanjutkan.',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
            const SizedBox(height: 8),
            Tekan(
              onTap: onMuat,
              radius: 12,
              child: Container(
                constraints: const BoxConstraints(minHeight: 46),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: c.tinta,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  widthFactor: 1,
                  child: Text(
                    'Muat versi terbaru',
                    style: TextStyle(
                      color: c.permukaan,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
