import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../../providers/core_repositories.dart';
import '../../providers/keuangan/pengaturan.dart';
import '../../providers/repositories_keuangan.dart';
import '../../widgets/penolakan.dart';
import '../../motion/kerangka.dart';
import '../../motion/urutan.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lembar_bawah.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';

// ---------- Board state: the open tab, the sheet, a refusal ----------

const _tabs = [
  (MasterKind.belanja, 'Belanja'),
  (MasterKind.pendapatan, 'Pendapatan'),
];

class _Keadaan extends ChangeNotifier {
  MasterKind tab = MasterKind.belanja;
  bool sheet = false;
  Refusal? tolak;

  void ubah(VoidCallback f) {
    f();
    notifyListeners();
  }
}

/// Runs [perintah] on every tree of the proposed release that [perlu]
/// selects; the first refusal stops it.
Future<Refusal?> perintahRilis(
  WidgetRef ref,
  bool Function(MasterVersion v) perlu,
  Future<Result<MasterVersion>> Function(Actor a, MasterVersion v, String kunci)
  perintah,
) async {
  final usulan = ref.read(versiMataAnggaranProvider).usulan;
  for (final v in usulan?.versi.values ?? const <MasterVersion>[]) {
    if (!perlu(v)) continue;
    final r = await jalankanPengaturan(ref, (a, k) => perintah(a, v, k));
    if (r != null) return r;
  }
  return null;
}

/// "Tandai sudah diperiksa" on both trees.
Future<Refusal?> periksaRilis(WidgetRef ref) => perintahRilis(
  ref,
  (v) => v.status == MasterVersionStatus.draft,
  (a, v, k) => ref
      .read(masterRepositoryProvider)
      .review(a, v.id, expectedRevision: v.revision, idempotencyKey: k),
);

/// "Terbitkan" both trees from their proposed month.
Future<Refusal?> terbitkanRilis(WidgetRef ref) => perintahRilis(
  ref,
  (v) => v.status == MasterVersionStatus.reviewed,
  (a, v, k) => ref
      .read(masterRepositoryProvider)
      .publish(
        a,
        v.id,
        v.effectiveFrom!,
        expectedRevision: v.revision,
        idempotencyKey: k,
      ),
);

/// A "Boleh untuk" chip: the same choice again clears it.
Future<Refusal?> pilihBoleh(
  WidgetRef ref,
  MasterKind kind,
  MasterRow r,
  AllowedEffect e,
) {
  final v = ref.read(versiMataAnggaranProvider).usulan?.versi[kind];
  if (v == null) return Future.value(null);
  return jalankanPengaturan(
    ref,
    (a, k) => ref
        .read(masterRepositoryProvider)
        .setAllowedEffect(
          a,
          v.id,
          r.code,
          r.allowedEffect == e ? AllowedEffect.unset : e,
          expectedRevision: v.revision,
          idempotencyKey: k,
        ),
  );
}

/// "Berlaku mulai {bulan} · diterbitkan oleh {nama}, dd/mm/yyyy" or
/// "Belum berlaku · usulan berlaku mulai {bulan}".
String teksUsulan(WidgetRef ref, RilisMataAnggaran r) {
  final mulai = bulanDari(r.berlaku!);
  if (!r.terbit) return 'Belum berlaku · usulan berlaku mulai $mulai';
  final v = r.versi.values.first;
  final nama = ref.read(peopleRepositoryProvider).person(v.publishedBy ?? '');
  return 'Berlaku mulai $mulai · diterbitkan oleh ${nama?.name ?? ''}, '
      '${tgl(v.publishedAt!)}';
}

/// "Pendapatan {n} baris · Belanja {n} baris".
String teksJumlahBaris(WidgetRef ref, RilisMataAnggaran r) {
  final m = ref.read(masterRepositoryProvider);
  return [
    for (final (k, nama) in _tabs.reversed)
      if (r.versi[k] case final v?) '$nama ${m.rows(v.id).length} baris',
  ].join(' · ');
}

