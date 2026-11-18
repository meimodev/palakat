import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/palakat_tema.dart';

/// Unknown route (navigation.md 5.5).
class TidakDitemukanScreen extends StatelessWidget {
  const TidakDitemukanScreen({super.key, required this.lokasi});
  final String lokasi;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return ColoredBox(
      color: c.kertas,
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Layar tidak ditemukan', style: PalakatText.judulBesar.copyWith(color: c.tinta)),
          const SizedBox(height: 8),
          Text(lokasi, style: PalakatText.kode.copyWith(color: c.tinta3)),
          const SizedBox(height: 20),
          FilledButton(onPressed: () => context.go('/'), child: const Text('Semua layar')),
        ]),
      ),
    );
  }
}
