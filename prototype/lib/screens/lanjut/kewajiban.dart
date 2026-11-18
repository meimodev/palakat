import 'package:flutter/material.dart';

import '../../shell/belum_dibangun.dart';
import '../../shell/kendali.dart';

class KewajibanKendali extends StatefulWidget {
  const KewajibanKendali({super.key, required this.child});
  final Widget child;
  @override
  State<KewajibanKendali> createState() => _KewajibanKendaliState();
}

class _KewajibanKendaliState extends State<KewajibanKendali> {
  @override
  Widget build(BuildContext context) => GenerasiPapan(generasi: 0, child: widget.child);
}

class KewajibanScreen extends StatelessWidget {
  const KewajibanScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;
  @override
  Widget build(BuildContext context) => BelumDibangun(stem: 'Kewajiban', anak: anak);
}
