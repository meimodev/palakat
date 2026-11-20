import 'package:flutter/widgets.dart';

import 'web_beranda.dart';

/// Tablet · Beranda (spec 13-tabberanda.md, TabBeranda): the laptop board at tablet
/// width (README D13). The tablet shell is the web scaffold unchanged
/// (HalamanTablet = HalamanWeb), so this is WebBerandaScreen itself: one record,
/// one number, one date with the web twin.
class TabBerandaScreen extends StatelessWidget {
  const TabBerandaScreen({super.key});

  @override
  Widget build(BuildContext context) => const WebBerandaScreen();
}
