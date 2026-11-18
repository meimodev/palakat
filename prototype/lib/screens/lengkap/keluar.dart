import 'package:flutter/material.dart';

import '../../shell/belum_dibangun.dart';
import '../../shell/kendali.dart';

class KeluarKendali extends StatefulWidget {
  const KeluarKendali({super.key, required this.child});
  final Widget child;
  @override
  State<KeluarKendali> createState() => _KeluarKendaliState();
}

class _KeluarKendaliState extends State<KeluarKendali> {
  @override
  Widget build(BuildContext context) => GenerasiPapan(generasi: 0, child: widget.child);
}

class KeluarScreen extends StatelessWidget {
  const KeluarScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;
  @override
  Widget build(BuildContext context) => BelumDibangun(stem: 'Keluar', anak: anak);
}
