import '../../core/tanggal.dart';
import '../../domain/finance/finance.dart';
import 'jangkar.dart';
import 'seed_inti.dart';
import 'seed_jemaat.dart';
import 'seed_keuangan.dart';
import 'seed_keuangan_akhir_bulan.dart';
import 'seed_keuangan_kasus.dart';
import 'seed_keuangan_pengaturan.dart';
import 'seed_kolaborasi.dart';
import 'seed_sekretariat.dart';
import 'seed_store.dart';

/// Builds the launch state from T = [anchor] (WITA) and [now] (README 5.3,
/// 5.7): every seed function in table order, then the invariants of 5.4.
SeedStore buildSeed({required Tanggal anchor, required DateTime now}) {
  final store = SeedStore(anchor: anchor, launchedAt: now);
  final a = Jangkar(hariIni: anchor, sekarang: now);
  seedInti(store, a);
  seedKeuangan(store, a);
  seedKeuanganKasus(store, a);
  seedKeuanganAkhirBulan(store, a);
  seedKeuanganPengaturan(store, a);
  seedSekretariat(store, a);
  seedJemaat(store, a);
  seedKolaborasi(store, a);
  assert(_periksa(store, now));
  assert(store.ledgerBalanced, 'jumlah Kas/Bank tidak sama dengan peruntukan');
  assert(_bukuBulanLalu(store, a), 'buku M−1 tidak berakhir di saldo barisnya');
  return store;
}

/// README 5.4, the invariants that hold for the core tables: no seeded time
/// after now; every assignment, cover and delegation starts on or before T;
/// a delegation drawn as ended ends before T. Later milestones add theirs.
bool _periksa(SeedStore s, DateTime now) {
  final t = s.inti;
  final hariIni = s.anchor;
  void tidakSetelah(DateTime? saat, String apa) {
    assert(
      saat == null || !saat.isAfter(now),
      '$apa: $saat setelah sekarang $now',
    );
  }

  for (final r in t.audit) {
    tidakSetelah(r.at, 'audit ${r.summary}');
  }
  for (final n in t.notifications) {
    tidakSetelah(n.createdAt, 'pemberitahuan ${n.title}');
  }
  for (final d in t.devices) {
    tidakSetelah(d.lastUsed, 'perangkat ${d.name}');
  }
  for (final m in t.modules) {
    tidakSetelah(m.changedAt, 'modul ${m.module.label}');
  }
  for (final g in t.authorityGrants) {
    tidakSetelah(g.recordedAt, 'wewenang ${g.id}');
    tidakSetelah(g.verifiedAt, 'wewenang ${g.id}');
  }
  for (final x in t.assignments) {
    assert(x.start <= hariIni, 'penugasan ${x.id} mulai ${x.start}');
    tidakSetelah(x.recordedAt, 'penugasan ${x.id}');
    assert(x.end == null || x.end! < hariIni, 'penugasan ${x.id} berakhir');
  }
  for (final c in t.covers) {
    assert(c.start <= hariIni, 'jabatan kosong ${c.id}');
    tidakSetelah(c.startedAt, 'jabatan kosong ${c.id}');
  }
  for (final d in t.delegations) {
    assert(d.start <= hariIni, 'pelimpahan ${d.id} mulai ${d.start}');
    tidakSetelah(d.createdAt, 'pelimpahan ${d.id}');
  }
  final k = s.keuangan;
  for (final x in k.transactions) {
    tidakSetelah(x.createdAt, 'transaksi ${x.description}');
    tidakSetelah(x.finalizedAt, 'transaksi ${x.description}');
    tidakSetelah(x.reviewedAt, 'transaksi ${x.description}');
    tidakSetelah(x.cancelledAt, 'transaksi ${x.description}');
    assert(x.effectiveDate <= hariIni || x.isDraft, 'transaksi ${x.id}');
  }
  for (final u in k.unfinishedVouchers) {
    tidakSetelah(u.allocatedAt, 'nomor ${u.seedKey}');
  }
  // The Sekretaris → Yanti delegation is drawn as ended.
  final lalu = t.delegations.where((d) => d.id == 'pelimpahan-olvie-yanti');
  assert(lalu.every((d) => d.end! < hariIni), 'pelimpahan lalu belum berakhir');
  return true;
}

/// README 5.4: the M−1 ledger ends at the balance its own rows give: the
/// balance before M−1 plus every posted M−1 movement.
bool _bukuBulanLalu(SeedStore s, Jangkar a) {
  final k = s.keuangan;
  final sebelum = a.bln(-1, 1).tambahHari(-1), akhir = a.akhirBln(-1);
  int saldo(Tanggal t) =>
      k.accounts.fold(0, (n, x) => n + k.accountBalance(x.id, at: t));
  final gerak = k.posted
      .where((t) => t.effectiveDate > sebelum && t.effectiveDate <= akhir)
      .fold(0, (n, t) => n + signedAmount(t));
  return saldo(sebelum) + gerak == saldo(akhir);
}
