import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/layar.dart';
import '../core/format.dart';
import '../domain/core/core.dart';
import '../widgets/lencana_status.dart' show GayaLabel;
import 'actor.dart';
import 'core_repositories.dart';
import 'home_rows.dart';

/// Home rows of the Inti module's open items (C1, M6), each from real state,
/// so finishing the item removes the row:
///
/// - Penatua Kolom (core.confirm_recovery in the person's Kolom): "Pemulihan
///   akun · {nama}" while a recovery waits for them (P4).
/// - Authorized church officer (core.assign_post): "Serah terima {jabatan}
///   menunggu dicatat" while a handover is proposed (DP39), and "Penugasan
///   {jabatan} menunggu verifikasi wewenang" to know while it waits.
/// - Operator (core.cover_vacancy): "Jabatan {jabatan} kosong" while a post
///   that needs authority (Bendahara, Sekretaris) has no holder and no cover
///   (D18).
List<HomeRow> barisInti(Ref ref, Actor actor) {
  final can = ref.watch(canProvider);
  final hari = ref.watch(hariIniProvider);
  final orang = ref.watch(peopleRepositoryProvider);
  String nama(String id) => orang.person(id)?.name ?? '';
  bool boleh(Capability c, ScopeRef s) => can.can(actor, c, s, at: hari);
  final baris = <HomeRow>[];

  for (final r in ref.watch(recoveryRepositoryProvider).recoveries()) {
    if (r.status == RecoveryStatus.waiting &&
        r.requestedBy != actor.personId &&
        r.personId != actor.personId &&
        boleh(Capability.confirmRecovery, ScopeRef(r.scopeId))) {
      baris.add(
        HomeRow(
          kelompok: KelompokBaris.tindak,
          judul: 'Pemulihan akun · ${nama(r.personId)}',
          sub:
              'Diminta ${nama(r.requestedBy)}, Operator · nomor baru '
              '${samarHp(r.newPhone)}',
          label: 'Menunggu Anda',
          gaya: GayaLabel.garis,
          ke: Layar.cariOrang,
        ),
      );
    }
  }

  for (final p in ref.watch(roleRepositoryProvider).posts()) {
    final lingkup = ScopeRef(p.post.scopeId);
    if (p.handover case final h? when p.pending == null) {
      if (boleh(Capability.assignPost, lingkup)) {
        baris.add(
          HomeRow(
            kelompok: KelompokBaris.tindak,
            judul: 'Serah terima ${p.post.title} menunggu dicatat',
            sub:
                'Dari ${nama(h.fromPersonId)} kepada ${nama(h.toPersonId)} · '
                '${h.documentRef}',
            label: 'Diajukan',
            gaya: GayaLabel.garis,
            ke: Layar.penugasan,
          ),
        );
      }
    }
    if (p.pending case final w? when boleh(Capability.assignPost, lingkup)) {
      baris.add(
        HomeRow(
          kelompok: KelompokBaris.tahu,
          judul: 'Penugasan ${p.post.title} menunggu verifikasi wewenang',
          sub: '${nama(w.personId)} · dicatat ${tgl(w.recordedAt!)}',
          ke: Layar.penugasan,
        ),
      );
    }
    if (p.vacant &&
        p.cover == null &&
        p.pending == null &&
        p.post.role.needsAuthority &&
        boleh(Capability.coverVacancy, ScopeRef.jemaat)) {
      baris.add(
        HomeRow(
          kelompok: KelompokBaris.tindak,
          judul: 'Jabatan ${p.post.title} kosong',
          sub: 'Operator dapat menjalankan jabatan kosong',
          label: 'Jabatan kosong',
          gaya: GayaLabel.draf,
          ke: Layar.jabatanKosong,
        ),
      );
    }
  }
  return baris;
}