class _Lingkup extends InheritedNotifier<_Keadaan> {
  const _Lingkup({required _Keadaan super.notifier, required super.child});
  static _Keadaan of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_Lingkup>()!.notifier!;
  static _Keadaan baca(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_Lingkup>()!.notifier!;
}

/// Owns the board state and the phone root (strip, Terbitkan sheet) above
/// `/MataAnggaran` and `/MataAnggaran/rinci`.
class MataAnggaranKendali extends StatefulWidget {
  const MataAnggaranKendali({super.key, required this.child});
  final Widget child;
  @override
  State<MataAnggaranKendali> createState() => _MataAnggaranKendaliState();
}

class _MataAnggaranKendaliState extends State<MataAnggaranKendali> {
  final _k = _Keadaan();

  @override
  void dispose() {
    _k.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _Lingkup(
    notifier: _k,
    child: Material(
      type: MaterialType.transparency,
      child: ListenableBuilder(
        listenable: _k,
        builder: (context, _) => LayarPonsel(
          layarKeuangan: true,
          overlay: [if (_k.sheet) _LembarTerbit(k: _k)],
          child: widget.child,
        ),
      ),
    ),
  );
}

class MataAnggaranScreen extends StatelessWidget {
  const MataAnggaranScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.warna.kertas,
    child: anak == 'rinci' ? const _Rinci() : const _Versi(),
  );
}

/// The proposed version's status badge (header and card).
Widget _lencana(MasterVersionStatus st) => switch (st) {
  MasterVersionStatus.draft => LencanaStatus.uang(StatusUang.draf),
  MasterVersionStatus.reviewed => LencanaStatus.uang(StatusUang.sudahDiperiksa),
  MasterVersionStatus.published => const LencanaStatus(
    'Diterbitkan',
    bentuk: BentukLencana.tinta,
  ),
};

// ---------- Versi ----------

class _Versi extends ConsumerWidget {
  const _Versi();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    final v = ref.watch(versiMataAnggaranProvider);
    final usulan = v.usulan, kini = v.kini;
    const judul = TextStyle(fontSize: 18, fontWeight: FontWeight.w700);

