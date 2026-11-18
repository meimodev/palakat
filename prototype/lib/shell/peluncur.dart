import 'package:flutter/material.dart';

import '../boards.dart';
import '../theme/palakat_tema.dart';
import '../widgets/chip_pilihan.dart';
import '../widgets/garis.dart';
import '../widgets/ikon.dart';
import '../widgets/kecil.dart';
import 'halaman_web.dart';
import 'perjalanan.dart';
import 'prototipe_state.dart';
import 'tautan.dart';

/// Launcher at `/` (components.md 4.10, navigation.md 4): every board by canvas
/// page or by role journey. A laptop-style page: [HalamanWeb] without nav.
class Peluncur extends StatelessWidget {
  const Peluncur({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final k = context.prototipe;
    return HalamanWeb(
      nav: null,
      isi: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                'Palakat · prototipe',
                style: PalakatText.judulHalaman.copyWith(color: c.tinta),
              ),
            ),
            Text(
              '${semuaPapan.length} layar · data contoh, tanpa server',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ],
        ),
        ChipPilihan<bool>(
          label: 'Urutkan menurut',
          pilihan: const [
            (nilai: false, teks: 'Halaman kanvas'),
            (nilai: true, teks: 'Perjalanan jabatan'),
          ],
          terpilih: k.urutPerjalanan,
          onPilih: (v) => k.urutPerjalanan = v,
        ),
        _kartu([
          Tautan(
            ke: '_komponen',
            child: const _Baris(
              judul: 'Komponen',
              kode: '/_komponen',
              pertama: true,
            ),
          ),
        ]),
        if (!k.urutPerjalanan)
          for (final (id, nama) in halamanKanvas) _halaman(id, nama)
        else
          for (final j in perjalananJabatan) _Perjalanan(j),
      ],
    );
  }

  static Widget _kartu(List<Widget> baris) => Kartu(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: baris,
    ),
  );

  static Widget _halaman(String id, String nama) {
    final papan = semuaPapan.where((p) => p.halaman == id).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        JudulBagian('$nama · ${papan.length} layar', web: true),
        _kartu([
          for (final (i, p) in papan.indexed)
            Tautan(
              ke: p.stem,
              cara: Cara.ganti,
              child: _Baris(judul: p.judul, kode: p.stem, pertama: i == 0),
            ),
        ]),
      ],
    );
  }
}

/// A launcher row: canvas title (600) and stem (mono 13 `tinta3`), chevron.
class _Baris extends StatelessWidget {
  const _Baris({required this.judul, required this.kode, this.pertama = false});
  final String judul, kode;
  final bool pertama;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!pertama) GarisLurus(warna: c.garis),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 60),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      judul,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      kode,
                      style: PalakatText.kode.copyWith(color: c.tinta3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              PalakatIkon(Ikon.lanjut, ukuran: 18, warna: c.tinta3),
            ],
          ),
        ),
      ],
    );
  }
}

/// One role of "Perjalanan jabatan": heading, then a card of numbered steps.
class _Perjalanan extends StatelessWidget {
  const _Perjalanan(this.j);
  final Perjalanan j;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final kode = PalakatText.kode.copyWith(color: c.tinta3);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        JudulBagian(j.peran, web: true),
        Peluncur._kartu([
          for (final (i, langkah) in j.langkah.indexed) ...[
            if (i > 0) GarisLurus(warna: c.garis),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10,
                      children: [
                        for (final e in langkah)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 4,
                            children: [
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: e.judul,
                                      style: e.ke.isEmpty
                                          ? TextStyle(color: c.tinta2)
                                          : const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                    ),
                                    if (e.catatan != null)
                                      TextSpan(
                                        text: ' (${e.catatan})',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: c.tinta3,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (e.ke.isNotEmpty)
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    for (final t in e.ke)
                                      Tautan(
                                        ke: t.stem,
                                        cara: Cara.ganti,
                                        radius: 999,
                                        child: Container(
                                          constraints: const BoxConstraints(
                                            minHeight: 44,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                          ),
                                          decoration: BoxDecoration(
                                            color: c.permukaan,
                                            border: Border.all(
                                              color: c.garisTegas,
                                              width: 1.5,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                t.jenis,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(t.stem, style: kode),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ]),
      ],
    );
  }
}
