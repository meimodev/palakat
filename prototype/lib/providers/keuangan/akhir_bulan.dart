import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layar.dart';
import '../../domain/core/core.dart';
import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../domain/finance/finance.dart';
import '../actor.dart';
import '../clock.dart';
import '../core_repositories.dart';
import '../repositories_keuangan.dart';
import 'persembahan.dart' show penghitungProvider;
import '../revision.dart';
import 'beranda.dart';

/// Month end (TutupBuku, WebTutupBuku, the reconciliation boards, HitungKas,
/// Kesiapan, SelesaikanUnit; README 5.6, DM 6.3, 6.4): read models over
/// PeriodRepository and ReconciliationRepository. Every figure is computed
/// (D11); nothing here holds state.

/// [t]'s net movement on [akunId].
int diAkun(Transaction t, String akunId) {
  var n = 0;
  for (final e in effectsOf(t)) {
    for (final l in e.legs) {
      if (l.accountId == akunId) n += l.amount;
    }
  }
  return n;
}

/// 'Okt' of [p], for file names ('mutasi-bni-okt.csv').
String singkatBulan(Period p) =>
    bulanTahun(p.year, p.month).substring(0, 3).toLowerCase();

/// '1–31 {Bulan} {tahun}', or from the cutover in the first period (RD05).
String rentangPeriode(Period p) {
  final b = bulanTahun(p.year, p.month);
  return '${p.start.hari}–${p.end.hari} $b';
}

// ---------- Hambatan ----------

/// One blocker as the boards print it, with the screen that clears it.
class ButirHambatan {
  const ButirHambatan({
    required this.blocker,
    required this.judul,
    required this.sub,
    required this.tombol,
    required this.ke,
    this.param = const {},
    this.anak,
  });

  final Blocker blocker;
  final String judul;
  final String sub;
  final String tombol;
  final Layar ke;
  final Map<String, String> param;
  final String? anak;

  /// The unit whose item it is ("hambatan dari unit", DL33).
  bool get dariUnit => blocker.unitScopeId != null;
}

/// One of the eight close checks (DM 6.4, mock-data 2.11).
typedef Syarat = ({String teks, bool terpenuhi});

/// The close of the next month to close (README 5.6).
class TutupBuku {
  const TutupBuku({
    required this.bulan,
    required this.periode,
    required this.hambatan,
    required this.syarat,
    required this.uangMuka,
    required this.dalamPerjalanan,
  });

  final BulanBuku bulan;

  /// The next month to close (the first OPEN period); null when none.
  final Period? periode;
  final List<ButirHambatan> hambatan;
  final List<Syarat> syarat;

  /// Advances with something outstanding ("Untuk diketahui").
  final int uangMuka;

  /// Deposits and payments in transit on the month's reconciliations.
  final int dalamPerjalanan;

  /// The month has ended: it may be closed once nothing blocks.
  bool get sudahBerakhir => periode != null && bulan.berjalan != periode;
  bool get siap => sudahBerakhir && hambatan.isEmpty;
}

