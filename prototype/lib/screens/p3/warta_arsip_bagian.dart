import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/layar.dart';
import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../domain/secretariat/secretariat.dart';
import '../../providers/actor.dart';
import '../../providers/repositories_sekretariat.dart';
import '../../providers/revision.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import 'sekretariat_bersama.dart';

/// Button row with one button: `flex: 1 1 150px; max-width: 340px`.
Widget tombolWarta(Widget tombol, {double maks = 372}) => Align(
  alignment: Alignment.centerLeft,
  child: ConstrainedBox(
    constraints: BoxConstraints(maxWidth: maks),
    child: tombol,
  ),
);

LencanaStatus lencanaWarta(WartaStatus s) => LencanaStatus(
  s.label,
  bentuk: switch (s) {
    WartaStatus.draft => BentukLencana.draf,
    WartaStatus.review => BentukLencana.lautGaris,
    WartaStatus.approved => BentukLencana.laut,
    WartaStatus.published => BentukLencana.tinta,
    WartaStatus.retired => BentukLencana.abu,
  },
);

/// Opens the editor of the coming Sunday's edition, drafting it first when
/// it does not exist yet (WartaArsip "Susun edisi …").
Future<void> susunEdisi(BuildContext context, WidgetRef ref) async {
  final repo = ref.read(wartaRepositoryProvider);
  final minggu = mingguDepan(ref.read(hariIniProvider));
  var e = repo.editions().where((x) => x.sunday == minggu).firstOrNull;
  if (e == null) {
    final r = await repo.draft(
      aktorSek(ref),
      minggu,
      idempotencyKey: kunciSek(ref),
    );
    if (r case Ok(:final value)) e = value;
  }
  if (e == null || !context.mounted) return;
  context.dorongKe(Layar.wartaEdisi, param: {'edisi': e.id});
}

/// WartaArsip and WebWartaArsip (spec 18): the published editions, exactly
/// as published, newest first. A row opens the edition in place with "Unduh
/// PDF" and its ralat; the Sekretaris Jemaat composes the coming Sunday's.
class IsiWartaArsip extends ConsumerStatefulWidget {
  const IsiWartaArsip({super.key, required this.web});

  final bool web;

  @override
  ConsumerState<IsiWartaArsip> createState() => _IsiWartaArsipState();
}

class _IsiWartaArsipState extends ConsumerState<IsiWartaArsip> {
  String? _pilih;

