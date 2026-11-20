import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../a4/a4_f01.dart';
import '../lanjut/laporan_tabel.dart';

/// A4 · F01 Laporan sementara: the route month's F01 before its close (the
/// same page, with the provisional ribbon and no report ID).
class A4SementaraScreen extends ConsumerWidget {
  const A4SementaraScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = laporanRute(context, ref);
    return l == null ? const SizedBox.shrink() : HalamanF01(l);
  }
}
