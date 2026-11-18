import 'package:flutter/material.dart';

import '../../shell/belum_dibangun.dart';
import '../../shell/kendali.dart';

class KejadianKendali extends StatefulWidget {
  const KejadianKendali({super.key, required this.child});
  final Widget child;
  @override
  State<KejadianKendali> createState() => _KejadianKendaliState();
}

class _KejadianKendaliState extends State<KejadianKendali> {
  @override
  Widget build(BuildContext context) => GenerasiPapan(generasi: 0, child: widget.child);
}

class KejadianScreen extends StatelessWidget {
  const KejadianScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;
  @override
  Widget build(BuildContext context) => BelumDibangun(stem: 'Kejadian', anak: anak);
}
