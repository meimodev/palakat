import 'package:flutter/widgets.dart';

import '../lengkap/web_catat.dart';

/// Tablet · Catat (spec 13-tabberanda.md, TabCatat): the laptop board at tablet
/// width (README D13). The tablet shell is the web scaffold unchanged
/// (HalamanTablet = HalamanWeb), so this is WebCatatScreen itself: one record,
/// one number, one date with the web twin.
class TabCatatScreen extends StatelessWidget {
  const TabCatatScreen({super.key});

  @override
  Widget build(BuildContext context) => const WebCatatScreen();
}
