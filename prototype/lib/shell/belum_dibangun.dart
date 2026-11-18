import 'package:flutter/material.dart';

import '../boards.dart';
import '../theme/palakat_tema.dart';

/// Placeholder for a board that is not built yet (M0 stub).
class BelumDibangun extends StatelessWidget {
  const BelumDibangun({super.key, required this.stem, this.anak});
  final String stem;
  final String? anak;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final p = papanMenurutStem[stem]!;
    return ColoredBox(
      color: c.kertas,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                p.judul,
                textAlign: TextAlign.center,
                style: PalakatText.judulLayar.copyWith(color: c.tinta),
              ),
              const SizedBox(height: 8),
              Text(
                anak == null ? 'Belum dibangun' : 'Belum dibangun · $anak',
                style: PalakatText.keterangan.copyWith(color: c.tinta3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
