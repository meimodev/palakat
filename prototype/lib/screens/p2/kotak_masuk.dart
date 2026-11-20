import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layar.dart';
import '../../domain/core/core.dart';
import '../../domain/membership/membership.dart';
import '../../providers/actor.dart';
import '../../providers/clock.dart';
import '../../providers/core_repositories.dart';
import '../../providers/jemaat/jemaat.dart';
import '../../providers/layout.dart';
import '../../providers/repositories_jemaat.dart';
import '../../providers/revision.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tekan.dart';

/// The signed-in person's inbox (NotificationRepository), split as the board
/// does: "Perlu tindakan" (types tindak and tempo) and "Untuk diketahui" (the
/// rest). A module that is off leaves no notifications. Shared with
/// WebKotakMasuk.
(List<AppNotification>, List<AppNotification>) kotakMasukDari(WidgetRef ref) {
  ref.watch(revisionProvider);
  final a = ref.watch(actorProvider);
  if (a == null) return (const [], const []);
  final can = ref.watch(canProvider);
  final semua = [
    for (final n in ref.watch(notificationRepositoryProvider).inbox(a.personId))
      if (n.module == null || can.moduleActive(n.module)) n,
  ];
  bool tindak(AppNotification n) =>
      n.type == NotificationType.action || n.type == NotificationType.due;
  return ([...semua.where(tindak)], [...semua.where((n) => !tindak(n))]);
}

/// The row's second line: the module, then the body.
String subKabar(AppNotification n) =>
    n.module == null ? n.body : '${n.module!.label} · ${n.body}';

/// The read-state badge: "Belum dibaca" (`tinta`) or "Dibaca" (`garis`).
LencanaStatus lencanaKabar(AppNotification n) => LencanaStatus(
  n.read ? 'Dibaca' : 'Belum dibaca',
  bentuk: (n.read ? GayaLabel.garis : GayaLabel.tinta).bentuk,
);

/// The screen a notification's record opens, by record kind.
const _tujuan = {
  'post': Layar.jabatanKosong,
  'assignment': Layar.penugasan,
  'delegation': Layar.pelimpahan,
};

/// Opening a row marks it read (`markRead`), then pushes its record's screen
/// when there is one the actor may open here. A refused mark (stale) is
/// left: the next read shows the stored state.
Future<void> bukaKabar(
  BuildContext context,
  WidgetRef ref,
  AppNotification n,
) async {
  final a = ref.read(actorProvider);
  if (a == null) return;
  if (!n.read) {
    await ref
        .read(notificationRepositoryProvider)
        .markRead(
          a,
          n.id,
          expectedRevision: n.revision,
          idempotencyKey: kunciBaru(a.personId, ref.read(clockProvider)),
        );
  }
  if (!context.mounted) return;
  final r = n.ref;
  final (ke, param, pilih) = switch (r?.kind) {
    'letter' => (Layar.surat, const <String, String>{}, null),
    'announcement' => (Layar.pengumuman, const <String, String>{}, null),
    'document' => (Layar.dokumenGereja, const <String, String>{}, null),
    'warta' => (
      ref.read(penjagaProvider(Layar.wartaEdisi)) == null
          ? Layar.wartaEdisi
          : Layar.wartaPdf,
      {'edisi': r!.id},
      null,
    ),
    'membership_item' => _tujuanJemaat(ref, r!.id),
    final k => (_tujuan[k], const <String, String>{}, null),
  };
  if (ke == null) return;
  if (!ke.adaUntuk(ref.read(layoutProvider))) return;
  if (ref.read(penjagaProvider(ke)) != null) return;
  pilih?.call();
  context.dorongKe(ke, param: param);
}

