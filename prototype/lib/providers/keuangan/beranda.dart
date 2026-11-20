import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layar.dart';
import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../domain/finance/finance.dart';
import '../actor.dart';
import '../repositories_keuangan.dart';
import '../revision.dart';

/// The months of the books (README 5.6) as the finance screens name them:
/// the running month (the period holding today), the next to close (the
/// first OPEN period, calendar order) and the closed ones.
class BulanBuku {
  const BulanBuku({required this.semua, this.berjalan, this.berikutDitutup});

  /// Every period, calendar order.
  final List<Period> semua;

  /// The period holding today (M0).
  final Period? berjalan;

  /// The first OPEN period (M−1 at launch, M0 once M−1 is closed).
  final Period? berikutDitutup;

  /// An earlier month than the running one is still open ("{Bulan} {tahun}
  /// belum ditutup").
  bool get adaBulanLaluTerbuka =>
      berikutDitutup != null &&
      berjalan != null &&
      berikutDitutup!.start < berjalan!.start;
}

/// '{Bulan} {tahun}' of [p].
String namaBulan(Period p) => bulanTahun(p.year, p.month);

final bulanBukuProvider = Provider<BulanBuku>((ref) {
  ref.watch(revisionProvider);
  final semua = ref.watch(periodRepositoryProvider).periods();
  final hari = ref.watch(hariIniProvider);
  return BulanBuku(
    semua: semua,
    berjalan: semua.where((p) => p.contains(hari)).firstOrNull,
    berikutDitutup: semua.where((p) => !p.isClosed).firstOrNull,
  );
});

/// One month's figures (Beranda "Bulan ini", PilihBulan): posted rows only;
/// Pendapatan and Belanja without titipan (DM 4.2: I and E).
class RingkasanBulan {
  const RingkasanBulan({
    required this.periode,
    required this.dibukukan,
    required this.draf,
    required this.pendapatan,
    required this.belanja,
  });

  final Period periode;

  /// Posted transactions dated in the month (a reversal is one of them).
  final int dibukukan;

  /// Drafts dated in the month (DRAFT and REVIEWED).
  final int draf;
  final int pendapatan;
  final int belanja;

  /// "Surplus/Defisit bulan ini".
  int get surplus => pendapatan - belanja;
}

/// [RingkasanBulan] of period id 'yyyy-mm'; null for an unknown period.
final ringkasanBulanProvider = Provider.family<RingkasanBulan?, String>((
  ref,
  periodId,
) {
  ref.watch(revisionProvider);
  final p = ref.watch(periodRepositoryProvider).period(periodId);
  if (p == null) return null;
  final daftar = ref.watch(transactionRepositoryProvider).list(periodId);
  var dibukukan = 0, draf = 0, masuk = 0, keluar = 0;
  for (final t in daftar) {
    if (t.isDraft) draf++;
    if (!t.isPosted) continue;
    dibukukan++;
    for (final e in effectsOf(t)) {
      masuk += e.income;
      keluar += e.expense;
    }
  }
  return RingkasanBulan(
    periode: p,
    dibukukan: dibukukan,
    draf: draf,
    pendapatan: masuk,
    belanja: keluar,
  );
});

/// Every period with its figures, newest first (PilihBulan, WebPilihBulan).
final daftarBulanProvider = Provider<List<RingkasanBulan>>((ref) {
  final b = ref.watch(bulanBukuProvider);
  return [
    for (final p in b.semua.reversed) ?ref.watch(ringkasanBulanProvider(p.id)),
  ];
});

/// One "Perlu tindakan" or "Untuk diketahui" row of the finance home.
class ButirKeuangan {
  const ButirKeuangan({
    required this.judul,
    required this.sub,
    required this.ke,
    this.param = const {},
    this.penting = false,
  });

  final String judul;
  final String sub;
  final Layar ke;
  final Map<String, String> param;

  /// The `bata` caption (the month not yet closed).
  final bool penting;
}

/// A Kas/Bank with its book balance.
typedef SaldoAkun = ({Account akun, int saldo});

/// The finance home (Main Beranda, WebBeranda, TabBeranda; README 3.3).
class BerandaKeuangan {
  const BerandaKeuangan({
    required this.bulan,
    required this.saldoBuku,
    required this.kasBank,
    required this.drafJumlah,
    required this.drafRp,
    required this.bulanIni,
    required this.hambatan,
    required this.perluTindakan,
    required this.untukDiketahui,
    required this.drafBulanTutup,
  });

  final BulanBuku bulan;

  /// "Saldo buku semua Kas/Bank": every active Kas/Bank, Kas Kolom 7
  /// included (DP16), posted transactions only.
  final int saldoBuku;
  final List<SaldoAkun> kasBank;

  /// The dashed pill: the church's drafts (not a unit's) in open months.
  final int drafJumlah;
  final int drafRp;

  /// "Bulan ini" of the running month; null outside the periods.
  final RingkasanBulan? bulanIni;

  /// The computed blockers of the next month to close (DM 6.4).
  final List<Blocker> hambatan;
  final List<ButirKeuangan> perluTindakan;
  final List<ButirKeuangan> untukDiketahui;

  /// Drafts dated in a CLOSED month ("1 draf di bulan yang sudah ditutup"),
  /// oldest first; each opens Layar.draf with its id.
  final List<Transaction> drafBulanTutup;
}

