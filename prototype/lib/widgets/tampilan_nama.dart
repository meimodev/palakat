import 'package:flutter/widgets.dart';

import '../theme/palakat_tema.dart';
import 'garis.dart';
import 'garis_status.dart';
import 'kecil.dart';
import 'tekan.dart';

enum BentukNama {
  namaLengkap('Nama lengkap'),
  namaKeluarga('Nama keluarga'),
  keluargaKolom('Keluarga + Kolom'),
  kolom('Kolom'),
  bipra('BIPRA'),
  bipraKolom('BIPRA + Kolom'),
  tanpaNama('Tanpa nama');

  const BentukNama(this.label);
  final String label;
}

/// TampilanNama: one radio row per [BentukNama], the "Lihat tampilan nama
/// saya" sample, and the "Masih mudah dikenali." warning when
/// [masihDikenali] is set. Blocks are [jarak] apart (the body gap, 16). The
/// caption above ("Pilihan pribadi") and the footnote stay on the screen.
class TampilanNama extends StatelessWidget {
  const TampilanNama({
    super.key,
    required this.pilihan,
    required this.contoh,
    required this.onPilih,
    required this.contohKalimat,
    this.masihDikenali,
    this.jarak = 16,
  });

  final BentukNama pilihan;

  /// Right-hand sample per row: 'Kel. Wenas-Lasut — Kolom 7'.
  final Map<BentukNama, String> contoh;
  final ValueChanged<BentukNama> onPilih;

  /// 'Syukur HUT pernikahan: '.
  final String contohKalimat;

  /// Sentence after 'Masih mudah dikenali.'.
  final String? masihDikenali;
  final double jarak;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final blok = <Widget>[
      for (final b in BentukNama.values) _baris(context, b),
      // Preview card: lautLembut, radius 14, padding 14 16, gap 6.
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: c.lautLembut,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lihat tampilan nama saya',
              style: TextStyle(fontSize: 13, color: c.tinta3),
            ),
            const SizedBox(height: 6),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: contohKalimat),
                  TextSpan(
                    text: contoh[pilihan] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
      if (masihDikenali != null)
        Kartu(
          status: GarisStatus.draf,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Masih mudah dikenali.',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: ' $masihDikenali',
                  style: TextStyle(color: c.tinta2),
                ),
              ],
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < blok.length; i++) ...[
          if (i > 0) SizedBox(height: jarak),
          blok[i],
        ],
      ],
    );
  }

  /// The board's `label` row: `permukaan`, 1 `garis`, radius 14, padding
  /// 10 14, min height 44, gap 12, 15 px; radio 22, name (flex), sample 13
  /// `tinta3`. The whole row is the target.
  Widget _baris(BuildContext context, BentukNama b) {
    final c = context.warna;
    final on = b == pilihan;
    // Radio group semantics, merged into the row's own node; like the
    // board's <label>, the name and the sample are both read.
    return MergeSemantics(
      child: Semantics(
        inMutuallyExclusiveGroup: true,
        child: Tekan(
          onTap: () => onPilih(b),
          tercentang: on,
          radius: 14,
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: ShapeDecoration(
              color: c.permukaan,
              shape: GarisBorder.penuh(c.garis, tebal: 1, radius: 14),
            ),
            child: LayoutBuilder(
              builder: (context, k) => Row(
                children: [
                  SizedBox.square(
                    dimension: 22,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c.permukaan,
                        border: Border.all(
                          color: on ? c.tinta : c.tinta3,
                          width: on ? 6 : 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(b.label, style: const TextStyle(fontSize: 15)),
                  ),
                  const SizedBox(width: 12),
                  // CSS flex-shrink: the sample wraps only when the name
                  // would go below about its longest word.
                  // ponytail: 72 px stands in for the name's min-content width.
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: (k.maxWidth - 22 - 12 - 12 - 72).clamp(
                        0,
                        double.infinity,
                      ),
                    ),
                    child: Text(
                      contoh[b] ?? '',
                      style: TextStyle(fontSize: 13, color: c.tinta3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