final tutupBukuProvider = Provider<TutupBuku>((ref) {
  ref.watch(revisionProvider);
  final bulan = ref.watch(bulanBukuProvider);
  final p = bulan.berikutDitutup;
  final per = ref.watch(periodRepositoryProvider);
  final akun = ref.watch(accountRepositoryProvider);
  final tx = ref.watch(transactionRepositoryProvider);
  final rekon = ref.watch(reconciliationRepositoryProvider);
  final dana = ref.watch(fundRepositoryProvider);
  if (p == null) {
    return TutupBuku(
      bulan: bulan,
      periode: null,
      hambatan: const [],
      syarat: const [],
      uangMuka: 0,
      dalamPerjalanan: 0,
    );
  }
  final nama = namaBulan(p);
  Account? a(String? id) =>
      akun.accounts(includeInactive: true).where((x) => x.id == id).firstOrNull;
  Transaction? t(String? id) => id == null ? null : tx.get(id);
  String voucher(String? id) => t(id)?.voucher ?? t(id)?.description ?? '';
  final blok = per.blockers(p.id);

  ButirHambatan butir(Blocker b) {
    final unit = b.unitScopeId != null;
    final x = a(b.accountId);
    switch (b.kind) {
      case BlockerKind.earlierPeriodOpen:
        return ButirHambatan(
          blocker: b,
          judul: 'Bulan sebelumnya belum ditutup',
          sub: 'Bulan ditutup satu per satu, mulai dari yang paling lama.',
          tombol: 'Buka bulan',
          ke: Layar.tutupBuku,
        );
      case BlockerKind.statementMissing:
        return ButirHambatan(
          blocker: b,
          judul: '${x?.name} belum ada rekening koran',
          sub: 'Saldo rekening koran $nama belum diisi',
          tombol: unit ? 'Selesaikan untuk unit' : 'Isi rekening koran',
          ke: unit ? Layar.hambatanUnit : Layar.rekeningKoran,
        );
      case BlockerKind.cashCountMissing:
        return ButirHambatan(
          blocker: b,
          judul: '${x?.name} belum dihitung',
          sub: 'Hitung kas akhir $nama belum dicatat',
          tombol: unit ? 'Selesaikan untuk unit' : 'Hitung kas',
          ke: unit ? Layar.hambatanUnit : Layar.hitungKas,
        );
      case BlockerKind.notReconciled:
        final r = ref.watch(rekonAkunProvider(b.accountId!));
        final sub = r?.selisih == null
            ? 'Rekonsiliasi belum dipastikan'
            : r!.selisih == 0
            ? 'Selisih sudah Rp0, rekonsiliasi belum dipastikan'
            : 'Selisih belum dijelaskan ${rp(r.selisih!)}';
        final tunai = x?.type == AccountType.cash;
        return ButirHambatan(
          blocker: b,
          judul: '${x?.name} belum direkonsiliasi',
          sub: sub,
          tombol: unit
              ? 'Selesaikan untuk unit'
              : tunai
              ? 'Hitung kas'
              : 'Buka rekonsiliasi',
          ke: unit
              ? Layar.hambatanUnit
              : tunai
              ? Layar.hitungKas
              : Layar.tutupBuku,
          anak: unit || tunai ? null : 'rekonsiliasi',
        );
      case BlockerKind.missingClassification:
        return ButirHambatan(
          blocker: b,
          judul: '${voucher(b.transactionId)} belum punya Mata Anggaran',
          sub: t(b.transactionId)?.description ?? '',
          tombol: 'Buka transaksi',
          ke: Layar.transaksiRinci,
          param: {'id': b.transactionId!},
        );
      case BlockerKind.approvalMissing:
        return ButirHambatan(
          blocker: b,
          judul: 'Persetujuan ${voucher(b.transactionId)} belum dicatat',
          sub: t(b.transactionId)?.description ?? '',
          tombol: 'Catat persetujuan',
          ke: Layar.persetujuan,
          param: {'id': b.transactionId!},
        );
      case BlockerKind.evidenceMissing:
        final x = t(b.transactionId);
        return ButirHambatan(
          blocker: b,
          judul: 'Dokumen pendukung ${voucher(b.transactionId)} belum ada',
          sub: '${x?.description} · ${rp(x?.total ?? 0)}',
          tombol: 'Buka dokumen pendukung',
          ke: Layar.dokumen,
        );
      case BlockerKind.openDraft:
        final x = t(b.transactionId);
        return ButirHambatan(
          blocker: b,
          judul: '1 transaksi Draf bertanggal $nama',
          sub:
              '${x?.description} · ${rp(b.amount ?? 0)} · bukukan, pindah '
              'tanggal atau batalkan',
          tombol: unit ? 'Selesaikan untuk unit' : 'Buka draf',
          ke: unit ? Layar.hambatanUnit : Layar.draf,
          param: unit ? const {} : {'id': b.transactionId!},
        );
      case BlockerKind.stagedImportRow:
        return ButirHambatan(
          blocker: b,
          judul: 'Baris impor bertanggal $nama belum dibukukan',
          sub: 'Bukukan, atau tandai tidak diimpor',
          tombol: 'Buka impor',
          ke: Layar.impor,
        );
      case BlockerKind.negativeCase:
        return ButirHambatan(
          blocker: b,
          judul: 'Sisa kasus kurang dari nol',
          sub: 'Periksa uang muka dan titipan',
          tombol: 'Buka kewajiban',
          ke: Layar.kewajiban,
        );
      case BlockerKind.readinessMissing || BlockerKind.readinessInvalidated:
        final d = dana.fund(b.fundId!);
        return ButirHambatan(
          blocker: b,
          judul: b.kind == BlockerKind.readinessMissing
              ? 'Kesiapan peruntukan ${d?.name} belum ada'
              : 'Kesiapan peruntukan ${d?.name} perlu dinyatakan lagi',
          sub: d?.preparerPersonId == null
              ? 'Pernyataan kesiapan $nama'
              : 'Dinyatakan oleh '
                    '${ref.watch(peopleRepositoryProvider).person(d!.preparerPersonId!)?.name}',
          tombol: 'Pernyataan kesiapan',
          ke: Layar.kesiapan,
        );
      case BlockerKind.templateNotAccepted:
        return ButirHambatan(
          blocker: b,
          judul: 'Persetujuan format laporan belum dicatat',
          sub: 'Format laporan Bawaan Palakat',
          tombol: 'Buka format laporan',
          ke: Layar.formatLaporan,
        );
    }
  }

  final kinds = {for (final b in blok) b.kind};
  bool ada(Set<BlockerKind> s) => s.any(kinds.contains);
  final rekonKinds = {
    BlockerKind.statementMissing,
    BlockerKind.cashCountMissing,
    BlockerKind.notReconciled,
  };
  final posted = [
    for (final x in tx.list(p.id))
      if (x.isPosted) x,
  ];
  final relevan = [
    for (final x in akun.accounts(includeInactive: true))
      if (akun.balance(x.id, at: p.end) != 0 ||
          posted.any((t) => diAkun(t, x.id) != 0))
        x,
  ];
  final belumRekon = {
    for (final b in blok)
      if (rekonKinds.contains(b.kind)) b.accountId,
  }.length;
  final draf = blok.where((b) => b.kind == BlockerKind.openDraft).length;
  var jalan = 0;
  for (final x in relevan) {
    jalan += rekon.session(x.id, p.id)?.timingItems.length ?? 0;
  }

  return TutupBuku(
    bulan: bulan,
    periode: p,
    hambatan: [for (final b in blok) butir(b)],
    syarat: [
      (
        teks: 'bulan sebelumnya sudah ditutup',
        terpenuhi: !ada({BlockerKind.earlierPeriodOpen}),
      ),
      (
        teks: belumRekon == 0
            ? 'semua ${relevan.length} kas/bank sudah direkonsiliasi'
            : '${relevan.length - belumRekon} dari ${relevan.length} kas/bank '
                  'sudah direkonsiliasi',
        terpenuhi: belumRekon == 0,
      ),
      (
        teks: 'Mata Anggaran sudah dipilih untuk semua transaksi',
        terpenuhi: !ada({BlockerKind.missingClassification}),
      ),
      (
        teks: 'persetujuan yang wajib sudah dicatat',
        terpenuhi: !ada({BlockerKind.approvalMissing}),
      ),
      (
        teks: 'dokumen pendukung wajib sudah terverifikasi atau dikecualikan',
        terpenuhi: !ada({BlockerKind.evidenceMissing}),
      ),
      (
        teks: draf == 0
            ? 'tidak ada transaksi Draf atau Sudah diperiksa'
            : 'masih ada $draf transaksi Draf',
        terpenuhi: draf == 0,
      ),
      (
        teks: 'tidak ada baris impor yang tertunda',
        terpenuhi: !ada({BlockerKind.stagedImportRow}),
      ),
      (
        teks: 'persetujuan format laporan sudah dicatat',
        terpenuhi: !ada({BlockerKind.templateNotAccepted}),
      ),
    ],
    uangMuka: ref
        .watch(caseRepositoryProvider)
        .advances()
        .where((c) => c.outstanding > 0)
        .length,
    dalamPerjalanan: jalan,
  );
});