  void _ke(String? id) {
    setState(() => _pilih = id);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Scrollable.maybeOf(context)?.position.jumpTo(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(revisionProvider);
    final c = context.warna;
    final repo = ref.watch(wartaRepositoryProvider);
    final terbit = [
      for (final e in repo.editions())
        if (e.status == WartaStatus.published ||
            e.status == WartaStatus.retired)
          e,
    ];
    final editor = bolehSek(ref, Capability.wartaEdit);
    final minggu = mingguDepan(ref.watch(hariIniProvider));
    final depan = repo.editions().where((x) => x.sunday == minggu).firstOrNull;
    final bolehSusun =
        editor &&
        (depan == null ||
            depan.status != WartaStatus.published &&
                depan.status != WartaStatus.retired);
    final e = terbit.where((x) => x.id == _pilih).firstOrNull;
    final t14 = TextStyle(fontSize: 14, color: c.tinta2);

    Widget susun(String label) => tombolWarta(
      Tombol(
        label,
        jenis: JenisTombol.tinta,
        onPressed: () => susunEdisi(context, ref),
      ),
    );

    if (e != null) {
      return kolomSek([
        Kartu(
          child: kolomSek([
            KepalaKartuWarta('Edisi ${tgl(e.sunday.awal)}', e.status),
            Text(
              'Diterbitkan ${tglJam(e.publishedAt!)} · tidak diubah',
              style: t14,
            ),
            tombolWarta(
              Tombol(
                'Unduh PDF',
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.sedang,
                onPressed: () =>
                    context.dorongKe(Layar.wartaPdf, param: {'edisi': e.id}),
              ),
              maks: 340,
            ),
          ], 6),
        ),
        for (final r in e.ralats)
          Kartu(
            status: GarisStatus.draf,
            child: kolomSek([
              KepalaKartuWarta(
                'Ralat (revisi edisi ${tgl(e.sunday.awal)})',
                WartaStatus.published,
              ),
              Text(r.text, style: t14),
              kecilSek(
                context,
                'Tertaut ke edisi asli, yang tetap tampil apa adanya. '
                'Diterbitkan ${tglJam(r.at)} oleh ${namaSek(ref, r.by)}.',
              ),
            ], 6),
          ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Tombol(
            'Semua edisi',
            onPressed: () => _ke(null),
            jenis: JenisTombol.teks,
            ukuran: UkuranTombol.kecil,
            lebarPenuh: false,
          ),
        ),
      ], 16);
    }

    if (terbit.isEmpty) {
      return kolomSek([
        Kartu(
          status: GarisStatus.draf,
          child: kolomSek([
            const Text(
              'Belum ada edisi yang diterbitkan',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              'Edisi pertama dapat disusun dari pengumuman yang sudah '
              'diterbitkan.',
              style: t14,
            ),
          ], 6),
        ),
        if (bolehSusun) susun('Susun edisi pertama'),
      ], 16);
    }

    return kolomSek([
      if (widget.web)
        _Tabel(daftar: terbit, onBuka: _ke)
      else
        for (final x in terbit) _Baris(x, onBuka: _ke),
      if (bolehSusun) susun('Susun edisi ${tgl(minggu.awal)}'),
      if (!editor)
        kecilSek(
          context,
          'Anggota membaca edisi yang ditujukan untuknya. Nama tampil sesuai '
          'pilihan tiap anggota saat edisi itu diterbitkan; pindah Kolom atau '
          'mengubah pilihan kemudian tidak mengubah edisi lama.',
        ),
    ], 16);
  }
}

/// Card head: 700 title, the status badge at the end.
class KepalaKartuWarta extends StatelessWidget {
  const KepalaKartuWarta(this.judul, this.status, {super.key});
  final String judul;
  final WartaStatus status;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Flexible(
        child: Text(judul, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      const SizedBox(width: 16),
      lencanaWarta(status),
    ],
  );
}

String _ketEdisi(WartaEdition e) =>
    'Diterbitkan ${tglJam(e.publishedAt!)}'
    '${e.ralats.isEmpty ? '' : ' · ${e.ralats.length} ralat'}';

/// Phone row: its own card; opens the edition in place.
class _Baris extends StatelessWidget {
  const _Baris(this.e, {required this.onBuka});
  final WartaEdition e;
  final ValueChanged<String> onBuka;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tautan(
      ke: Layar.warta,
      diSini: () => onBuka(e.id),
      radius: 14,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 70),
        child: Kartu(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edisi ${tgl(e.sunday.awal)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _ketEdisi(e),
                      style: TextStyle(fontSize: 13, color: c.tinta3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              lencanaWarta(e.status),
              const SizedBox(width: 12),
              PalakatIkon(Ikon.lanjut, ukuran: 18, warna: c.tinta3),
            ],
          ),
        ),
      ),
    );
  }
}

/// Web table: one card, rows with a top rule.
class _Tabel extends StatelessWidget {
  const _Tabel({required this.daftar, required this.onBuka});
  final List<WartaEdition> daftar;
  final ValueChanged<String> onBuka;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Kartu(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, e) in daftar.indexed)
              Tautan(
                ke: Layar.warta,
                diSini: () => onBuka(e.id),
                child: Container(
                  decoration: BoxDecoration(
                    border: i == 0
                        ? null
                        : Border(top: BorderSide(color: c.garis)),
                  ),
                  constraints: BoxConstraints(minHeight: i == 0 ? 68 : 69),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: BarisLentur(
                          jarak: 20,
                          jarakBaris: 2,
                          anak: [
                            Lentur(
                              dasar: 260,
                              child: Text(
                                'Edisi ${tgl(e.sunday.awal)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Lentur(
                              dasar: 300,
                              tumbuh: 1.4,
                              child: Text(
                                _ketEdisi(e),
                                style: TextStyle(fontSize: 13, color: c.tinta3),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      lencanaWarta(e.status),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 20,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: PalakatIkon(
                            Ikon.lanjut,
                            ukuran: 18,
                            warna: c.tinta3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The router's `:edisi`.
String edisiDariRute(BuildContext context) =>
    GoRouterState.of(context).pathParameters['edisi'] ?? '';