/// A membership item opens its own screen; the selection is set only when
/// the screen is opened.
(Layar?, Map<String, String>, VoidCallback?) _tujuanJemaat(
  WidgetRef ref,
  String id,
) {
  final i = ref.read(verificationRepositoryProvider).item(id);
  return switch (i?.kind) {
    null => (null, const {}, null),
    ItemKind.application => (Layar.permohonanAnggota, {'id': id}, null),
    ItemKind.lifeEvent => (
      Layar.peristiwa,
      const {},
      () => ref.read(peristiwaDipilihProvider.notifier).pilih(id),
    ),
    ItemKind.household => (
      Layar.konfirmasiKeluarga,
      const {},
      () => ref.read(keluargaDipilihProvider.notifier).pilih(i!.householdId),
    ),
    ItemKind.dataChange => (Layar.verifikasi, const {}, null),
  };
}

/// 51 · Pemberitahuan (spec 14-berandajabatan.md, KotakMasuk): the one
/// notification box for all active modules, read from the person's inbox.
class KotakMasukScreen extends ConsumerWidget {
  const KotakMasukScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (tindak, tahu) = kotakMasukDari(ref);
    final ada = tindak.isNotEmpty || tahu.isNotEmpty;

    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Pemberitahuan',
            anakJudul: 'Satu kotak untuk semua modul yang aktif',
            kembaliKe: Layar.beranda,
            labelKembali: 'Kembali ke Beranda',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  // An empty list leaves its heading out.
                  if (tindak.isNotEmpty) ...[
                    const JudulKotak('Perlu tindakan'),
                    for (final n in tindak) _Kartu(n),
                  ],
                  if (tahu.isNotEmpty) ...[
                    const JudulKotak('Untuk diketahui'),
                    for (final n in tahu) _Kartu(n),
                  ],
                  if (!ada) const KotakKosong(),
                  const CatatanKotakMasuk(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Row card: `permukaan`, 1 px `garis`, radius 14, padding 12 16, min height
/// 44 (content box), gap 12; title 600, subtitle 13 `tinta3`, badge, chevron.
class _Kartu extends ConsumerWidget {
  const _Kartu(this.n);

  final AppNotification n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    return Tekan(
      onTap: () => bukaKabar(context, ref, n),
      peran: PeranTekan.tautan,
      radius: 14,
      child: Kartu(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Row(
            spacing: 12,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 2,
                  children: [
                    Text(
                      n.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      subKabar(n),
                      style: TextStyle(fontSize: 13, color: c.tinta3),
                    ),
                  ],
                ),
              ),
              lencanaKabar(n),
              PalakatIkon(Ikon.lanjut, ukuran: 18, warna: c.tinta3),
            ],
          ),
        ),
      ),
    );
  }
}

/// h2 16/700 ("Perlu tindakan", "Untuk diketahui"); shared with WebKotakMasuk.
class JudulKotak extends StatelessWidget {
  const JudulKotak(this.teks, {super.key});
  final String teks;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(
      teks,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    ),
  );
}

/// "Semua sudah selesai": the dashed (draf) box, padding 14 16, gap 6. The
/// title takes the page's body size (16 phone, 15 web).
class KotakKosong extends StatelessWidget {
  const KotakKosong({super.key});

  @override
  Widget build(BuildContext context) => Kartu(
    status: GarisStatus.draf,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        const Text(
          'Tidak ada yang perlu tindakan',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        Text(
          'Pemberitahuan selesai sendiri ketika pekerjaannya selesai.',
          style: TextStyle(fontSize: 14, color: context.warna.tinta2),
        ),
      ],
    ),
  );
}

/// The closing caption, 13 `tinta3`, on every view.
class CatatanKotakMasuk extends StatelessWidget {
  const CatatanKotakMasuk({super.key});

  @override
  Widget build(BuildContext context) => Text(
    'Pemberitahuan bukan persetujuan dan bukan dokumen pendukung. Bila '
    'pemberitahuan dorong gagal terkirim, pekerjaan di aplikasi tetap berjalan.',
    style: TextStyle(fontSize: 13, color: context.warna.tinta3),
  );
}