// ---------- Rekonsiliasi ----------

/// One statement line with what it is matched to and what could match it.
class BarisMutasi {
  const BarisMutasi({
    required this.baris,
    required this.cocok,
    required this.sisa,
    required this.saran,
    required this.calon,
  });

  final StatementLine baris;

  /// The transactions it is matched to (a draft made from it included).
  final List<Transaction> cocok;

  /// What is not yet matched to posted transactions.
  final int sisa;

  /// The exact set "Cocokkan" proposes (mock-data 2.11), or empty.
  final List<Transaction> saran;

  /// Every posted transaction that may still be matched to it.
  final List<Transaction> calon;

  bool get lunas => sisa == 0;
}

/// One Kas/Bank's reconciliation for the next month to close.
class RekonAkun {
  const RekonAkun({
    required this.akun,
    required this.periode,
    required this.sesi,
    required this.buku,
    required this.amati,
    required this.setor,
    required this.bayar,
    required this.mutasi,
    required this.belumDiKoran,
    required this.dalamPerjalanan,
    required this.hitung,
    required this.wajibPeriksa,
    required this.pemeriksa,
  });

  final Account akun;
  final Period periode;
  final ReconSession? sesi;

  /// Saldo buku at the month's end.
  final int buku;

  /// The statement closing (bank) or the latest count (cash).
  final int? amati;
  final int setor, bayar;
  final List<BarisMutasi> mutasi;

  /// Posted movements no statement line holds or proposes.
  final List<Transaction> belumDiKoran;
  final List<Transaction> dalamPerjalanan;

  /// The latest cash count of the month (cash).
  final CashCount? hitung;

  /// The second-checker rule in force for the month (D24): the session is
  /// marked "Sudah diperiksa" by someone else before it is confirmed.
  final bool wajibPeriksa;

  /// Who marked the session "Sudah diperiksa", while it is REVIEWED.
  final String? pemeriksa;

  bool get diperiksa => sesi?.status == ReconStatus.reviewed;

  /// The Tahapan chips (09-rekonisi.md: three with the second checker).
  List<String> get tahapan => [
    'Sedang dikerjakan',
    if (wajibPeriksa) 'Sudah diperiksa',
    'Sudah dipastikan',
  ];

  /// Chips done (a stale confirmation is handled by the screen).
  int get tahapSelesai => dipastikan
      ? tahapan.length
      : diperiksa
      ? 2
      : 1;

  /// The status the badges print.
  String get status => dipastikan
      ? 'Sudah dipastikan'
      : diperiksa
      ? 'Sudah diperiksa'
      : 'Sedang dikerjakan';

  /// The TombolBersyarat label: the second checker marks first.
  String get tombolPastikan => wajibPeriksa && !diperiksa && !dipastikan
      ? 'Tandai sudah diperiksa'
      : 'Pastikan rekonsiliasi';

