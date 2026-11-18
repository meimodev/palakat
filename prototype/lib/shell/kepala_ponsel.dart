import 'package:flutter/widgets.dart';

import '../theme/palakat_tema.dart';
import '../widgets/ikon.dart';
import '../widgets/tekan.dart';
import 'tautan.dart';

/// Phone header with back (components.md 4.1, navigation.md 1.2): row, gap 8,
/// padding 14 12 8. Back 44 × 44 with the 22 chevron; h1 18/700 `flex: 1`.
class KepalaPonsel extends StatelessWidget {
  const KepalaPonsel({
    super.key,
    required this.judul,
    this.anakJudul,
    this.kembaliKe,
    this.onKembali,
    this.diSini,
    this.labelKembali = 'Kembali',
    this.ujung,
    this.judulMono = false,
    this.ukuranJudul,
    this.padding = const EdgeInsets.fromLTRB(12, 14, 12, 8),
    this.jarakJudul,
  });

  /// h1.
  final String judul;

  /// Subtitle under the title, 13 `tinta2`.
  final String? anakJudul;

  /// Board stem of the back arrow: `Tautan(ke: kembaliKe, cara: Cara.naik)`.
  final String? kembaliKe;

  /// …or a view change inside the board (a `<button>` back).
  final VoidCallback? onKembali;

  /// Runs instead of navigating when [kembaliKe] is the page open now.
  final VoidCallback? diSini;

  /// The back control's aria-label, verbatim.
  final String labelKembali;

  /// Trailing: save status, a `kepala` badge or a small action. Gets the
  /// boards' 8 px right spacing.
  final Widget? ujung;

  /// No. Bukti titles: mono 17/600.
  final bool judulMono;

  /// Title size override (LihatDokumen: mono 16).
  final double? ukuranJudul;

  /// One board uses bottom padding 4.
  final EdgeInsets padding;

  /// Title left margin; defaults to 8 when there is no back control, else 0.
  /// Main periksa (the only header with a hidden back) has 8 either way:
  /// pass 8 there.
  final double? jarakJudul;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    const panah = SizedBox(
      width: 44,
      height: 44,
      child: Center(child: PalakatIkon(Ikon.kembali, ukuran: 22)),
    );
    final Widget? kembali = kembaliKe != null
        ? Tautan(
            ke: kembaliKe!,
            cara: Cara.naik,
            label: labelKembali,
            diSini: diSini,
            child: panah,
          )
        : onKembali != null
        ? Tekan(onTap: onKembali, label: labelKembali, child: panah)
        : null;
    final gayaJudul = judulMono
        ? TextStyle(
            fontFamily: PalakatText.mono,
            fontSize: ukuranJudul ?? 17,
            fontWeight: FontWeight.w600,
          )
        : TextStyle(fontSize: ukuranJudul ?? 18, fontWeight: FontWeight.w700);
    Widget teks = Semantics(header: true, child: Text(judul, style: gayaJudul));
    if (anakJudul != null) {
      teks = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          teks,
          Text(anakJudul!, style: TextStyle(fontSize: 13, color: c.tinta2)),
        ],
      );
    }
    return Padding(
      padding: padding,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Row(
          children: [
            if (kembali != null) ...[kembali, const SizedBox(width: 8)],
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: jarakJudul ?? (kembali == null ? 8 : 0),
                ),
                child: teks,
              ),
            ),
            if (ujung != null) ...[
              const SizedBox(width: 8),
              Padding(padding: const EdgeInsets.only(right: 8), child: ujung),
            ],
          ],
        ),
      ),
    );
  }
}
