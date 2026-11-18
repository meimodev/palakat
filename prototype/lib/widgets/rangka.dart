import 'package:flutter/widgets.dart';

import '../motion/ulang.dart';
import '../theme/palakat_tema.dart';
import 'garis.dart';
import 'tombol.dart';

/// The loading skeleton (`role="status"`): an optional visible line, then the
/// blocks the screen lays out, in a column. Never a provisional figure.
class Rangka extends StatelessWidget {
  const Rangka({
    super.key,
    required this.balok,
    this.keterangan,
    this.jarak = 16,
  });

  /// Laid out by the screen: [RangkaBalok]s, inside `Kartu`s as the board does.
  final List<Widget> balok;

  /// Visible line first, e.g. 'Memuat saldo dan transaksi…' (14 tinta2).
  final String? keterangan;

  /// Column gap: 16 (Memuat), 12 (preview).
  final double jarak;

  @override
  Widget build(BuildContext context) {
    final anak = [
      if (keterangan != null)
        Text(
          keterangan!,
          style: TextStyle(fontSize: 14, color: context.warna.tinta2),
        ),
      ...balok,
    ];
    return Semantics(
      container: true,
      liveRegion: true,
      label: 'Memuat',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < anak.length; i++) ...[
            if (i > 0) SizedBox(height: jarak),
            anak[i],
          ],
        ],
      ),
    );
  }
}

/// One skeleton block: `garis` fill, radius 8, hidden from screen readers.
/// Width is a fraction of the parent's width, so the parent must be bounded
/// (in a Row, give it an `Expanded`).
class RangkaBalok extends StatelessWidget {
  const RangkaBalok({
    super.key,
    required this.lebar,
    required this.tinggi,
    this.radius = 8,
    this.denyut = true,
  });

  /// Fraction of the parent width (0.62 = CSS `width: 62%`).
  final double lebar;
  final double tinggi;
  final double radius;

  /// `denyut 1.4s` (Memuat, WebMemuat); false on KeadaanUmum, which keeps it still.
  final bool denyut;

  @override
  Widget build(BuildContext context) {
    final blok = FractionallySizedBox(
      widthFactor: lebar,
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        height: tinggi,
        decoration: BoxDecoration(
          color: context.warna.garis,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
    return ExcludeSemantics(child: denyut ? Denyut(child: blok) : blok);
  }
}

/// The failure card that replaces the skeleton (`role="alert"`): `bataLembut`
/// fill, 1.5 `bata`, radius 14, padding 16, gap 6; title 17/700, sentence 14
/// `tinta2`, then the `tinta` "Coba lagi" (52, padding 0 20, min width 140).
class RangkaGagal extends StatelessWidget {
  const RangkaGagal({
    super.key,
    required this.kalimat,
    required this.onCobaLagi,
    this.judul = 'Data belum dapat dimuat',
  });

  final String judul;

  /// 'Server tidak menjawab. Pembukuan Anda tidak berubah.'
  final String kalimat;
  final VoidCallback onCobaLagi;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: c.bataLembut,
          shape: GarisBorder.penuh(c.bata, radius: 14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              judul,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(kalimat, style: TextStyle(fontSize: 14, color: c.tinta2)),
            const SizedBox(height: 12), // gap 6 + margin-top 6
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 140),
              child: Tombol(
                'Coba lagi',
                onPressed: onCobaLagi,
                jenis: JenisTombol.tinta,
                lebarPenuh: false,
                paddingH: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
