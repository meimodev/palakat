import 'package:flutter/material.dart';

import '../../shell/belum_dibangun.dart';
import '../../shell/kendali.dart';

class MataAnggaranKendali extends StatefulWidget {
  const MataAnggaranKendali({super.key, required this.child});
  final Widget child;
  @override
  State<MataAnggaranKendali> createState() => _MataAnggaranKendaliState();
}

class _MataAnggaranKendaliState extends State<MataAnggaranKendali> {
  @override
  Widget build(BuildContext context) => GenerasiPapan(generasi: 0, child: widget.child);
}

class MataAnggaranScreen extends StatelessWidget {
  const MataAnggaranScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;
  @override
  Widget build(BuildContext context) => BelumDibangun(stem: 'MataAnggaran', anak: anak);
}
