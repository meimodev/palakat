import 'package:flutter/material.dart';

import '../../shell/belum_dibangun.dart';
import '../../shell/kendali.dart';

class AwalKendali extends StatefulWidget {
  const AwalKendali({super.key, required this.child});
  final Widget child;
  @override
  State<AwalKendali> createState() => _AwalKendaliState();
}

class _AwalKendaliState extends State<AwalKendali> {
  @override
  Widget build(BuildContext context) => GenerasiPapan(generasi: 0, child: widget.child);
}

class AwalScreen extends StatelessWidget {
  const AwalScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;
  @override
  Widget build(BuildContext context) => BelumDibangun(stem: 'Awal', anak: anak);
}
