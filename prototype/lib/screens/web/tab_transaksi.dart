import 'package:flutter/widgets.dart';

import 'web_transaksi.dart';

/// Tablet · Transaksi (spec 13-tabberanda.md, TabTransaksi): the laptop board at tablet
/// width (README D13). The tablet shell is the web scaffold unchanged
/// (HalamanTablet = HalamanWeb), so this is WebTransaksiScreen itself: one record,
/// one number, one date with the web twin.
class TabTransaksiScreen extends StatelessWidget {
  const TabTransaksiScreen({super.key});

  @override
  Widget build(BuildContext context) => const WebTransaksiScreen();
}
