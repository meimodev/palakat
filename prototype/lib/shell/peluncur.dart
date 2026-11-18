import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../boards.dart';
import '../theme/palakat_tema.dart';

/// Launcher at `/` (components.md 4.10, navigation.md 4).
class Peluncur extends StatelessWidget {
  const Peluncur({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Material(
      color: c.kertas,
      child: ListView(children: [
        for (final (id, nama) in halamanKanvas) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
            child: Text(nama, style: PalakatText.judulBagian.copyWith(color: c.tinta)),
          ),
          for (final p in semuaPapan.where((p) => p.halaman == id))
            ListTile(title: Text(p.judul), subtitle: Text('/${p.stem}'), onTap: () => context.push('/${p.stem}')),
        ],
      ]),
    );
  }
}
