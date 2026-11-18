import 'package:flutter/widgets.dart';

import '../mock/model.dart' show GayaLabel;
import '../theme/palakat_tema.dart';
import 'garis.dart';

/// The badge shapes; the first seven are the boards' `LS` map.
enum BentukLencana {
  draf,
  garis,
  tinta,
  laut,
  lautGaris,
  bata,
  abu,
  peran,
  usulanAI,
  terbalik,
}

/// The seven glossary statuses of money (and three reconciliation words),
/// each with its fixed shape (02-components.md).
enum StatusUang {
  draf('Draf', BentukLencana.draf),
  sudahDiperiksa('Sudah diperiksa', BentukLencana.lautGaris),
  dibukukan('Dibukukan', BentukLencana.tinta),
  sudahDitutup('Sudah ditutup', BentukLencana.tinta),
  dibalik('Dibalik', BentukLencana.garis),
  belumDitutup('Belum ditutup', BentukLencana.garis),
  sedangDikerjakan('Sedang dikerjakan', BentukLencana.garis),
  dibatalkan('Dibatalkan', BentukLencana.abu),
  sudahDipastikan('Sudah dipastikan', BentukLencana.laut),
  perluDipastikanLagi('Perlu dipastikan lagi', BentukLencana.bata);

  const StatusUang(this.label, this.bentuk);
  final String label;
  final BentukLencana bentuk;
}

/// The mock's `GayaLabel` (board `LS` keys) as a badge shape.
extension GayaLabelLencana on GayaLabel {
  BentukLencana get bentuk => this == GayaLabel.lautg
      ? BentukLencana.lautGaris
      : BentukLencana.values.byName(name);
}

/// A status badge: 13/700, radius 6, padding 3 9 inside a 1.5 line.
/// [kepala]: header form, no line, padding 4 10.
class LencanaStatus extends StatelessWidget {
  const LencanaStatus(
    this.label, {
    super.key,
    required this.bentuk,
    this.kepala = false,
    this.jarakHuruf = 0,
  });

  factory LencanaStatus.uang(
    StatusUang s, {
    Key? key,
    bool kepala = false,
    double jarakHuruf = 0,
  }) => LencanaStatus(
    s.label,
    key: key,
    bentuk: s.bentuk,
    kepala: kepala,
    jarakHuruf: jarakHuruf,
  );

  /// Glossary word, verbatim.
  final String label;
  final BentukLencana bentuk;
  final bool kepala;

  /// Main's transaction list adds .3.
  final double jarakHuruf;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final (GarisBorder? garis, Color? isi, Color teks) = switch (bentuk) {
      BentukLencana.draf => (
        GarisBorder.putus(c.putus, radius: 6),
        null,
        c.tinta2,
      ),
      BentukLencana.garis => (
        GarisBorder.penuh(c.tinta3, radius: 6),
        c.permukaan,
        c.tinta2,
      ),
      BentukLencana.tinta => (
        GarisBorder.penuh(c.tinta, radius: 6),
        c.tinta,
        c.permukaan,
      ),
      BentukLencana.laut => (
        GarisBorder.penuh(c.laut, radius: 6),
        c.laut,
        c.diLaut,
      ),
      BentukLencana.lautGaris => (
        GarisBorder.penuh(c.laut, radius: 6),
        c.permukaan,
        c.laut,
      ),
      BentukLencana.bata => (
        GarisBorder.penuh(c.bata, radius: 6),
        c.permukaan,
        c.bata,
      ),
      BentukLencana.abu => (
        GarisBorder.penuh(c.garis, radius: 6),
        c.garis,
        c.tinta2,
      ),
      BentukLencana.peran => (
        GarisBorder.penuh(c.tinta, radius: 6),
        c.permukaan,
        c.tinta,
      ),
      BentukLencana.usulanAI => (
        GarisBorder.titik(c.laut, radius: 6),
        null,
        c.lautTua,
      ),
      BentukLencana.terbalik => (null, c.permukaan, c.tinta),
    };
    final tanpaGaris = kepala || garis == null;
    return Container(
      padding: tanpaGaris
          ? const EdgeInsets.symmetric(horizontal: 10, vertical: 4)
          : bentuk == BentukLencana.usulanAI
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 2)
          : const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: ShapeDecoration(
        color: isi,
        shape: tanpaGaris
            ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))
            : garis,
      ),
      child: Text(
        label,
        softWrap: false,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: teks,
          letterSpacing: jarakHuruf,
        ),
      ),
    );
  }
}
