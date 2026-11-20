import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/layar.dart';
import '../core/format.dart';
import '../domain/collaboration/collaboration.dart';
import '../domain/core/core.dart';
import '../widgets/lencana_status.dart' show GayaLabel;
import 'actor.dart';
import 'core_repositories.dart';
import 'home_rows.dart';
import 'repositories_kolaborasi.dart';

/// Home rows of the Collaboration module's open items (BerandaJabatan,
/// screens/14), each from real state, so finishing the item removes it:
///
/// - The approver of a fund request: "Permintaan dana {unit}" (Menunggu
///   Anda); the requester: the same row while it waits, "… tidak disetujui"
///   to know after a refusal; the church Bendahara: "N permintaan dana siap
///   dibayar".
/// - The approver of a service: "{ibadah}, {tanggal}" while it is Draf,
///   "Tugaskan penghitung · {ibadah}" while it has no counter, "Jumlah
///   kehadiran {ibadah}" while the count waits to be Ditetapkan.
/// - A counter: "Hitung kehadiran · {ibadah}" while the count is live (to
///   know before the service day).
/// - The authorized church officer: "{Panitia} masih Perencanaan"; the
///   church Bendahara: "Sisa uang {Panitia}" while its destination waits.
List<HomeRow> barisKolaborasi(Ref ref, Actor actor) {
  final can = ref.watch(canProvider);
  final hari = ref.watch(hariIniProvider);
  final org = ref.watch(orgRepositoryProvider);
  final saya = actor.personId;
  bool boleh(Capability c) => can.can(actor, c, ScopeRef.jemaat, at: hari);
  String unit(String scopeId) => org.scope(scopeId)?.name ?? '';

  /// The actor's post giving [c] in exactly [scopeId], or null.
  Grant? persis(Capability c, String scopeId) => can
      .grantsFor(saya, c, ScopeRef(scopeId), at: hari)
      .where((g) => g.scopeId == scopeId && g.kind != GrantKind.member)
      .firstOrNull;
  final baris = <HomeRow>[];

  // ---------- Fund requests ----------
  final permintaan = ref.watch(fundRequestRepositoryProvider).list();
  for (final v in permintaan) {
    final r = v.request;
    if (v.state != FundRequestState.waiting || r.requestedBy == saya) continue;
    final g = persis(Capability.requestsApprove, r.approverScopeId);
    if (g == null) continue;
    baris.add(
      HomeRow(
        kelompok: KelompokBaris.tindak,
        judul: 'Permintaan dana ${unit(r.scopeId)}',
        sub: 'Sebagai ${g.title} · ${rp(r.amount)} · ${r.purpose}',
        label: 'Menunggu Anda',
        gaya: GayaLabel.garis,
        ke: Layar.permintaanDana,
      ),
    );
  }
  for (final v in permintaan) {
    final r = v.request;
    if (r.requestedBy != saya) continue;
    if (v.state == FundRequestState.waiting) {
      baris.add(
        HomeRow(
          kelompok: KelompokBaris.tindak,
          judul: 'Permintaan dana ${unit(r.scopeId)}',
          sub: 'Sebagai ${r.requesterTitle} · menunggu persetujuan',
          label: 'Diajukan',
          gaya: GayaLabel.garis,
          ke: Layar.permintaanDana,
        ),
      );
    } else if (v.state == FundRequestState.refused) {
      baris.add(
        HomeRow(
          kelompok: KelompokBaris.tahu,
          judul: 'Permintaan dana ${unit(r.scopeId)} tidak disetujui',
          sub: 'Alasan: ${r.decision?.reason ?? ''}',
          label: 'Tidak disetujui',
          gaya: GayaLabel.bata,
          ke: Layar.permintaanDana,
        ),
      );
    }
  }
  if (boleh(Capability.financeFinalize)) {
    final bayar = [
      for (final v in permintaan)
        if (v.payable && v.request.requestedBy != saya) v,
    ];
    if (bayar.isNotEmpty) {
      baris.add(
        HomeRow(
          kelompok: KelompokBaris.tindak,
          judul: '${bayar.length} permintaan dana siap dibayar',
          sub: 'Dibukukan sebagai Uang Muka diberikan',
          label: 'Disetujui',
          gaya: GayaLabel.laut,
          ke: Layar.permintaanDana,
        ),
      );
    }
  }

  // ---------- Services and attendance (DL11, DL30) ----------
  final ibadah = ref.watch(serviceRepositoryProvider);
  final hadir = ref.watch(attendanceRepositoryProvider);
  for (final s in ibadah.list()) {
    final c = hadir.count(s.id);
    if (ibadah.approversOf(s.id).contains(saya)) {
      final sebagai =
          persis(Capability.servicesApprove, s.scopeId)?.title ??
          persis(Capability.servicesApprove, ScopeRef.jemaatId)?.title ??
          '';
      if (s.status == ServiceStatus.draft && !(s.date < hari)) {
        baris.add(
          HomeRow(
            kelompok: KelompokBaris.tindak,
            judul: '${s.title}, ${tgl(s.date.awal)}',
            sub: 'Sebagai $sebagai · menunggu persetujuan Anda',
            label: 'Draf',
            gaya: GayaLabel.draf,
            ke: Layar.ibadah,
          ),
        );
      } else if (s.status == ServiceStatus.scheduled &&
          s.approvedBy == saya &&
          c != null &&
          c.posts.isEmpty) {
        baris.add(
          HomeRow(
            kelompok: KelompokBaris.tindak,
            judul: 'Tugaskan penghitung · ${s.title}',
            sub: 'Sebagai $sebagai · ${tgl(s.date.awal)}',
            label: 'Dijadwalkan',
            gaya: GayaLabel.lautg,
            ke: Layar.ibadah,
          ),
        );
      }
      // DL30: whoever approved it finalizes the count.
      if (c?.status == AttendanceStatus.review && s.approvedBy == saya) {
        baris.add(
          HomeRow(
            kelompok: KelompokBaris.tindak,
            judul: 'Jumlah kehadiran ${s.title}',
            sub: 'Sebagai $sebagai · ${c!.counted} orang, belum Ditetapkan',
            label: 'Sudah diperiksa',
            gaya: GayaLabel.lautg,
            ke: Layar.kehadiran,
            param: {'ibadah': s.id},
          ),
        );
      }
    }
    if (c != null && c.status == AttendanceStatus.live) {
      for (final p in c.posts) {
        if (p.personId != saya) continue;
        final nanti = s.date > hari;
        baris.add(
          HomeRow(
            kelompok: nanti ? KelompokBaris.tahu : KelompokBaris.tindak,
            judul: 'Hitung kehadiran · ${s.title}',
            sub: 'Petugas penghitung · ${p.post} · ${tgl(s.date.awal)}',
            label: nanti ? null : 'Sedang dihitung',
            gaya: nanti ? null : GayaLabel.laut,
            ke: Layar.kehadiran,
            param: {'ibadah': s.id},
          ),
        );
      }
    }
  }

  // ---------- Panitia (DL27) ----------
  final panitia = ref.watch(panitiaRepositoryProvider);
  for (final p in panitia.list()) {
    if (p.stage == PanitiaStage.planning && boleh(Capability.panitiaStage)) {
      baris.add(
        HomeRow(
          kelompok: KelompokBaris.tindak,
          judul: '${p.name} masih Perencanaan',
          sub: 'Belum dapat membukukan sampai diaktifkan',
          label: PanitiaStage.planning.label,
          gaya: GayaLabel.draf,
          ke: Layar.panitia,
        ),
      );
    }
    if (p.stage == PanitiaStage.financialClosing &&
        !p.leftoverApproved &&
        boleh(Capability.panitiaApproveLeftover)) {
      baris.add(
        HomeRow(
          kelompok: KelompokBaris.tindak,
          judul: 'Sisa uang ${p.name}',
          sub:
              'Penutupan keuangan · ${rp(panitia.money(p.id).leftover)} '
              'menunggu tujuan',
          label: PanitiaStage.financialClosing.label,
          gaya: GayaLabel.draf,
          ke: Layar.panitia,
        ),
      );
    }
  }
  return baris;
}
