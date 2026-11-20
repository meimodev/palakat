import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/layar.dart';
import '../core/format.dart';
import '../domain/core/core.dart';
import '../domain/membership/membership.dart';
import '../widgets/lencana_status.dart' show GayaLabel;
import 'actor.dart';
import 'home_rows.dart';
import 'jemaat/jemaat.dart';
import 'repositories_jemaat.dart';

/// Home rows of the Jemaat module's open items (BerandaJabatan, mock-data
/// 2.16), each from real state, so finishing the item removes the row:
///
/// - a verifier: "N data menunggu verifikasi" (the queue routed to them;
///   "N data {Kolom} menunggu verifikasi" while covering a vacant post);
/// - a Penatua Kolom: "N anggota {Kolom} belum dikonfirmasi" (to know);
/// - the Operator: a paper book not yet imported, open possible duplicates,
///   and "Buku anggota: N baris sudah diimpor" (to know);
/// - a member: their family's life event returned, or waiting.
List<HomeRow> barisJemaat(Ref ref, Actor actor) {
  final can = ref.watch(canProvider);
  final hari = ref.watch(hariIniProvider);
  final nama = ref.watch(namaJemaatProvider);
  final anggota = ref.watch(memberRepositoryProvider);
  final baris = <HomeRow>[];
  List<Grant> hak(Capability c) =>
      can.grantsFor(actor.personId, c, ScopeRef.anywhere, at: hari);

  // Verifier: whoever the queue routes items to (a Syamas or Operator too,
  // for what nobody else may verify) and who may open it.
  final verif = hak(Capability.membershipVerify)
      .where((g) => g.scopeId != ScopeRef.jemaatId)
      .toList();
  {
    final antre = [
      for (final e in ref.watch(verificationRepositoryProvider).queue(actor))
        if (e.blocked == null) e.item,
    ];
    if (antre.isNotEmpty) {
      int n(ItemKind k) => antre.where((i) => i.kind == k).length;
      final rincian = [
        if (n(ItemKind.application) > 0)
          '${n(ItemKind.application)} permohonan',
        if (n(ItemKind.household) > 0)
          '${n(ItemKind.household)} konfirmasi keluarga',
        if (n(ItemKind.lifeEvent) > 0) '${n(ItemKind.lifeEvent)} peristiwa',
        if (n(ItemKind.dataChange) > 0)
          '${n(ItemKind.dataChange)} perubahan data',
      ];
      final g =
          verif.firstOrNull ??
          can
              .grantsOf(actor.personId, at: hari)
              .where((x) => x.kind == GrantKind.assignment)
              .firstOrNull;
      // A vacancy cover opens the post's own screen (BerandaJabatan,
      // WebBerandaJabatan), which holds its queue on both layouts.
      final kosong = g?.kind == GrantKind.cover;
      final ke = kosong ? Layar.jabatanKosong : Layar.verifikasi;
      if (ref.watch(penjagaProvider(ke)) == null) {
        final sejak = kosong
            ? ref.watch(jalanJabatanProvider(g!.postId!)).sejak
            : null;
        baris.add(
          HomeRow(
            kelompok: KelompokBaris.tindak,
            judul: kosong
                ? '${antre.length} data ${nama.kolom(g!.scopeId)} menunggu '
                      'verifikasi'
                : '${antre.length} data menunggu verifikasi',
            sub: kosong
                ? [
                    'Menjalankan jabatan kosong ${g!.title}',
                    ?(sejak == null ? null : 'sejak ${tgl(sejak)}'),
                  ].join(' ')
                : [
                    ?(g == null ? null : 'Sebagai ${g.title}'),
                    ...rincian,
                  ].join(' · '),
            label: kosong ? 'Jabatan kosong' : 'Diajukan',
            gaya: kosong ? GayaLabel.bata : GayaLabel.garis,
            ke: ke,
          ),
        );
      }
    }
  }

  // Penatua Kolom: their Kolom's unconfirmed members.
  for (final g in hak(Capability.membershipConfirmHousehold)) {
    if (g.kind != GrantKind.assignment || g.scopeId == ScopeRef.jemaatId) {
      continue;
    }
    final u = anggota.counts(kolom: g.scopeId).unconfirmed;
    if (u == 0) continue;
    baris.add(
      HomeRow(
        kelompok: KelompokBaris.tahu,
        judul: '$u anggota ${nama.kolom(g.scopeId)} belum dikonfirmasi',
        sub: 'Sebagai ${g.title} · dari buku anggota',
        ke: Layar.konfirmasiKeluarga,
      ),
    );
  }

  // Operator: the paper books.
  if (can.can(actor, Capability.membershipImport, ScopeRef.jemaat, at: hari)) {
    final impor = ref.watch(memberImportRepositoryProvider);
    for (final b in impor.batches()) {
      if (b.status == ImportStatus.imported) continue;
      baris.add(
        HomeRow(
          kelompok: KelompokBaris.tindak,
          judul: '${b.source} belum diimpor',
          sub: '${b.rows.length} baris · ${b.status.label}',
          label: b.status.label,
          gaya: GayaLabel.draf,
          ke: Layar.imporBuku,
        ),
      );
    }
    final ganda = impor
        .duplicates()
        .where((d) => d.status == DuplicateStatus.open)
        .length;
    if (ganda > 0) {
      baris.add(
        HomeRow(
          kelompok: KelompokBaris.tindak,
          judul: '$ganda kemungkinan data ganda',
          sub: 'Bandingkan dulu; tidak pernah digabung sendiri',
          label: 'Perlu diputuskan',
          gaya: GayaLabel.bata,
          ke: Layar.dataGanda,
        ),
      );
    }
    final diimpor = impor
        .batches()
        .where((b) => b.status == ImportStatus.imported)
        .fold(0, (s, b) => s + b.rows.length);
    if (diimpor > 0) {
      baris.add(
        HomeRow(
          kelompok: KelompokBaris.tahu,
          judul: 'Buku anggota: $diimpor baris sudah diimpor',
          sub: '${anggota.counts().unconfirmed} belum dikonfirmasi',
          ke: Layar.imporBuku,
        ),
      );
    }
  }

  // A member: their family's life events.
  for (final i
      in ref.watch(applicationRepositoryProvider).submittedBy(actor.personId)) {
    if (i.kind != ItemKind.lifeEvent || i.replacedBy != null) continue;
    final judul = '${i.event!.kind.label} · ${nama.subjek(i)}';
    if (i.status == ItemStatus.returned) {
      baris.add(
        HomeRow(
          kelompok: KelompokBaris.tindak,
          judul: '$judul dikembalikan',
          sub: 'Alasan: ${i.reason}',
          label: 'Dikembalikan',
          gaya: GayaLabel.bata,
          ke: Layar.peristiwa,
        ),
      );
    } else if (i.open && i.submittedBy == actor.personId) {
      baris.add(
        HomeRow(
          kelompok: KelompokBaris.tahu,
          judul: judul,
          sub:
              'Diajukan ${tgl(i.submittedAt)} · menunggu Penatua '
              '${nama.kolom(i.scopeId)}',
          label: 'Diajukan',
          gaya: GayaLabel.garis,
          ke: Layar.peristiwa,
        ),
      );
    }
  }
  return baris;
}
