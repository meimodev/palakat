import 'package:flutter/material.dart';

import '../../shell/belum_dibangun.dart';
import '../../shell/kendali.dart';

class MainKendali extends StatefulWidget {
  const MainKendali({super.key, required this.child});
  final Widget child;
  @override
  State<MainKendali> createState() => _MainKendaliState();
}

class _MainKendaliState extends State<MainKendali> {
  @override
  Widget build(BuildContext context) => GenerasiPapan(generasi: 0, child: widget.child);
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;
  @override
  Widget build(BuildContext context) => BelumDibangun(stem: 'Main', anak: anak);
}
