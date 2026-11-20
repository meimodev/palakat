import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/session.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/kecil.dart';
import '../../widgets/logo.dart';

/// The persona picker (README 5.2, D7, D17): "Masuk sebagai", one row per
/// persona under its role heading. Tapping a row signs in; the router then
/// opens the role home.
class PemilihPersonaScreen extends ConsumerWidget {
  const PemilihPersonaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    return Material(
      color: c.kertas,
      child: DefaultTextStyle(
        style: PalakatText.isi.copyWith(color: c.tinta),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        TandaPalakat(),
                        SizedBox(width: 10),
                        KataPalakat(),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Semantics(
                      header: true,
                      child: Text(
                        'Masuk sebagai',
                        style: PalakatText.judulBesar.copyWith(color: c.tinta),
                      ),
                    ),
                    for (final (judul, persona) in kelompokPersona) ...[
                      const SizedBox(height: 24),
                      JudulBagian(judul),
                      const SizedBox(height: 8),
                      Kartu(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            for (var i = 0; i < persona.length; i++)
                              BarisDaftar(
                                judul: persona[i].nama,
                                keterangan: persona[i].jabatan,
                                pertama: i == 0,
                                label: 'Masuk sebagai ${persona[i].nama}',
                                onTap: () => ref
                                    .read(sessionProvider.notifier)
                                    .masuk(persona[i]),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