    // The whole view fades in (`pudar` on the board's view container).
    return Gerak(
      Kerangka.pudar,
      lama: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Versi Mata Anggaran',
            kembaliKe: Layar.pengaturan,
            labelKembali: 'Kembali ke Lainnya',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: [
                  Text(
                    'Versi yang diterbitkan tidak pernah berubah. Perubahan '
                    'menjadi versi baru yang berlaku mulai bulan berikutnya.',
                    style: TextStyle(fontSize: 14, color: c.tinta2),
                  ),
                  if (usulan != null)
                    Tekan(
                      onTap: () =>
                          context.dorongKe(Layar.mataAnggaran, anak: 'rinci'),
                      radius: 16,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Kartu(
                              status: usulan.status == MasterVersionStatus.draft
                                  ? GarisStatus.draf
                                  : GarisStatus.terpilih,
                              radius: 16,
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                spacing: 4,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    spacing: 8,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'Versi ${usulan.kode}',
                                          style: judul,
                                        ),
                                      ),
                                      _lencana(usulan.status),
                                    ],
                                  ),
                                  Text(
                                    teksUsulan(ref, usulan),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: c.tinta2,
                                    ),
                                  ),
                                  Text(
                                    bedaUsulan(
                                      ref.watch(masterRepositoryProvider),
                                      v,
                                    ),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: c.tinta3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (usulan.terbit) const SapuTinta(),
                          ],
                        ),
                      ),
                    ),
                  if (kini != null)
                    Kartu(
                      status: GarisStatus.terpilih,
                      radius: 16,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 4,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            spacing: 8,
                            children: [
                              Flexible(
                                child: Text('Versi ${kini.kode}', style: judul),
                              ),
                              const LencanaStatus(
                                'Diterbitkan',
                                bentuk: BentukLencana.tinta,
                                kepala: true,
                              ),
                            ],
                          ),
                          Text(
                            'Berlaku mulai ${bulanDari(kini.berlaku!)} · '
                            '${usulan?.terbit ?? false ? 'dipakai sampai ${bulanDari(usulan!.berlaku!.tambahHari(-1))}' : 'versi yang sedang dipakai'}',
                            style: TextStyle(fontSize: 14, color: c.tinta2),
                          ),
                          Text(
                            teksJumlahBaris(ref, kini),
                            style: TextStyle(fontSize: 13, color: c.tinta3),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Rinci ----------

class _Rinci extends ConsumerWidget {
  const _Rinci();

  /// `keVersi`: pop to `/mata-anggaran` (closes the sheet too).
  static void _keVersi(BuildContext context) {
    final k = _Lingkup.baca(context);
    k.ubah(() => k.sheet = false);
    context.naikKe(Layar.mataAnggaran);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    final k = _Lingkup.of(context);
    final v = ref.watch(versiMataAnggaranProvider);
    final usulan = v.usulan;
    if (usulan == null) return const SizedBox.shrink();
    final st = usulan.status;
    final terbit = usulan.terbit;
    final master = ref.watch(masterRepositoryProvider);
    final rows = barisUsulan(master, v, k.tab);
    final kosongN =
        [for (final t in MasterKind.values) ...barisUsulan(master, v, t)]
            .where(
              (b) =>
                  b.baris.postable &&
                  b.baris.allowedEffect == AllowedEffect.unset,
            )
            .length;
    final kakiTeks = terbit
        ? 'Diterbitkan. Versi ini tidak dapat diubah lagi.'
        : st == MasterVersionStatus.reviewed
        ? 'Sudah diperiksa. Mengubah isi mengembalikan versi ini ke Draf.'
        : kosongN > 0
        ? '$kosongN baris belum punya “Boleh untuk”. Boleh dibiarkan kosong; '
              'baris itu tidak dapat menerima titipan.'
        : 'Semua baris sudah punya “Boleh untuk”.';
    final garisAtas = BoxDecoration(
      border: Border(top: BorderSide(color: c.garis)),
    );
    Future<void> lakukan(Future<Refusal?> f) async {
      final r = await f;
      k.ubah(() => k.tolak = r);
    }

    return PopScope(
      // An open sheet takes system Back first (navigation.md 5.1).
      canPop: !k.sheet,
      onPopInvokedWithResult: (sudah, _) {
        if (!sudah) k.ubah(() => k.sheet = false);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KepalaPonsel(
            judul: 'Versi ${usulan.kode}',
            onKembali: () => _keVersi(context),
            ujung: _lencana(st),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Wrap(
              spacing: 8,
              children: [
                for (final (t, nama) in _tabs)
                  ChipSatu(
                    teks: nama,
                    dipilih: k.tab == t,
                    padding: 16,
                    onTap: () => k.ubah(() => k.tab = t),
                  ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final r in rows)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: garisAtas,
                      child: _baris(
                        context,
                        k,
                        r,
                        terbit,
                        (e) => lakukan(pilihBoleh(ref, k.tab, r.baris, e)),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.only(top: 12),
                    decoration: garisAtas,
                    child: Text(
                      '${rows.length} baris. '
                      '“Boleh untuk” diisi atas keputusan Pimpinan Jemaat yang '
                      'berwenang. Baris yang dibiarkan kosong tidak dapat '
                      'menerima titipan.',
                      style: TextStyle(fontSize: 13, color: c.tinta3),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
            decoration: BoxDecoration(
              color: c.permukaan,
              border: Border(top: BorderSide(color: c.garis)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                if (k.tolak != null)
                  Penolakan(
                    tindakan: k.tolak!.action,
                    sebab: k.tolak!.because,
                    jalan: const [],
                  ),
                Text(kakiTeks, style: TextStyle(fontSize: 14, color: c.tinta2)),
                if (st == MasterVersionStatus.draft)
                  Tombol(
                    'Tandai sudah diperiksa',
                    jenis: JenisTombol.kedua,
                    onPressed: () => lakukan(periksaRilis(ref)),
                  ),
                if (st == MasterVersionStatus.reviewed)
                  Gerak(
                    Kerangka.muncul,
                    lama: const Duration(milliseconds: 300),
                    child: Tombol(
                      'Terbitkan',
                      onPressed: () => k.ubah(() => k.sheet = true),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _baris(
    BuildContext context,
    _Keadaan k,
    BarisUsulan b,
    bool kunci,
    ValueChanged<AllowedEffect> pilih,
  ) {
    final c = context.warna;
    final r = b.baris;
    final grup = !r.postable;
    final cur = labelBoleh(r.allowedEffect);
    final nama = _tabs.firstWhere((t) => t.$1 == k.tab).$2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          spacing: 8,
          children: [
            Flexible(
              child: Text(
                '$nama ${r.code}',
                style: TextStyle(
                  fontFamily: PalakatText.mono,
                  fontSize: 13,
                  color: c.tinta2,
                ),
              ),
            ),
            if (b.tanda != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                decoration: ShapeDecoration(
                  shape: GarisBorder.penuh(c.laut, radius: 6),
                ),
                child: Text(
                  b.tanda!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: c.laut,
                  ),
                ),
              ),
          ],
        ),
        Text(
          r.name,
          style: TextStyle(
            fontSize: 15,
            fontWeight: grup ? FontWeight.w700 : FontWeight.w600,
            color: grup ? c.tinta2 : c.tinta,
          ),
        ),
        if (grup)
          Text(
            'Judul kelompok, tidak dapat dibukukan',
            style: TextStyle(fontSize: 13, color: c.tinta3),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Text.rich(
                  TextSpan(
                    text: 'Dapat dibukukan · Boleh untuk: ',
                    children: [
                      TextSpan(
                        text: cur.isEmpty ? 'belum diisi' : cur,
                        style: TextStyle(
                          color: cur.isEmpty ? c.bata : c.tinta,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  style: TextStyle(fontSize: 13, color: c.tinta2),
                ),
                Wrap(
                  spacing: 6,
                  children: [
                    for (final o in AllowedEffect.values)
                      if (o != AllowedEffect.unset)
                        _ChipBoleh(
                          teks: labelBoleh(o),
                          dipilih: r.allowedEffect == o,
                          onTap: kunci ? null : () => pilih(o),
                        ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// "Boleh untuk" chip: min height 44, padding 0 12, radius 10, 1.5 line,
/// 13/600; colours as [ChipSatu]. Null [onTap] once published (`disabled`).
class _ChipBoleh extends StatelessWidget {
  const _ChipBoleh({
    required this.teks,
    required this.dipilih,
    required this.onTap,
  });
  final String teks;
  final bool dipilih;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tekan(
      onTap: onTap,
      dipilih: dipilih,
      radius: 10,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: ShapeDecoration(
          color: dipilih ? c.tinta : c.permukaan,
          shape: GarisBorder.penuh(
            dipilih ? c.tinta : c.garisTegas,
            radius: 10,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              teks,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: dipilih ? c.permukaan : c.tinta,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Terbitkan sheet ----------

class _LembarTerbit extends ConsumerWidget {
  const _LembarTerbit({required this.k});
  final _Keadaan k;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    final v = ref.watch(versiMataAnggaranProvider);
    final usulan = v.usulan;
    if (usulan == null) return const SizedBox.shrink();
    final mulai = bulanDari(usulan.berlaku!);
    final sampai = bulanDari(usulan.berlaku!.tambahHari(-1));
    void tutup() => k.ubah(() => k.sheet = false);
    return LembarBawah(
      judul: 'Terbitkan versi ${usulan.kode}?',
      ukuranJudul: 20,
      labelTirai: 'Kembali ke versi ${usulan.kode}',
      onTutup: tutup,
      isi: [
        Kartu(
          status: GarisStatus.ditutup,
          child: Text.rich(
            const TextSpan(
              children: [
                TextSpan(
                  text: 'Versi yang diterbitkan tidak dapat diubah.',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text:
                      ' Perubahan berikutnya harus menjadi versi baru, berlaku '
                      'mulai bulan yang lebih kemudian.',
                ),
              ],
            ),
            style: TextStyle(fontSize: 14, color: c.permukaan),
          ),
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Berlaku mulai $mulai.',
                style: TextStyle(fontWeight: FontWeight.w700, color: c.tinta),
              ),
              TextSpan(
                text:
                    ' Transaksi sampai $sampai tetap memakai versi '
                    '${v.kini?.kode ?? ''} dan tidak berubah.',
              ),
            ],
          ),
          style: TextStyle(fontSize: 14, color: c.tinta2),
        ),
        Builder(
          builder: (ctx) => Tombol(
            'Terbitkan, berlaku mulai $mulai',
            onPressed: () async {
              final router = GoRouter.of(ctx);
              final r = await terbitkanRilis(ref);
              k.ubah(() {
                k.tolak = r;
                k.sheet = false;
              });
              // `terbitkan` also switches the board to the Versi view.
              if (r == null) kembaliKeDengan(router, Layar.mataAnggaran.jalur);
            },
          ),
        ),
        Tombol(
          'Kembali',
          jenis: JenisTombol.teks,
          warnaTeks: c.tinta,
          onPressed: tutup,
        ),
      ],
    );
  }
}
