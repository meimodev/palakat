import 'package:flutter/widgets.dart';

import 'ikon.dart';

/// The Palakat mark (components.md 2.6): `Ikon.tanda` in `laut`; aria-hidden.
/// 26 in the side nav, phone headers and Awal; 40 on Masuk, WebMasuk.
class TandaPalakat extends StatelessWidget {
  const TandaPalakat({super.key, this.ukuran = 26});
  final double ukuran;

  @override
  Widget build(BuildContext context) => PalakatIkon(Ikon.tanda, ukuran: ukuran);
}

/// The word mark 'palakat', lower case, 700, colour inherited (tinta).
/// Side nav 18 / line height 1.1; Awal 17; Masuk, WebMasuk 30 with letter spacing −0.5.
class KataPalakat extends StatelessWidget {
  const KataPalakat({
    super.key,
    this.ukuran = 18,
    this.jarakHuruf = 0,
    this.tinggiBaris = 1.1,
  });
  final double ukuran;
  final double jarakHuruf;
  final double tinggiBaris;

  @override
  Widget build(BuildContext context) => Text(
    'palakat',
    style: TextStyle(
      fontSize: ukuran,
      fontWeight: FontWeight.w700,
      letterSpacing: jarakHuruf,
      height: tinggiBaris,
    ),
  );
}
