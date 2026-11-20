import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/layar.dart';
import '../core/format.dart';
import '../domain/core/core.dart';
import '../domain/secretariat/secretariat.dart';
import '../widgets/lencana_status.dart' show GayaLabel;
import 'actor.dart';
import 'home_rows.dart';
import 'repositories_sekretariat.dart';

/// Home rows of the Secretariat's open items (BerandaJabatan, mock-data 2.3
/// and screens/14), each from real state, so finishing the item removes it:
///
/// - Sekretaris Jemaat: "N permohonan surat", "N pengumuman masih Draf",
///   "Warta Jemaat edisi {Minggu depan}" until it is published; to know:
///   "N pengumuman berakhir pada {tanggal}".
/// - Operator: "N permohonan surat dicatat di kantor" (hers, still open).
/// - Anggota jemaat (acting as a member): their own open letter requests;
///   to know: the latest Warta edition and "N pengumuman untuk {Kolom}".
List<HomeRow> barisSekretariat(Ref ref, Actor actor) {
  final can = ref.watch(canProvider);
  final hari = ref.watch(hariIniProvider);
  bool boleh(Capability c) => can.can(actor, c, ScopeRef.jemaat, at: hari);
  final surat = ref.watch(letterRepositoryProvider).requests();
  final umum = ref.watch(announcementRepositoryProvider);
  final warta = ref.watch(wartaRepositoryProvider).editions();
  final baris = <HomeRow>[];
  final terbuka = [
    for (final r in surat)
      if (r.status == LetterStatus.requested) r,
  ];

  if (boleh(Capability.documentsIssueLetter) && terbuka.isNotEmpty) {
    baris.add(
      HomeRow(
        kelompok: KelompokBaris.tindak,
        judul: '${terbuka.length} permohonan surat',
        sub: 'Diajukan anggota dan dicatat Operator',
        label: 'Diajukan',
        gaya: GayaLabel.garis,
        ke: Layar.surat,
      ),
    );
  }
  if (boleh(Capability.announcementsPublish)) {
    final draf = [
      for (final a in umum.list())
        if (a.status == AnnouncementStatus.draft) a,
    ];
    if (draf.isNotEmpty) {
      baris.add(
        HomeRow(
          kelompok: KelompokBaris.tindak,
          judul: '${draf.length} pengumuman masih Draf',
          sub: 'Belum diterbitkan',
          label: 'Draf',
          gaya: GayaLabel.draf,
          ke: Layar.pengumuman,
        ),
      );
    }
  }
  if (boleh(Capability.wartaEdit)) {
    final minggu = mingguDepan(hari);
    final e = warta.where((x) => x.sunday == minggu).firstOrNull;
    if (e == null ||
        e.status != WartaStatus.published && e.status != WartaStatus.retired) {
      baris.add(
        HomeRow(
          kelompok: KelompokBaris.tindak,
          judul: 'Warta Jemaat edisi ${tgl(minggu.awal)}',
          sub: e == null ? 'Belum disusun' : 'Belum diterbitkan',
          label: e?.status.label ?? 'Belum disusun',
          gaya: GayaLabel.draf,
          ke: e == null ? Layar.warta : Layar.wartaEdisi,
          param: e == null ? const {} : {'edisi': e.id},
        ),
      );
    }
  }
  if (boleh(Capability.announcementsPublish)) {
    final akhir = [
      for (final a in umum.list())
        if (a.statusAt(hari) == AnnouncementStatus.published &&
            a.endsOn != null)
          a.endsOn!,
    ]..sort();
    if (akhir.isNotEmpty) {
      final n = akhir.where((t) => t == akhir.first).length;
      baris.add(
        HomeRow(
          kelompok: KelompokBaris.tahu,
          judul: '$n pengumuman berakhir pada ${tgl(akhir.first.awal)}',
          sub: 'Setelah itu diarsipkan sendiri',
          ke: Layar.pengumuman,
        ),
      );
    }
  }
  if (boleh(Capability.documentsRecordRequest) &&
      !boleh(Capability.documentsIssueLetter)) {
    final kantor = [
      for (final r in terbuka)
        if (r.atOffice && r.requestedBy == actor.personId) r,
    ];
    if (kantor.isNotEmpty) {
      baris.add(
        HomeRow(
          kelompok: KelompokBaris.tindak,
          judul: '${kantor.length} permohonan surat dicatat di kantor',
          sub: 'Sebagai Operator · menunggu Sekretaris Jemaat',
          label: 'Diajukan',
          gaya: GayaLabel.garis,
          ke: Layar.surat,
        ),
      );
    }
  }
  // A member's own items: only while acting as a member (no post).
  if (actor.assignmentId == null) {
    for (final r in terbuka) {
      if (r.forPersonId == actor.personId || r.requestedBy == actor.personId) {
        baris.add(
          HomeRow(
            kelompok: KelompokBaris.tindak,
            judul: 'Permohonan ${r.type.label.toLowerCase()}',
            sub: 'Diajukan ${tgl(r.requestedAt)}',
            label: 'Diajukan',
            gaya: GayaLabel.garis,
            ke: Layar.surat,
          ),
        );
      }
    }
    final terakhir = warta
        .where((e) => e.status == WartaStatus.published)
        .firstOrNull;
    if (terakhir != null) {
      baris.add(
        HomeRow(
          kelompok: KelompokBaris.tahu,
          judul: 'Warta Jemaat edisi ${tgl(terakhir.sunday.awal)}',
          sub: 'Diterbitkan untuk semua anggota',
          label: 'Diterbitkan',
          gaya: GayaLabel.tinta,
          ke: Layar.warta,
        ),
      );
    }
    final untukSaya = [
      for (final a in umum.list(audienceOf: actor.personId))
        if (a.statusAt(hari) == AnnouncementStatus.published) a,
    ];
    if (untukSaya.isNotEmpty) {
      // As a member of their Kolom, every announcement that reaches them.
      final kolom = umum.kolomOf(actor.personId) ?? 'Anda';
      baris.add(
        HomeRow(
          kelompok: KelompokBaris.tahu,
          judul: '${untukSaya.length} pengumuman untuk $kolom',
          sub: 'Ditujukan untuk: $kolom',
          ke: Layar.pengumuman,
        ),
      );
    }
  }
  return baris;
}