  /// The reason above "Pastikan rekonsiliasi" once checked.
  String? get alasanDiperiksa => diperiksa
      ? 'Sudah diperiksa oleh $pemeriksa. Bendahara memastikan.'
      : null;

  int? get pembanding => amati == null ? null : amati! + setor - bayar;
  int? get selisih => pembanding == null ? null : buku - pembanding!;
  bool get dipastikan => sesi?.status == ReconStatus.confirmed;
  int get cocok => mutasi.where((m) => m.lunas).length;
  List<BarisMutasi> get belumCocok => [
    for (final m in mutasi)
      if (!m.lunas) m,
  ];

  /// Why "Pastikan" cannot run yet (the repository's words), or null.
  String? get alasanBelum => amati == null
      ? (akun.type == AccountType.cash
            ? 'Kas belum dihitung.'
            : 'Saldo rekening koran belum diisi.')
      : selisih != 0
      ? 'Selisih belum dijelaskan harus Rp0 sebelum rekonsiliasi dapat '
            'dipastikan.'
      : belumCocok.isNotEmpty
      ? 'Masih ada mutasi bank yang belum cocok seluruhnya.'
      : null;
}

/// [RekonAkun] of an account in the next month to close.
final rekonAkunProvider = Provider.family<RekonAkun?, String>((ref, akunId) {
  ref.watch(revisionProvider);
  final p = ref.watch(bulanBukuProvider).berikutDitutup;
  final akun = ref
      .watch(accountRepositoryProvider)
      .accounts(includeInactive: true)
      .where((x) => x.id == akunId)
      .firstOrNull;
  if (p == null || akun == null) return null;
  return _rekon(ref, akun, p);
});

RekonAkun _rekon(Ref ref, Account akun, Period p) {
  final r = ref.watch(reconciliationRepositoryProvider);
  final tx = ref.watch(transactionRepositoryProvider);
  final s = r.session(akun.id, p.id);
  final semua = [
    for (final t in tx.list(p.id))
      if (t.isPosted && diAkun(t, akun.id) != 0) t,
  ];
  final baris = s == null ? const <StatementLine>[] : r.statementLines(s.id);
  final dipakai = {for (final l in baris) ...l.matchedTransactionIds};
  final jalan = {...?s?.timingItems.keys};
  final bebas = [
    for (final t in semua)
      if (!dipakai.contains(t.id) && !jalan.contains(t.id)) t,
  ];
  final disarankan = <String>{};
  final mutasi = <BarisMutasi>[];
  for (final l in baris) {
    final cocok = [for (final id in l.matchedTransactionIds) ?tx.get(id)];
    final sisa =
        l.amount -
        cocok
            .where((t) => t.isPosted)
            .fold<int>(0, (n, t) => n + diAkun(t, akun.id));
    final calon = sisa == 0 || cocok.any((t) => !t.isPosted)
        ? const <Transaction>[]
        : [
            for (final t in bebas)
              if (diAkun(t, akun.id).sign == sisa.sign &&
                  diAkun(t, akun.id).abs() <= sisa.abs())
                t,
          ];
    var saran = <Transaction>[];
    final sisaBebas = [
      for (final t in calon)
        if (!disarankan.contains(t.id)) t,
    ];
    final satu = sisaBebas.where((t) => diAkun(t, akun.id) == sisa).firstOrNull;
    if (satu != null) {
      saran = [satu];
    } else {
      for (var i = 0; i < sisaBebas.length && saran.isEmpty; i++) {
        for (var j = i + 1; j < sisaBebas.length; j++) {
          if (diAkun(sisaBebas[i], akun.id) + diAkun(sisaBebas[j], akun.id) ==
              sisa) {
            saran = [sisaBebas[i], sisaBebas[j]];
            break;
          }
        }
      }
    }
    disarankan.addAll(saran.map((t) => t.id));
    mutasi.add(
      BarisMutasi(
        baris: l,
        cocok: cocok,
        sisa: sisa,
        saran: saran,
        calon: calon,
      ),
    );
  }
  var setor = 0, bayar = 0;
  for (final id in jalan) {
    final t = tx.get(id);
    if (t == null || !t.isPosted) continue;
    final n = diAkun(t, akun.id);
    if (n > 0) setor += n;
    if (n < 0) bayar -= n;
  }
  final hitung = [
    for (final c in r.cashCounts(akun.id))
      if (c.periodId == p.id) c,
  ].firstOrNull;
  return RekonAkun(
    akun: akun,
    periode: p,
    sesi: s,
    buku: ref.watch(accountRepositoryProvider).balance(akun.id, at: p.end),
    amati: akun.type == AccountType.cash ? hitung?.total : s?.statementClosing,
    setor: setor,
    bayar: bayar,
    mutasi: mutasi,
    belumDiKoran: [
      for (final t in bebas)
        if (!disarankan.contains(t.id)) t,
    ],
    dalamPerjalanan: [for (final id in jalan) ?tx.get(id)],
    hitung: hitung,
    wajibPeriksa: ref
        .watch(settingsRepositoryProvider)
        .rulesInForce(at: p.end)
        .secondChecker,
    pemeriksa: s?.status == ReconStatus.reviewed
        ? ref.watch(peopleRepositoryProvider).person(s!.reviewedBy!)?.name
        : null,
  );
}

