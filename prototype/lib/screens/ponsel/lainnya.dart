import 'package:flutter/material.dart';

import '../../shell/belum_dibangun.dart';
import '../../shell/kendali.dart';

class LainnyaKendali extends StatefulWidget {
  const LainnyaKendali({super.key, required this.child});
  final Widget child;
  @override
  State<LainnyaKendali> createState() => _LainnyaKendaliState();
}

class _LainnyaKendaliState extends State<LainnyaKendali> {
  @override
  Widget build(BuildContext context) => GenerasiPapan(generasi: 0, child: widget.child);
}

class LainnyaScreen extends StatelessWidget {
  const LainnyaScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;
  @override
  Widget build(BuildContext context) => BelumDibangun(stem: 'Lainnya', anak: anak);
}
