import 'package:flutter/material.dart';

import '../../shell/belum_dibangun.dart';
import '../../shell/kendali.dart';

class TutupBukuKendali extends StatefulWidget {
  const TutupBukuKendali({super.key, required this.child});
  final Widget child;
  @override
  State<TutupBukuKendali> createState() => _TutupBukuKendaliState();
}

class _TutupBukuKendaliState extends State<TutupBukuKendali> {
  @override
  Widget build(BuildContext context) => GenerasiPapan(generasi: 0, child: widget.child);
}

class TutupBukuScreen extends StatelessWidget {
  const TutupBukuScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;
  @override
  Widget build(BuildContext context) => BelumDibangun(stem: 'TutupBuku', anak: anak);
}
