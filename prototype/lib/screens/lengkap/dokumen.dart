import 'package:flutter/material.dart';

import '../../shell/belum_dibangun.dart';
import '../../shell/kendali.dart';

class DokumenKendali extends StatefulWidget {
  const DokumenKendali({super.key, required this.child});
  final Widget child;
  @override
  State<DokumenKendali> createState() => _DokumenKendaliState();
}

class _DokumenKendaliState extends State<DokumenKendali> {
  @override
  Widget build(BuildContext context) => GenerasiPapan(generasi: 0, child: widget.child);
}

class DokumenScreen extends StatelessWidget {
  const DokumenScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;
  @override
  Widget build(BuildContext context) => BelumDibangun(stem: 'Dokumen', anak: anak);
}
