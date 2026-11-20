import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/finance/finance.dart';
import '../../motion/kerangka.dart';
import '../../providers/actor.dart';
import '../../providers/keuangan/beranda.dart';
import '../../providers/keuangan/laporan.dart';
import '../../providers/repositories_keuangan.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../app/layar.dart';

/// 16 · Daftar Bukti Kas dan celah nomor (spec 06-bukti.md, Bukti): the
/// chosen month's posted Bukti Kas (F12) and each year's numbers given
/// without a posted transaction (DP7).
class BuktiScreen extends ConsumerStatefulWidget {
  const BuktiScreen({super.key});

  @override
  ConsumerState<BuktiScreen> createState() => _BuktiScreenState();
}

const _mono = TextStyle(
  fontFamily: PalakatText.mono,
  fontFeatures: [FontFeature.tabularFigures()],
);

class _BuktiScreenState extends ConsumerState<BuktiScreen> {
  String _tab = 'Daftar';
  String? _bulan;

  /// Bumped on every chip press: the board re-renders the view, so the
  /// Celah nomor fade replays and the scroll goes back to the top.
  int _versi = 0;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final bulan = bulanBukti(ref, _bulan);
    return LayarPonsel(
      layarKeuangan: true,
      // CSS splits line-height leading evenly above and below each font;
      // without this the mono spans make mixed lines taller than the board.
      child: DefaultTextStyle.merge(
        style: const TextStyle(
          leadingDistribution: TextLeadingDistribution.even,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KepalaPonsel(
              judul: 'Daftar Bukti Kas',
              anakJudul: bulan == null
                  ? null
                  : '${namaBulan(bulan)} · '
                        '${bulan.isClosed ? 'Sudah ditutup' : 'Belum ditutup'}',
              kembaliKe: Layar.pengaturan,
              labelKembali: 'Kembali ke Lainnya',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: ChipPilihan<String>(
                pilihan: const [
                  (nilai: 'Daftar', teks: 'Daftar'),
                  (nilai: 'Celah nomor', teks: 'Celah nomor'),
                ],
                terpilih: _tab,
                onPilih: (t) => setState(() {
                  _tab = t;
                  _versi++;
                }),
                jarakBaris: 0,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                key: ValueKey(_versi),
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                child: _tab == 'Daftar'
                    ? _daftar(c, bulan)
                    : Gerak(
                        Kerangka.pudar,
                        lama: const Duration(milliseconds: 200),
                        child: _celahNomor(c),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _daftar(PalakatWarna c, Period? bulan) {
    final kecil = TextStyle(fontSize: 13, color: c.tinta2);
    final baris = bulan == null
        ? const <BarisBukti>[]
        : ref.watch(buktiBulanProvider(bulan.id));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PilihBulanBukti(
          terpilih: bulan,
          onPilih: (id) => setState(() => _bulan = id),
        ),
        const SizedBox(height: 10),
        for (final r in baris)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Kartu(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Text(
                          '${r.no} · ${r.tgl}',
                          style: _mono.copyWith(fontSize: 13, color: c.tinta2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        rp(r.jumlah),
                        style: _mono.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    r.ur,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (r.tanda.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(r.tanda, style: kecil),
                  ],
                  if (r.asal.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        text: 'No. bukti asal ',
                        children: [TextSpan(text: r.asal, style: _mono)],
                      ),
                      style: kecil,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: c.garis)),
                    ),
                    child: Text('Persetujuan: ${r.setuju}', style: kecil),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dokumen pendukung: ${r.dok}',
                    style: TextStyle(
                      fontSize: 13,
                      color: r.wajib ? c.bata : c.tinta2,
                      fontWeight: r.wajib ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        Text(
          baris.isEmpty
              ? 'Belum ada Bukti Kas di bulan ini.'
              : '${baris.length} Bukti Kas. Transaksi yang dibalik tetap ada '
                    'di daftar.',
          style: TextStyle(fontSize: 13, color: c.tinta3),
        ),
      ],
    );
  }

  Widget _celahNomor(PalakatWarna c) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final w in kartuCelah(ref, c)) ...[w, const SizedBox(height: 10)],
      Text(
        'Hanya terlihat oleh yang melihat seluruh Jemaat.',
        style: TextStyle(fontSize: 13, color: c.tinta3),
      ),
    ],
  );
}

/// The month Bukti lists: [id] when chosen, else Laporan's month.
Period? bulanBukti(WidgetRef ref, String? id) {
  final semua = ref.watch(bulanBukuProvider).semua;
  return semua.where((p) => p.id == id).firstOrNull ??
      ref.watch(laporanBulanProvider)?.periode;
}

/// Month chips: every month that has started, newest first.
class PilihBulanBukti extends ConsumerWidget {
  const PilihBulanBukti({
    super.key,
    required this.terpilih,
    required this.onPilih,
  });
  final Period? terpilih;
  final ValueChanged<String> onPilih;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hari = ref.watch(hariIniProvider);
    final bulan = [
      for (final p in ref.watch(bulanBukuProvider).semua.reversed)
        if (p.start <= hari) p,
    ];
    return ChipPilihan<String>(
      pilihan: [for (final p in bulan) (nilai: p.id, teks: namaBulan(p))],
      terpilih: terpilih?.id ?? '',
      onPilih: onPilih,
      jarakBaris: 0,
    );
  }
}

/// The gap cards: one per BKU year with its numbers given without a posted
/// transaction, then the OPN and ADJ series (DP7, DM F12).
List<Widget> kartuCelah(WidgetRef ref, PalakatWarna c) {
  const judul = TextStyle(fontSize: 15, fontWeight: FontWeight.w700);
  final sub = TextStyle(fontSize: 14, color: c.tinta2);
  final tx = ref.watch(transactionRepositoryProvider);
  Widget seri(String j, String s) => Kartu(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(j, style: judul),
        Text(s, style: sub),
      ],
    ),
  );
  final tahun = ref.watch(buktiProvider);
  final opn = [
    for (final b in tahun) ...tx.voucherSeries(VoucherSeries.opn, b.tahun),
  ];
  final opnCelah = [
    for (final e in opn)
      if (e.isGap) e,
  ];
  final adj = [
    for (final b in tahun) ...tx.voucherSeries(VoucherSeries.adj, b.tahun),
  ];
  return [
    for (final b in tahun)
      Kartu(
        status: GarisStatus.terpilih,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text.rich(
              TextSpan(
                text: 'Seri Biasa · ',
                children: [
                  TextSpan(text: b.nomor.first.code, style: _mono),
                  const TextSpan(text: ' sampai '),
                  TextSpan(
                    text: b.nomor.last.number.toString().padLeft(4, '0'),
                    style: _mono,
                  ),
                ],
              ),
              style: judul,
            ),
            const SizedBox(height: 4),
            Text(
              b.celah.isEmpty
                  ? 'Tidak ada celah'
                  : '${b.celah.length} nomor tanpa transaksi',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            for (final e in b.celah) ...[
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: e.code,
                      style: _mono.copyWith(color: c.tinta),
                    ),
                    TextSpan(
                      text:
                          '${e.unfinished == null ? '' : ' · diberikan ${tglJam(e.unfinished!.allocatedAt)}'}'
                          ', pembukuannya tidak selesai. Nomor ini tidak '
                          'dipakai ulang.',
                    ),
                  ],
                ),
                style: sub,
              ),
            ],
          ],
        ),
      ),
    seri(
      'Seri OPN Saldo awal pencatatan',
      opn.isEmpty
          ? 'Belum pernah dipakai'
          : opnCelah.isEmpty
          ? 'Tidak ada celah'
          : '${opnCelah.length} nomor tanpa transaksi',
    ),
    seri(
      'Seri ADJ Penyesuaian',
      adj.isEmpty ? 'Belum pernah dipakai' : '${adj.length} nomor',
    ),
  ];
}
