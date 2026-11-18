import 'package:flutter/material.dart';

import '../../shell/belum_dibangun.dart';
import '../../shell/kendali.dart';

class PersembahanKendali extends StatefulWidget {
  const PersembahanKendali({super.key, required this.child});
  final Widget child;
  @override
  State<PersembahanKendali> createState() => _PersembahanKendaliState();
}

class _PersembahanKendaliState extends State<PersembahanKendali> {
  @override
  Widget build(BuildContext context) => GenerasiPapan(generasi: 0, child: widget.child);
}

class PersembahanScreen extends StatelessWidget {
  const PersembahanScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;
  @override
  Widget build(BuildContext context) => BelumDibangun(stem: 'Persembahan', anak: anak);
}
