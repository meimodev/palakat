import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/layar.dart';
import '../core/format.dart';
import '../domain/core/core.dart';
import '../domain/finance/finance.dart';
import '../widgets/lencana_status.dart' show GayaLabel;
import 'actor.dart';
import 'core_repositories.dart';
import 'home_rows.dart';
import 'keuangan/akhir_bulan.dart';
import 'keuangan/beranda.dart';
import 'keuangan/pemeriksa.dart';
import 'repositories_keuangan.dart';

/// Home rows of the Keuangan module's open items (BerandaJabatan, mock-data
/// 2.3 and screens/14): only for a persona who may act on them, each row
/// drawn from real state, so finishing the item removes the row.
///
/// - Bendahara (finance.finalize): "Keuangan: N hal perlu tindakan", "N draf
///   belum dibukukan", "N hambatan dari unit", and "N uang muka dengan sisa
///   belum dipertanggungjawabkan" (to know).
/// - Pemeriksa kedua (finance.review without finalize): "N draf menunggu
///   pemeriksaan" and "Rekonsiliasi {akun} menunggu pemeriksaan".
/// - Unit treasurer: "N draf {unit} belum dibukukan".
/// - Scoped preparer (DP37): "Kesiapan peruntukan {Fund} · {bulan}" while
///   missing or out of date for the next month to close.
List<HomeRow> barisKeuangan(Ref ref, Actor actor) {
  final can = ref.watch(canProvider);
  final hari = ref.watch(hariIniProvider);
  bool boleh(Capability c, [ScopeRef s = ScopeRef.jemaat]) =>
      can.can(actor, c, s, at: hari);
  final baris = <HomeRow>[];

  if (boleh(Capability.financeFinalize)) {
    final b = ref.watch(berandaKeuanganProvider);
    final berikut = b.bulan.berikutDitutup;
    final n = b.perluTindakan.length;
    if (n > 0) {
      baris.add(
        HomeRow(
          kelompok: KelompokBaris.tindak,
          judul: 'Keuangan: $n hal perlu tindakan',
          sub: [
            'Saldo buku ${rp(b.saldoBuku)}',
            if (b.bulan.adaBulanLaluTerbuka)
              '${namaBulan(berikut!)} belum ditutup',
          ].join(' · '),
          ke: Layar.keuangan,
        ),
      );
    }
    if (b.drafJumlah > 0) {
      baris.add(
        HomeRow(
          kelompok: KelompokBaris.tindak,
          judul: '${b.drafJumlah} draf belum dibukukan',
          sub: 'Belum masuk saldo · ${rp(b.drafRp)}',
          label: 'Draf',
          gaya: GayaLabel.draf,
          ke: Layar.transaksi,
        ),
      );
    }
    final dariUnit = [
      for (final h in b.hambatan)
        if (h.unitScopeId != null) h,
    ];
    if (dariUnit.isNotEmpty) {
      final org = ref.watch(orgRepositoryProvider);
      final unit = {
        for (final h in dariUnit) org.scope(h.unitScopeId!)?.name ?? '',
      }.join(', ');
      baris.add(
        HomeRow(
          kelompok: KelompokBaris.tindak,
          judul: '${dariUnit.length} hambatan dari unit',
          sub: '$unit · menghalangi tutup buku ${namaBulan(berikut!)}',
          label: 'Hambatan',
          gaya: GayaLabel.bata,
          ke: Layar.hambatanUnit,
        ),
      );
    }
    for (final t in b.untukDiketahui) {
      baris.add(
        HomeRow(
          kelompok: KelompokBaris.tahu,
          judul: t.judul,
          sub: 'Tidak menghalangi tutup buku',
          ke: t.ke,
        ),
      );
    }
  } else if (boleh(Capability.financeReview)) {
    final m = ref.watch(menungguPemeriksaanProvider);
    if (m.isNotEmpty) {
      baris.add(
        HomeRow(
          kelompok: KelompokBaris.tindak,
          judul: '${m.length} draf menunggu pemeriksaan',
          sub: 'Sebagai Pemeriksa kedua · belum masuk saldo',
          label: 'Draf',
          gaya: GayaLabel.draf,
          ke: Layar.pemeriksa,
        ),
      );
    }
    // A bank reconciliation ready for their check (D24, OPEN → REVIEWED).
    final akunId = ref.watch(akunRekeningKoranProvider);
    final r = akunId == null ? null : ref.watch(rekonAkunProvider(akunId));
    if (r != null) {
      baris.add(
        HomeRow(
          kelompok: KelompokBaris.tindak,
          judul: 'Rekonsiliasi ${r.akun.name} menunggu pemeriksaan',
          sub: 'Sebagai Pemeriksa kedua · ${namaBulan(r.periode)}',
          label: 'Hambatan',
          gaya: GayaLabel.bata,
          ke: Layar.rekeningKoran,
        ),
      );
    }
  }

  // A unit treasurer's own drafts (KeuanganUnit; WebAlurUnit on the web).
  final unit = can
      .grantsFor(
        actor.personId,
        Capability.unitFinanceRecord,
        ScopeRef.anywhere,
        at: hari,
      )
      .map((g) => g.scopeId)
      .toSet();
  if (unit.isNotEmpty) {
    final tx = ref.watch(transactionRepositoryProvider);
    final org = ref.watch(orgRepositoryProvider);
    for (final s in unit) {
      final d = [
        for (final t in tx.drafts())
          if (t.unitScopeId == s) t,
      ];
      if (d.isEmpty) continue;
      baris.add(
        HomeRow(
          kelompok: KelompokBaris.tindak,
          judul: '${d.length} draf ${org.scope(s)?.name ?? s} belum dibukukan',
          sub: 'Belum masuk saldo · ${rp(d.fold(0, (n, t) => n + t.total))}',
          label: 'Draf',
          gaya: GayaLabel.draf,
          ke: Layar.keuanganUnit,
        ),
      );
    }
  }

  // Readiness of the Funds this person prepares (RD12, DP37).
  final berikut = ref.watch(bulanBukuProvider).berikutDitutup;
  if (berikut != null) {
    final dana = ref.watch(fundRepositoryProvider);
    for (final v
        in ref.watch(periodRepositoryProvider).attestations(berikut.id)) {
      final f = dana.fund(v.fundId);
      if (f?.preparerPersonId != actor.personId) continue;
      final sub = switch (v.state) {
        ReadinessState.missing => 'Belum dinyatakan siap',
        ReadinessState.invalidated =>
          'Perlu dinyatakan lagi: ada pembukuan setelahnya',
        _ => null,
      };
      if (sub == null) continue;
      baris.add(
        HomeRow(
          kelompok: KelompokBaris.tindak,
          judul: 'Kesiapan peruntukan ${f!.name} · ${namaBulan(berikut)}',
          sub: sub,
          label: 'Hambatan',
          gaya: GayaLabel.bata,
          ke: Layar.kesiapan,
        ),
      );
    }
  }

  return [
    for (final r in baris)
      if (ref.watch(penjagaProvider(r.ke)) == null) r,
  ];
}