/// The church bank the TutupBuku `/rekonsiliasi` view opens: the first with
/// a statement and no confirmation, else the first with one at all.
final akunRekonProvider = Provider<String?>((ref) {
  final p = ref.watch(bulanBukuProvider).berikutDitutup;
  if (p == null) return null;
  final bank = _bankGereja(ref);
  final r = ref.watch(reconciliationRepositoryProvider);
  return bank
          .where((a) {
            final s = r.session(a.id, p.id);
            return s?.statementClosing != null &&
                s!.status != ReconStatus.confirmed;
          })
          .firstOrNull
          ?.id ??
      bank
          .where((a) => r.session(a.id, p.id)?.statementClosing != null)
          .firstOrNull
          ?.id;
});

/// True when the actor reconciles the church's accounts (the Bendahara);
/// the Pemeriksa kedua only marks a session checked (D24).
final bisaMencocokkanProvider = Provider<bool>((ref) {
  final a = ref.watch(actorProvider);
  return a != null &&
      ref
          .watch(canProvider)
          .can(
            a,
            Capability.financeReconcile,
            ScopeRef.jemaat,
            at: ref.watch(hariIniProvider),
          );
});

/// The church bank RekonIsi fills: the first with no statement for the
/// next month to close, else the TutupBuku one. For the Pemeriksa kedua:
/// the church bank whose session waits for their check.
final akunRekeningKoranProvider = Provider<String?>((ref) {
  final p = ref.watch(bulanBukuProvider).berikutDitutup;
  if (p == null) return null;
  if (!ref.watch(bisaMencocokkanProvider)) {
    return _bankGereja(ref)
        .where((a) {
          final r = ref.watch(rekonAkunProvider(a.id));
          return r != null &&
              r.sesi != null &&
              r.wajibPeriksa &&
              !r.diperiksa &&
              !r.dipastikan &&
              r.alasanBelum == null;
        })
        .firstOrNull
        ?.id;
  }
  final r = ref.watch(reconciliationRepositoryProvider);
  final tx = ref.watch(transactionRepositoryProvider);
  final akun = ref.watch(accountRepositoryProvider);
  return _bankGereja(ref)
          .where(
            (a) =>
                r.session(a.id, p.id)?.statementClosing == null &&
                (akun.balance(a.id, at: p.end) != 0 ||
                    tx
                        .list(p.id)
                        .any((t) => t.isPosted && diAkun(t, a.id) != 0)),
          )
          .firstOrNull
          ?.id ??
      ref.watch(akunRekonProvider);
});

List<Account> _bankGereja(Ref ref) {
  ref.watch(revisionProvider);
  final hari = ref.watch(hariIniProvider);
  return [
    for (final a in ref.watch(accountRepositoryProvider).accounts())
      if (a.type == AccountType.bank && a.operatorAt(hari) == null) a,
  ];
}

/// The bundled statement file of [r]'s bank (D4: a fixed sample): one line
/// per posted movement no line holds yet, as the bank prints it.
SampleStatement sampelRekeningKoran(RekonAkun r, int saldo) {
  final ada = {for (final m in r.mutasi) ...m.baris.matchedTransactionIds};
  final bank = (r.akun.institution ?? r.akun.shortName)
      .split(' ')
      .last
      .toLowerCase();
  return SampleStatement(
    fileName: 'mutasi-$bank-${singkatBulan(r.periode)}.csv',
    closing: saldo,
    lines: [
      for (final t in [...r.belumDiKoran, ...r.dalamPerjalanan])
        if (!ada.contains(t.id) && !r.dalamPerjalanan.contains(t))
          (
            date: t.effectiveDate,
            description: t.description.toUpperCase(),
            amount: diAkun(t, r.akun.id),
          ),
    ],
  );
}

/// The bank fee draft made from a statement line (mock-data 2.11): Belanja
/// 5.03.03.00, Umum Jemaat, Lingkup Jemaat; the line is its document.
/// The Mata Anggaran of a bank fee (chart of accounts, like
/// maPersembahanMinggu).
const maBiayaBank = '5.03.03.00';

/// A DRAFT for an unmatched statement line, in the church's general Fund
/// (the first Fund the Jemaat owns, as Catat's default).
TransactionDraft drafDariMutasi(
  StatementLine l,
  String akunId,
  List<Fund> dana,
) => TransactionDraft(
  type: l.amount < 0 ? TransactionType.expense : TransactionType.income,
  effectiveDate: l.date,
  description: l.amount < 0
      ? 'Biaya administrasi bank'
      : 'Pendapatan dari rekening koran',
  accountId: akunId,
  evidenceRequired: false,
  sourceRef: l.description,
  allocations: [
    Allocation(
      amount: l.amount.abs(),
      fundId: dana
          .where((f) => f.ownerScopeId == ScopeRef.jemaatId)
          .firstOrNull
          ?.id,
      scopeId: ScopeRef.jemaatId,
      masterCode: l.amount < 0 ? maBiayaBank : null,
    ),
  ],
);

