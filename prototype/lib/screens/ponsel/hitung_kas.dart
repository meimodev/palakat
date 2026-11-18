import 'package:flutter/material.dart';

import '../../shell/belum_dibangun.dart';
import '../../shell/kendali.dart';

class HitungKasKendali extends StatefulWidget {
  const HitungKasKendali({super.key, required this.child});
  final Widget child;
  @override
  State<HitungKasKendali> createState() => _HitungKasKendaliState();
}

class _HitungKasKendaliState extends State<HitungKasKendali> {
  @override
  Widget build(BuildContext context) => GenerasiPapan(generasi: 0, child: widget.child);
}

class HitungKasScreen extends StatelessWidget {
  const HitungKasScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;
  @override
  Widget build(BuildContext context) => BelumDibangun(stem: 'HitungKas', anak: anak);
}
