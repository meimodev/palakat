import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layar.dart';
import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../providers/actor.dart';
import '../../providers/clock.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';

// Shared parts of the C1 screens (Penugasan, JabatanKosong, Pelimpahan,
// Modul, CariOrang; M6).

/// A typed 'dd/mm/yyyy' as a date, or null (the flow boards' `tgl`).
Tanggal? tanggalKetik(String t) {
  final v = bacaTgl(t);
  if (v == null) return null;
  return Tanggal(v ~/ 10000, v ~/ 100 % 100, v % 100);
}

/// A fresh idempotency key for the signed-in person's submission.
String kunciInti(WidgetRef ref) => kunciBaru(
  ref.read(actorProvider)?.personId ?? '-',
  ref.read(clockProvider),
);

/// Jumps the enclosing scroll view to the top after the next frame (every
/// view change of the flow boards).
void keAtas(BuildContext context) =>
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final p = Scrollable.maybeOf(context)?.position;
      if (p != null && p.hasPixels) p.jumpTo(0);
    });

/// Column with a fixed gap between children.
Widget susun(List<Widget> anak, {double jarak = 16}) => Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  mainAxisSize: MainAxisSize.min,
  children: [
    for (final (i, w) in anak.indexed) ...[
      if (i > 0) SizedBox(height: jarak),
      w,
    ],
  ],
);

/// 13 `tinta3` caption.
class Catatan extends StatelessWidget {
  const Catatan(this.teks, {super.key});
  final String teks;

  @override
  Widget build(BuildContext context) =>
      Text(teks, style: TextStyle(fontSize: 13, color: context.warna.tinta3));
}

/// 14 `tinta2` line.
class Baris2 extends StatelessWidget {
  const Baris2(this.teks, {super.key});
  final String teks;

  @override
  Widget build(BuildContext context) =>
      Text(teks, style: TextStyle(fontSize: 14, color: context.warna.tinta2));
}

/// The draf empty box (1.5 dashed `putus`, radius 14, padding 14/16): a 700
/// title and an optional 14 `tinta2` line.
class KotakKosong extends StatelessWidget {
  const KotakKosong(this.judul, {super.key, this.teks});
  final String judul;
  final String? teks;

  @override
  Widget build(BuildContext context) => Kartu(
    status: GarisStatus.draf,
    child: susun([
      Text(judul, style: const TextStyle(fontWeight: FontWeight.w700)),
      if (teks != null) Baris2(teks!),
    ], jarak: 6),
  );
}

/// The `terpilih` notice box: 1.5 `tinta` line, radius 12, padding 12/14,
/// 14 px.
class KotakTerpilih extends StatelessWidget {
  const KotakTerpilih(this.child, {super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) => Kartu(
    status: GarisStatus.terpilih,
    radius: 12,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    child: DefaultTextStyle.merge(
      style: TextStyle(fontSize: 14, color: context.warna.tinta),
      child: child,
    ),
  );
}

/// The web breadcrumb: an up link to [ke], 14/600 `laut` underlined, with a
/// 44 px target that does not grow the title block.
Widget remahWeb(Layar ke, String teks) {
  const lebih = (44 - 15 * 1.45) / 2;
  return MarginNegatif(
    atas: lebih,
    bawah: lebih,
    child: Tautan(
      ke: ke,
      cara: Cara.naik,
      child: Align(
        alignment: Alignment.centerLeft,
        widthFactor: 1,
        child: TautanTeks(teks, ukuran: 14),
      ),
    ),
  );
}

/// The flow boards' web title block: breadcrumb link, h1 26/700, subtitle.
Widget judulWeb(
  BuildContext context, {
  required Widget remah,
  required String judul,
  required String anakJudul,
}) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    remah,
    const SizedBox(height: 2),
    Text(
      judul,
      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
    ),
    Text(
      anakJudul,
      style: TextStyle(fontSize: 14, color: context.warna.tinta2),
    ),
  ],
);

/// Chip group (K7): label 14 `tinta2`, gap 6, chips wrapping with gap 8.
class GrupChip extends StatelessWidget {
  const GrupChip({
    super.key,
    required this.label,
    required this.pilihan,
    required this.terpilih,
    required this.onPilih,
  });

  final String label;
  final List<String> pilihan;
  final int? terpilih;
  final ValueChanged<int> onPilih;

  @override
  Widget build(BuildContext context) => susun([
    Baris2(label),
    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (i, n) in pilihan.indexed)
          ChipSatu(teks: n, dipilih: i == terpilih, onTap: () => onPilih(i)),
      ],
    ),
  ], jarak: 6);
}