// ---------- Hitung kas ----------

/// The church Kas count (HitungKas, WebHitungKas): the month it observes,
/// its book and the latest count.
class HitungKas {
  const HitungKas({
    required this.akun,
    required this.periode,
    required this.buku,
    required this.terakhir,
    required this.rekon,
  });

  final Account akun;
  final Period periode;
  final int buku;
  final CashCount? terakhir;
  final ReconSession? rekon;

  bool get dipastikan => rekon?.status == ReconStatus.confirmed;
}

final hitungKasProvider = Provider<HitungKas?>((ref) {
  ref.watch(revisionProvider);
  final hari = ref.watch(hariIniProvider);
  final semua = ref.watch(bulanBukuProvider).semua;
  final p =
      semua.where((p) => !p.isClosed && p.end < hari).firstOrNull ??
      semua.where((p) => p.contains(hari)).firstOrNull;
  final akun = ref
      .watch(accountRepositoryProvider)
      .accounts()
      .where((a) => a.type == AccountType.cash && a.operatorAt(hari) == null)
      .firstOrNull;
  if (p == null || akun == null) return null;
  final r = ref.watch(reconciliationRepositoryProvider);
  return HitungKas(
    akun: akun,
    periode: p,
    buku: ref
        .watch(accountRepositoryProvider)
        .balance(akun.id, at: p.end < hari ? p.end : hari),
    terakhir: [
      for (final c in r.cashCounts(akun.id))
        if (c.periodId == p.id) c,
    ].firstOrNull,
    rekon: r.session(akun.id, p.id),
  );
});

/// The counters the boards offer (mock-data 2.12): the Bendahara, the
/// second checker and a unit treasurer.
final petugasHitungProvider = Provider<List<String>>(
  (ref) => [for (final p in ref.watch(penghitungProvider)) p.short],
);

// ---------- Kesiapan ----------

/// One Fund's readiness for the next month to close.
class BarisKesiapan {
  const BarisKesiapan({
    required this.dana,
    required this.lihat,
    required this.penyiap,
    required this.milikSaya,
  });

  final Fund dana;
  final ReadinessView lihat;
  final String penyiap;

  /// The signed-in person prepares it ("Nyatakan siap").
  final bool milikSaya;
}

final kesiapanProvider = Provider<List<BarisKesiapan>>((ref) {
  ref.watch(revisionProvider);
  final p = ref.watch(bulanBukuProvider).berikutDitutup;
  final a = ref.watch(actorProvider);
  if (p == null) return const [];
  final dana = ref.watch(fundRepositoryProvider);
  final orang = ref.watch(peopleRepositoryProvider);
  return [
    for (final v in ref.watch(periodRepositoryProvider).attestations(p.id))
      if (dana.fund(v.fundId) case final d?)
        BarisKesiapan(
          dana: d,
          lihat: v,
          penyiap: orang.person(d.preparerPersonId ?? '')?.name ?? '—',
          milikSaya: a != null && d.preparerPersonId == a.personId,
        ),
  ];
});

/// 'dd/mm/yyyy HH.mm' of a moment.
String waktu(DateTime d) => tglJam(d);

/// [d] as the lists print it.
String tanggalPendek(Tanggal d) => '$d';

/// Runs one command as the signed-in actor with a fresh idempotency key
/// (README 3.4); null when nobody is signed in.
Future<Result<T>?> perintah<T>(
  WidgetRef ref,
  Future<Result<T>> Function(Actor aktor, String kunci) jalan,
) async {
  final a = ref.read(actorProvider);
  if (a == null) return null;
  return jalan(a, kunciBaru(a.personId, ref.read(clockProvider)));
}

/// The closer's statement, recorded with the close (RD08).
String pernyataanTutup(Period p) =>
    'Saya sudah membaca ringkasan dan laporan sementara. Saya mengerti bahwa '
    'tutup buku ini bersifat permanen dan transaksi ${namaBulan(p)} tidak '
    'dapat dikoreksi lagi.';

/// "Ditutup oleh {nama}, Operator, …" while the closer covers the vacant
/// Bendahara post; null otherwise.
String? penutupJabatanKosong(WidgetRef ref) {
  if (!ref.watch(vacancyCoverProvider)) return null;
  final a = ref.watch(actorProvider);
  return a == null
      ? null
      : '${ref.watch(peopleRepositoryProvider).person(a.personId)?.name}, '
            'Operator';
}

/// The "Untuk diketahui" sentence of the confirmation.
String untukDiketahuiTutup(TutupBuku tb) => [
  if (tb.uangMuka > 0)
    '${tb.uangMuka} uang muka dengan sisa belum dipertanggungjawabkan',
  if (tb.dalamPerjalanan > 0)
    '${tb.dalamPerjalanan} setoran dalam perjalanan (belum tercatat di '
        'rekening koran)',
].join('; ');

