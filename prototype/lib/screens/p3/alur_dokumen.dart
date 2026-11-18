import 'package:flutter/material.dart';

import '../../shell/belum_dibangun.dart';
import '../../shell/kendali.dart';

class AlurDokumenKendali extends StatefulWidget {
  const AlurDokumenKendali({super.key, required this.child});
  final Widget child;
  @override
  State<AlurDokumenKendali> createState() => _AlurDokumenKendaliState();
}

class _AlurDokumenKendaliState extends State<AlurDokumenKendali> {
  @override
  Widget build(BuildContext context) => GenerasiPapan(generasi: 0, child: widget.child);
}

class AlurDokumenScreen extends StatelessWidget {
  const AlurDokumenScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;
  @override
  Widget build(BuildContext context) => BelumDibangun(stem: 'AlurDokumen', anak: anak);
}
