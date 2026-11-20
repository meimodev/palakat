import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/secretariat/secretariat.dart';
import '../../providers/core_repositories.dart';
import '../../providers/repositories_sekretariat.dart';
import '../../providers/revision.dart';
import '../../shell/halaman_a4.dart';
import '../../theme/palakat_tema.dart';
import 'warta_arsip_bagian.dart';

/// One printed section of an edition: heading and lines (A4Warta,
/// WebWartaEditor's preview).
typedef BagianWarta = ({String judul, List<Widget> baris});

/// The sections an edition prints, in A4Warta's order, from its preview:
/// only data already recorded; an empty section is left out (spec 18).
List<BagianWarta> bagianWarta(WartaPreview p) {
  final e = p.edition;
  return [
    if (e.services case final s?)
      (
        judul: 'Ibadah minggu ini',
        baris: [
          for (final x in s.split(' · '))
            if (x.split(' ') case [final nama, final jam])
              _Baris('Ibadah $nama', jam),
        ],
      ),
    if (p.announcements.isNotEmpty)
      (
        judul: 'Pengumuman',
        baris: [
          for (final a in p.announcements)
            _Paragraf('${a.title}.', ' ${a.body}'),
        ],
      ),
    if (p.events.isNotEmpty)
      (
        judul: 'Peristiwa jemaat',
        baris: [
          for (final x in p.events) Text('${x.event.label}: ${x.printed}'),
        ],
      ),
    if (e.attendance case final h?)
      (
        judul: 'Jumlah kehadiran · Minggu, ${tglPanjang(h.sunday.awal)}',
        baris: [
          for (final x in h.parts.split(' · '))
            if (x.split(' ') case [final nama, final n])
              _Baris('Ibadah $nama', n),
          _Baris('Jumlah', '${h.total}', jumlah: true),
        ],
      ),
  ];
}

/// A4Warta (Q27, README 7.1 rule 5): the edition of the route's `:edisi`
/// rendered from its data on the fixed A4 page. Masthead and footer come
/// from [HalamanA4.warta].
class A4WartaScreen extends ConsumerWidget {
  const A4WartaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(revisionProvider);
    final p = ref
        .watch(wartaRepositoryProvider)
        .preview(edisiDariRute(context));
    final gereja = ref.watch(workspaceRepositoryProvider).workspace().name;
    if (p == null) {
      return const Center(child: Text('Edisi ini tidak ditemukan.'));
    }
    final e = p.edition;
    return HalamanA4.warta(
      subjudul: 'GMIM $gereja · Minggu, ${tglPanjang(e.sunday.awal)}',
      kakiKanan: 'Edisi ${tgl(e.sunday.awal)} · halaman 1 dari 1',
      kakiKiri: e.publishedAt == null
          ? 'Belum diterbitkan · pratinjau · nama mengikuti Tampilan nama '
                'pilihan anggota'
          : 'Diterbitkan ${tgl(e.publishedAt!)} oleh Sekretaris Jemaat · nama '
                'mengikuti Tampilan nama pilihan anggota',
      isi: [for (final b in bagianWarta(p)) _Bagian(b.judul, b.baris)],
    );
  }
}

/// Section: 13/700 upper-case heading, letter-spacing .5, a 1.5 `tinta` rule
/// under it (padding-bottom 3, margin-bottom 6), then lines with gap 3.
class _Bagian extends StatelessWidget {
  const _Bagian(this.judul, this.baris);

  final String judul;
  final List<Widget> baris;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Container(
        padding: const EdgeInsets.only(bottom: 3),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: context.warna.tinta, width: 1.5),
          ),
        ),
        child: Semantics(
          header: true,
          child: Text(
            judul.toUpperCase(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: .5,
            ),
          ),
        ),
      ),
      for (var i = 0; i < baris.length; i++) ...[
        if (i > 0) const SizedBox(height: 3),
        baris[i],
      ],
    ],
  );
}

/// Label left, mono value right (never shrinking). [jumlah]: the 700 total
/// row with a 1 `tinta` rule above, padding-top 3.
class _Baris extends StatelessWidget {
  const _Baris(this.label, this.nilai, {this.jumlah = false});

  final String label, nilai;
  final bool jumlah;

  @override
  Widget build(BuildContext context) {
    final baris = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: 16),
        Text(nilai, style: const TextStyle(fontFamily: PalakatText.mono)),
      ],
    );
    if (!jumlah) return baris;
    return Container(
      padding: const EdgeInsets.only(top: 3),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.warna.tinta)),
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontWeight: FontWeight.w700),
        child: baris,
      ),
    );
  }
}

class _Paragraf extends StatelessWidget {
  const _Paragraf(this.tebal, this.sisa);

  final String tebal, sisa;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: [
        TextSpan(
          text: tebal,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        TextSpan(text: sisa),
      ],
    ),
  );
}
