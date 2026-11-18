import 'package:flutter/widgets.dart';

import '../theme/palakat_warna.dart';
import 'garis.dart';

/// The line language: a draft is dashed and unfilled, a booked item solid,
/// a closed one filled `tinta`, an AI suggestion dotted `laut`, a blocker `bata`.
enum GarisStatus { draf, dibukukan, terpilih, ditutup, usulanAI, hambatan }

extension GarisStatusGaya on GarisStatus {
  /// Border and fill for a card, badge or banner in this status.
  ({GarisBorder? garis, Color? isi}) gaya(
    PalakatWarna c, {
    double radius = 14,
  }) => switch (this) {
    GarisStatus.draf => (
      garis: GarisBorder.putus(c.putus, radius: radius),
      isi: null,
    ),
    GarisStatus.dibukukan => (
      garis: GarisBorder.penuh(c.garis, tebal: 1, radius: radius),
      isi: c.permukaan,
    ),
    GarisStatus.terpilih => (
      garis: GarisBorder.penuh(c.tinta, radius: radius),
      isi: c.permukaan,
    ),
    GarisStatus.ditutup => (garis: null, isi: c.tinta),
    GarisStatus.usulanAI => (
      garis: GarisBorder.titik(c.laut, radius: radius),
      isi: c.permukaan,
    ),
    GarisStatus.hambatan => (
      garis: GarisBorder.penuh(c.bata, radius: radius),
      isi: c.permukaan,
    ),
  };
}