/// The commands of the reconciliation views (phone and web); each returns
/// the refusal to show, or null.
abstract final class AksiRekon {
  static Future<Refusal?> _jalan<T>(
    WidgetRef ref,
    Future<Result<T>> Function(Actor a, String k) f,
  ) async => (await perintah(ref, f))?.refusal;

  /// "Cocokkan": the line with what it already holds plus [tambah].
  static Future<Refusal?> cocokkan(
    WidgetRef ref,
    RekonAkun r,
    BarisMutasi m,
    List<Transaction> tambah,
  ) => _jalan(
    ref,
    (a, k) => ref
        .read(reconciliationRepositoryProvider)
        .match(
          a,
          r.sesi!.id,
          [m.baris.id],
          [
            for (final t in m.cocok)
              if (t.isPosted) t.id,
            for (final t in tambah) t.id,
          ],
          expectedRevision: r.sesi!.revision,
          idempotencyKey: k,
        ),
  );

  static Future<Refusal?> lepaskanMutasi(
    WidgetRef ref,
    RekonAkun r,
    BarisMutasi m,
  ) => _jalan(
    ref,
    (a, k) => ref
        .read(reconciliationRepositoryProvider)
        .match(
          a,
          r.sesi!.id,
          [m.baris.id],
          const [],
          expectedRevision: r.sesi!.revision,
          idempotencyKey: k,
        ),
  );

  /// "Tandai dalam perjalanan" (again: "Lepaskan").
  static Future<Refusal?> dalamPerjalanan(
    WidgetRef ref,
    RekonAkun r,
    Transaction t,
    String bulanBerikut,
  ) => _jalan(
    ref,
    (a, k) => ref
        .read(reconciliationRepositoryProvider)
        .markTimingItem(
          a,
          r.sesi!.id,
          t.id,
          reason: 'dibawa ke $bulanBerikut',
          expectedRevision: r.sesi!.revision,
          idempotencyKey: k,
        ),
  );

  static Future<Refusal?> buatTransaksi(
    WidgetRef ref,
    RekonAkun r,
    BarisMutasi m,
  ) => _jalan(
    ref,
    (a, k) => ref
        .read(reconciliationRepositoryProvider)
        .createTxnFromLine(
          a,
          m.baris.id,
          drafDariMutasi(
            m.baris,
            r.akun.id,
            ref.read(fundRepositoryProvider).funds(),
          ),
          idempotencyKey: k,
        ),
  );

  /// The TombolBersyarat: "Tandai sudah diperiksa" (review) while the
  /// second checker has not marked an OPEN session, else confirm.
  static Future<Refusal?> pastikan(WidgetRef ref, RekonAkun r) => _jalan(
    ref,
    (a, k) => r.wajibPeriksa && r.sesi!.status == ReconStatus.open
        ? ref
              .read(reconciliationRepositoryProvider)
              .review(
                a,
                r.sesi!.id,
                expectedRevision: r.sesi!.revision,
                idempotencyKey: k,
              )
        : ref
              .read(reconciliationRepositoryProvider)
              .confirm(
                a,
                r.sesi!.id,
                expectedRevision: r.sesi!.revision,
                idempotencyKey: k,
              ),
  );
}

/// '{Bulan} {tahun}' of the month after [p].
String bulanSesudah(Period p) =>
    bulanTahun(p.month == 12 ? p.year + 1 : p.year, p.month % 12 + 1);

// ---------- Kejadian ----------

/// One incident as Kejadian lists it (07-kejadian.md).
class ButirKejadian {
  const ButirKejadian({
    required this.kejadian,
    required this.periode,
    required this.transaksi,
    required this.draf,
  });
  final CloseIncident kejadian;
  final Period periode;

  /// The No. Bukti of the transactions it explains.
  final List<String> transaksi;

  /// The settlement transaction in the open month, when one was made.
  final Transaction? draf;

  bool get selesai =>
      (kejadian.narrativeResolution ?? '').isNotEmpty || draf != null;
}

/// Kejadian (phone and web): the incidents, newest first, the last closed
/// month (where a new one is recorded) and the next month's blockers, which
/// an incident never clears.
typedef DaftarKejadian = ({
  List<ButirKejadian> butir,
  Period? ditutup,
  Period? berikut,
  int hambatan,
});

final kejadianProvider = Provider<DaftarKejadian>((ref) {
  ref.watch(revisionProvider);
  final per = ref.watch(periodRepositoryProvider);
  final tx = ref.watch(transactionRepositoryProvider);
  final bb = ref.watch(bulanBukuProvider);
  final butir = [
    for (final k in per.incidents())
      if (per.period(k.periodId) case final p?)
        ButirKejadian(
          kejadian: k,
          periode: p,
          transaksi: [
            for (final id in k.explanation.transactionIds)
              tx.get(id)?.voucher ?? id,
          ],
          draf: k.settlementTransactionId == null
              ? null
              : tx.get(k.settlementTransactionId!),
        ),
  ]..sort((a, b) => b.kejadian.recordedAt.compareTo(a.kejadian.recordedAt));
  final berikut = bb.berikutDitutup;
  return (
    butir: butir,
    ditutup: bb.semua.where((p) => p.isClosed).lastOrNull,
    berikut: berikut,
    hambatan: berikut == null ? 0 : per.blockers(berikut.id).length,
  );
});