final berandaKeuanganProvider = Provider<BerandaKeuangan>((ref) {
  ref.watch(revisionProvider);
  final bulan = ref.watch(bulanBukuProvider);
  final tx = ref.watch(transactionRepositoryProvider);
  final akun = ref.watch(accountRepositoryProvider);

  final kasBank = [
    for (final a in akun.accounts()) (akun: a, saldo: akun.balance(a.id)),
  ];
  final saldoBuku = kasBank.fold(0, (n, x) => n + x.saldo);

  bool bulanTerbuka(Transaction t) =>
      !bulan.semua.any((p) => p.isClosed && p.contains(t.effectiveDate));
  final semuaDraf = tx.drafts();
  final drafGereja = [
    for (final t in semuaDraf)
      if (t.unitScopeId == null && bulanTerbuka(t)) t,
  ];
  final drafRp = drafGereja.fold(0, (n, t) => n + t.total);
  final drafBulanTutup = [
    for (final t in semuaDraf)
      if (!bulanTerbuka(t)) t,
  ];

  final berikut = bulan.berikutDitutup;
  final hambatan = berikut == null
      ? const <Blocker>[]
      : ref.watch(periodRepositoryProvider).blockers(berikut.id);

  final perlu = <ButirKeuangan>[];
  if (bulan.adaBulanLaluTerbuka) {
    perlu.add(
      ButirKeuangan(
        judul: '${namaBulan(berikut!)} belum ditutup',
        sub: '${hambatan.length} hambatan · bulan berikutnya untuk tutup buku',
        ke: Layar.tutupBuku,
        penting: true,
      ),
    );
  }
  if (drafGereja.isNotEmpty) {
    perlu.add(
      ButirKeuangan(
        judul: '${drafGereja.length} draf belum dibukukan',
        sub: 'Belum masuk saldo',
        ke: Layar.transaksi,
      ),
    );
  }
  final bukti = ref.watch(evidenceRepositoryProvider);
  final tanpaDokumen = [
    for (final p in bulan.semua)
      if (!p.isClosed)
        for (final x in bukti.list(p.id, EvidenceStatus.requiredMissing))
          if (x.transaction.isPosted) x.transaction,
  ];
  if (tanpaDokumen.isNotEmpty) {
    final t = tanpaDokumen.first;
    perlu.add(
      ButirKeuangan(
        judul: '${tanpaDokumen.length} dokumen pendukung wajib, belum ada',
        sub: tanpaDokumen.length == 1
            ? '${t.voucher} · ${rp(t.total)}'
            : '${t.voucher} dan ${tanpaDokumen.length - 1} lainnya',
        ke: Layar.transaksi,
      ),
    );
  }
  final tanpaMa = [
    for (final t in drafGereja)
      if (t.allocations.any(
        (a) => a.masterCode == null && _perluMataAnggaran(t.typeOf(a)),
      ))
        t,
  ];
  if (tanpaMa.isNotEmpty) {
    perlu.add(
      ButirKeuangan(
        judul: '${tanpaMa.length} Mata Anggaran belum dipilih',
        sub: tanpaMa.length == 1
            ? 'Draf · ${tanpaMa.first.description}'
            : 'Draf · ${tanpaMa.length} transaksi',
        ke: Layar.transaksi,
      ),
    );
  }

  final tahu = <ButirKeuangan>[];
  final uangMuka = [
    for (final c in ref.watch(caseRepositoryProvider).advances())
      if (c.outstanding > 0) c,
  ];
  if (uangMuka.isNotEmpty) {
    tahu.add(
      ButirKeuangan(
        judul:
            '${uangMuka.length} uang muka dengan sisa belum '
            'dipertanggungjawabkan',
        sub: rp(uangMuka.fold(0, (n, c) => n + c.outstanding)),
        ke: Layar.kewajiban,
      ),
    );
  }

  final berjalan = bulan.berjalan;
  return BerandaKeuangan(
    bulan: bulan,
    saldoBuku: saldoBuku,
    kasBank: kasBank,
    drafJumlah: drafGereja.length,
    drafRp: drafRp,
    bulanIni: berjalan == null
        ? null
        : ref.watch(ringkasanBulanProvider(berjalan.id)),
    hambatan: hambatan,
    perluTindakan: perlu,
    untukDiketahui: tahu,
    drafBulanTutup: drafBulanTutup,
  );
});

/// A part of this type needs a Mata Anggaran (it moves I, E or titipan).
bool _perluMataAnggaran(TransactionType t) {
  final s = postingSigns[t];
  return s != null &&
      (s.income != 0 ||
          s.expense != 0 ||
          s.transitIn != 0 ||
          s.transitOut != 0);
}

/// The Kas/Bank name of [t] as the lists print it: one account, "Kas ke
/// Bank BNI" for a transfer, the names of a split's accounts joined.
String namaKasBank(Transaction t, Account? Function(String? id) akun) {
  String nama(String? id) => akun(id)?.name ?? 'Kas/Bank belum dipilih';
  if (t.toAccountId != null) {
    return '${akun(t.accountId)?.shortName ?? '…'} ke '
        '${akun(t.toAccountId)?.shortName ?? '…'}';
  }
  final ids = {for (final a in t.allocations) t.accountOf(a)}..remove(null);
  if (ids.length > 1) return ids.map(nama).join('; ');
  return nama(ids.firstOrNull ?? t.accountId);
}

/// A date as the lists print it ('dd/mm/yyyy').
String tanggalDaftar(Tanggal d) => '$d';
