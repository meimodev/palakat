import 'package:flutter/material.dart';

import '../../shell/belum_dibangun.dart';
import '../../shell/kendali.dart';

class KameraKendali extends StatefulWidget {
  const KameraKendali({super.key, required this.child});
  final Widget child;
  @override
  State<KameraKendali> createState() => _KameraKendaliState();
}

class _KameraKendaliState extends State<KameraKendali> {
  @override
  Widget build(BuildContext context) => GenerasiPapan(generasi: 0, child: widget.child);
}

class KameraScreen extends StatelessWidget {
  const KameraScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;
  @override
  Widget build(BuildContext context) => BelumDibangun(stem: 'Kamera', anak: anak);
}
