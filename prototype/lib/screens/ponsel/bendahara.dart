import 'package:flutter/material.dart';

import '../../shell/belum_dibangun.dart';
import '../../shell/kendali.dart';

class BendaharaKendali extends StatefulWidget {
  const BendaharaKendali({super.key, required this.child});
  final Widget child;
  @override
  State<BendaharaKendali> createState() => _BendaharaKendaliState();
}

class _BendaharaKendaliState extends State<BendaharaKendali> {
  @override
  Widget build(BuildContext context) => GenerasiPapan(generasi: 0, child: widget.child);
}

class BendaharaScreen extends StatelessWidget {
  const BendaharaScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;
  @override
  Widget build(BuildContext context) => BelumDibangun(stem: 'Bendahara', anak: anak);
}
