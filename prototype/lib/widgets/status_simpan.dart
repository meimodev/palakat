import 'package:flutter/widgets.dart';

import '../motion/kerangka.dart';
import '../theme/palakat_tema.dart';
import 'tekan.dart';

enum KeadaanSimpan { belum, tersimpan, mencoba, gagal }

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
      KeadaanSimpan.mencoba => ('Mencoba menyimpan lagi…', c.tinta3),
      KeadaanSimpan.gagal => ('Gagal disimpan', c.bata),
    };
    return Text(
      teks,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: warna),
    );
  }
}

/// Main's failure banner under the header (`role="alert"`): margin 0 20 8,
/// `bataLembut`, 1 px `bata`, radius 12, padding 10 14, row gap 10, appears
/// with `muncul` 200 ms. The screen runs Coba lagi → mencoba → 1100 ms → tersimpan.
class PitaGagalSimpan extends StatelessWidget {
  const PitaGagalSimpan({super.key, required this.onCobaLagi});

  final VoidCallback onCobaLagi;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Gerak(
      Kerangka.muncul,
      lama: const Duration(milliseconds: 200),
      child: Semantics(
        container: true,
        liveRegion: true,
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: c.bataLembut,
            border: Border.all(color: c.bata),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text.rich(
                  const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Gagal disimpan.',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: ' Isian Anda masih ada di layar ini.'),
                    ],
                  ),
                  style: TextStyle(fontSize: 14, color: c.tinta),
                ),
              ),
              const SizedBox(width: 10),
              Tekan(
                onTap: onCobaLagi,
                radius: 10,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: c.bata,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    widthFactor: 1,
                    child: Text(
                      'Coba lagi',
                      style: TextStyle(
                        color: c.diBata,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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

  /// '16/11/2026 10.58'.
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