/// The settlement draft of an incident (DM 3 CloseIncident): money found
/// ([jumlah] > 0) or missing in the church Kas, dated today in the open
/// month; the incident is its document. Money found of unknown origin is
/// booked as Sumbangan donatur; money missing has no Mata Anggaran in the
/// seed, so that draft is completed in Draf before its check.
TransactionDraft drafPenyelesaian({
  required String akunId,
  required int jumlah,
  required String judul,
  required Tanggal hari,
}) => TransactionDraft(
  type: jumlah > 0 ? TransactionType.income : TransactionType.expense,
  effectiveDate: hari,
  description: 'Penyelesaian kejadian: $judul',
  accountId: akunId,
  evidenceRequired: false,
  sourceRef: judul,
  allocations: [
    Allocation(
      amount: jumlah.abs(),
      fundId: 'umum',
      scopeId: 'jemaat',
      masterCode: jumlah > 0 ? '1.4.10.02.00' : null,
    ),
  ],
);

// ---------- Bantuan AI akhir bulan (AIBulan, WebAI) ----------

/// One month-end suggestion: the board's fixed proposals, built from the
/// reconciliation and the drafts (README 4.6 point 6). AI never books.
typedef UsulAi = ({
  String id,
  String label,
  String t,
  bool ragu,
  String pakaiTeks,
  String cat,
  String jadi,
});

/// The month-end AI panel: the budget, the reconciliation summary and the
/// suggestions, for the month next to close.
typedef AiBulan = ({
  AiBudget budget,
  Period? periode,
  String? ringkasan,
  List<UsulAi> usul,
});

final aiBulanProvider = Provider<AiBulan>((ref) {
  ref.watch(revisionProvider);
  final budget = ref.watch(aiRepositoryProvider).budget();
  final periode = ref.watch(bulanBukuProvider).berikutDitutup;
  final id = ref.watch(akunRekonProvider);
  final r = id == null ? null : ref.watch(rekonAkunProvider(id));
  String? ringkasan;
  final usul = <UsulAi>[];
  if (r != null && (r.selisih ?? 0) != 0) {
    final bagian = [
      if (r.belumDiKoran.isNotEmpty)
        '${r.belumDiKoran.length} transaksi '
            '${rp(r.belumDiKoran.fold(0, (n, t) => n + diAkun(t, r.akun.id).abs()))}'
            ' yang belum muncul di rekening koran',
      for (final m in r.belumCocok)
        if (m.calon.isEmpty && m.cocok.isEmpty)
          'mutasi “${m.baris.description}” ${rp(m.baris.amount)} yang belum '
              'dicatat',
    ];
    if (bagian.isNotEmpty) {
      ringkasan =
          'Selisih ${rp(r.selisih!.abs())} di ${r.akun.name} tampaknya '
          'terdiri dari ${bagian.join(' dan ')}.';
    }
  }
  final saran = r?.belumCocok.where((m) => m.saran.isNotEmpty).firstOrNull;
  if (saran != null) {
    final b = saran.baris;
    usul.add((
      id: 'cocok',
      label: 'Usulan AI · pencocokan',
      t:
          'Mutasi bank “${b.description} ${rp(b.amount)}” '
          '(${tanggalPendek(b.date)}) kemungkinan cocok dengan '
          '${saran.saran.map((t) => '${t.voucher} ${t.description}').join(' dan ')}.',
      ragu: false,
      pakaiTeks: 'Buka untuk dicocokkan',
      cat: 'Belum mencocokkan apa pun.',
      jadi:
          'Dibuka di rekonsiliasi. Mutasi baru cocok setelah Anda menekan '
          'Cocokkan di sana.',
    ));
  }
  if (periode != null) {
    final tx = ref.watch(transactionRepositoryProvider);
    final dibukukan = [
      for (final t in tx.list(periode.id))
        if (t.isPosted) t,
    ];
    for (final d in tx.drafts(periodId: periode.id)) {
      final kembar = dibukukan
          .where(
            (t) =>
                t.total == d.total &&
                t.type == d.type &&
                t.effectiveDate == d.effectiveDate,
          )
          .firstOrNull;
      if (kembar == null) continue;
      usul.add((
        id: 'ganda',
        label: 'Usulan AI · mungkin perlu dicek',
        t:
            '${kembar.voucher} dan draf “${d.description}” sama-sama '
            '${rp(d.total)} pada ${tanggalPendek(d.effectiveDate)}. Bisa jadi '
            'tercatat dua kali, bisa juga dua tagihan.',
        ragu: true,
        pakaiTeks: 'Lihat keduanya',
        cat: 'Hanya informasi.',
        jadi: 'Kedua transaksi dibuka berdampingan. Tidak ada yang diubah.',
      ));
      break;
    }
  }
  return (budget: budget, periode: periode, ringkasan: ringkasan, usul: usul);
});
