import 'package:flutter/material.dart';

import '../../shell/belum_dibangun.dart';
import '../../shell/kendali.dart';

class KoreksiKendali extends StatefulWidget {
  const KoreksiKendali({super.key, required this.child});
  final Widget child;
  @override
  State<KoreksiKendali> createState() => _KoreksiKendaliState();
}

class _KoreksiKendaliState extends State<KoreksiKendali> {
  @override
  Widget build(BuildContext context) => GenerasiPapan(generasi: 0, child: widget.child);
}

class KoreksiScreen extends StatelessWidget {
  const KoreksiScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;
  @override
  Widget build(BuildContext context) => BelumDibangun(stem: 'Koreksi', anak: anak);
}
