import 'package:flutter/material.dart';

import '../../shell/belum_dibangun.dart';
import '../../shell/kendali.dart';

class TerbatasKendali extends StatefulWidget {
  const TerbatasKendali({super.key, required this.child});
  final Widget child;
  @override
  State<TerbatasKendali> createState() => _TerbatasKendaliState();
}

class _TerbatasKendaliState extends State<TerbatasKendali> {
  @override
  Widget build(BuildContext context) => GenerasiPapan(generasi: 0, child: widget.child);
}

class TerbatasScreen extends StatelessWidget {
  const TerbatasScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;
  @override
  Widget build(BuildContext context) => BelumDibangun(stem: 'Terbatas', anak: anak);
}
