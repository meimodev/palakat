import 'package:flutter/material.dart';

import '../../shell/belum_dibangun.dart';
import '../../shell/kendali.dart';

class LaporanKendali extends StatefulWidget {
  const LaporanKendali({super.key, required this.child});
  final Widget child;
  @override
  State<LaporanKendali> createState() => _LaporanKendaliState();
}

class _LaporanKendaliState extends State<LaporanKendali> {
  @override
  Widget build(BuildContext context) => GenerasiPapan(generasi: 0, child: widget.child);
}

class LaporanScreen extends StatelessWidget {
  const LaporanScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;
  @override
  Widget build(BuildContext context) => BelumDibangun(stem: 'Laporan', anak: anak);
}
