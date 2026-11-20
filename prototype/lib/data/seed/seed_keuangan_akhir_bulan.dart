import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import 'jangkar.dart';
import 'seed_store.dart';

/// The month-end seed (README 5.6, 5.7; mock-data 2.8, 2.11, 2.15; DP11,
/// DP16, DP18, DP37): the closed M−2's reconciliations and counts, M−1's
/// Bank BNI statement (12-odd lines already matched, the three of mutasi
/// file still open), Kas Kolom 7's unit count without a confirmation, the
/// Diakonia readiness attested before a later Diakonia posting, the seeded
/// incident `K-{y}-01` and the accepted report template. Figures come from
/// the seeded ledger (D11): a statement closes at what its lines give.
void seedKeuanganAkhirBulan(SeedStore store, Jangkar a) {
  final k = store.keuangan;
  final dua = k.periods[0], satu = k.periods[1];

  int diAkun(Transaction t, String akun) {
    var n = 0;
    for (final e in effectsOf(t)) {
      for (final l in e.legs) {
        if (l.accountId == akun) n += l.amount;
      }
    }
    return n;
  }

  Iterable<Transaction> gerak(String akun, Period p) => k.posted.where(
    (t) => p.contains(t.effectiveDate) && diAkun(t, akun) != 0,
  );

  /// The audit line the repository would have written (seed_keuangan.dart's
  /// pattern): Riwayat reads AuditRepository (README 3.4, DP11).
  const jabatanDari = {
    'meiske': 'bendahara-jemaat',
    'jefry': 'pemeriksa-kedua',
    'deasy': 'bendahara-kolom-7',
    'olga': 'bendahara-komisi-diakonia',
  };
  void jejak(
    DateTime saat,
    String orang,
    String aksi,
    String ringkas,
    RecordRef ref,
  ) {
    final post = store.inti.post(jabatanDari[orang]!)!;
    store.inti.audit.add(
      AuditRecord(
        id: store.newId('aud'),
        at: saat,
        personId: orang,
        personName: store.inti.person(orang)!.name,
        actingRole: post.title,
        assignmentId: 'tugas-${post.id}-$orang',
        scopeId: post.scopeId,
        module: Module.finance,
        action: aksi,
        summary: ringkas,
        ref: ref,
      ),
    );
  }

  String bulanDari(Period p) => bulanTahun(p.year, p.month);

  /// Sheets per denomination for [jumlah], largest first.
  Map<int, int> lembar(int jumlah) {
    const pecahan = [100000, 50000, 20000, 10000, 5000, 2000, 1000];
    final m = <int, int>{};
    var sisa = jumlah;
    for (final p in pecahan) {
      m[p] = sisa ~/ p;
      sisa %= p;
    }
    return m;
  }

  // ---------- M−2, closed: every account reconciled before the close ----------
  // A bank session is checked by Pnt. Jefry Wowor before the Bendahara
  // confirms it (D24); a cash count by its two counters confirms itself.
  final dipastikan = dua.closedAt!.subtract(const Duration(hours: 3));
  final diperiksa = dipastikan.subtract(const Duration(hours: 1));
  for (final x in k.accounts) {
    final saldo = k.accountBalance(x.id, at: dua.end);
    if (saldo == 0 && gerak(x.id, dua).isEmpty) continue;
    final s = ReconSession(
      id: 'rekon-${x.id}-${dua.id}',
      accountId: x.id,
      periodId: dua.id,
      statementClosing: x.type == AccountType.bank ? saldo : null,
      status: ReconStatus.confirmed,
      reviewedBy: x.type == AccountType.bank ? 'jefry' : null,
      reviewedAt: x.type == AccountType.bank ? diperiksa : null,
      confirmedBy: 'meiske',
      confirmedAt: dipastikan,
    );
    k.reconSessions.add(s);
    final ref = RecordRef('recon', s.id);
    if (x.type == AccountType.cash) {
      final hitung = CashCount(
        id: 'hitung-${x.id}-${dua.id}',
        accountId: x.id,
        periodId: dua.id,
        countedAt: a.jam(dua.end, 16, 0),
        denominations: lembar(saldo),
        counters: const ['Meiske L.', 'Pnt. Jefry Wowor'],
        recordedBy: 'meiske',
      );
      k.cashCounts.add(hitung);
      jejak(
        hitung.countedAt,
        'meiske',
        'finance.cash.count',
        'Hitung kas ${x.name} · ${bulanDari(dua)}: ${rp(hitung.total)}',
        ref,
      );
    } else {
      jejak(
        diperiksa,
        'jefry',
        'finance.recon.review',
        'Rekonsiliasi ${x.name} diperiksa',
        ref,
      );
      jejak(
        dipastikan,
        'meiske',
        'finance.recon.confirm',
        'Rekonsiliasi ${x.name} dipastikan',
        ref,
      );
      for (final t in gerak(x.id, dua)) {
        k.statementLines.add(
          StatementLine(
            id: 'mutasi-${x.id}-${t.id}',
            sessionId: s.id,
            date: t.effectiveDate,
            amount: diAkun(t, x.id),
            description: t.description.toUpperCase(),
            matchedTransactionIds: [t.id],
          ),
        );
      }
    }
  }

  // ---------- M−1: Bank BNI statement in, not yet matched (mock-data 2.11) ----------
  final bni = ReconSession(
    id: 'rekon-bni-${satu.id}',
    accountId: 'bni',
    periodId: satu.id,
    statementFile:
        'mutasi-bni-${bulanTahun(satu.year, satu.month).substring(0, 3).toLowerCase()}.csv',
  );
  k.reconSessions.add(bni);
  final t1 = k.bySeedKey('0118')!, t2 = k.bySeedKey('0121')!;
  final t3 = k.bySeedKey('0127')!, t4 = k.bySeedKey('0131')!;
  var mutasi = 0;
  void baris(String id, Tanggal d, int n, String uraian, [List<String>? t]) {
    mutasi += n;
    k.statementLines.add(
      StatementLine(
        id: id,
        sessionId: bni.id,
        date: d,
        amount: n,
        description: uraian,
        matchedTransactionIds: t ?? const [],
      ),
    );
  }

  for (final t in gerak('bni', satu)) {
    if ({t1, t2, t3, t4}.contains(t)) continue;
    baris(
      'mutasi-bni-${t.id}',
      t.effectiveDate,
      diAkun(t, 'bni'),
      t.description.toUpperCase(),
      [t.id],
    );
  }
  baris(
    'mutasi-bni-m1',
    t2.effectiveDate,
    diAkun(t1, 'bni') + diAkun(t2, 'bni'),
    'TRF MASUK IBU RUNTU',
  );
  baris('mutasi-bni-m2', t3.effectiveDate, diAkun(t3, 'bni'), 'TARIK TUNAI');
  baris('mutasi-bni-m3', satu.end, -15000, 'BIAYA ADM');
  bni.statementClosing = k.accountBalance('bni', at: dua.end) + mutasi;

  // ---------- M−1: Kas Kolom 7 counted by the unit, not confirmed (DP14, DP16) ----------
  final kol7 = CashCount(
    id: 'hitung-kol7-${satu.id}',
    accountId: 'kol7',
    periodId: satu.id,
    countedAt: a.jam(satu.end, 17, 0),
    denominations: lembar(k.accountBalance('kol7', at: satu.end)),
    counters: const ['Deasy Tumbelaka'],
    recordedBy: 'deasy',
  );
  k.cashCounts.add(kol7);
  jejak(
    kol7.countedAt,
    'deasy',
    'finance.cash.count',
    'Hitung kas ${k.account('kol7')!.name} · ${bulanDari(satu)}: '
        '${rp(kol7.total)}',
    RecordRef('recon', kol7.id),
  );

  // ---------- M−1 readiness (DP37): Diakonia attested before its last posting ----------
  final diakonia =
      (k.posted
              .where(
                (t) =>
                    satu.contains(t.effectiveDate) &&
                    t.allocations.any((x) => x.fundId == 'diak'),
              )
              .toList()
            ..sort((x, y) => x.finalizedAt!.compareTo(y.finalizedAt!)))
          .lastOrNull;
  if (diakonia != null) {
    final siap = ReadinessAttestation(
      id: 'siap-diak-${satu.id}',
      fundId: 'diak',
      periodId: satu.id,
      preparerId: 'olga',
      attestedAt: diakonia.finalizedAt!.subtract(const Duration(days: 1)),
    );
    k.attestations.add(siap);
    jejak(
      siap.attestedAt!,
      'olga',
      'finance.readiness.attest',
      'Kesiapan ${k.fund('diak')!.name} · ${bulanDari(satu)} dinyatakan',
      RecordRef('period', satu.id),
    );
  }

  // ---------- The seeded incident K-{y}-01 (DP18; mock-data 2.15) ----------
  final diterima = a.bln(-1, 12);
  final dicatat = a.jam(diterima, 9, 30);
  final kejadian = CloseIncident(
    id: 'kejadian-dokumen-menyusul',
    year: dicatat.year,
    number: 1,
    periodId: dua.id,
    explanation: IncidentExplanation(
      title: 'Dokumen pendukung menyusul',
      facts:
          'Kuitansi asli diterima ${tglPanjang(diterima.awal)}, setelah '
          '${bulanTahun(dua.year, dua.month)} ditutup.',
      impact: 'Tidak ada.',
      responsible: 'Meiske L., Bendahara',
      transactionIds: [?k.bySeedKey('0019')?.id],
    ),
    recordedBy: 'meiske',
    recordedAt: dicatat,
    narrativeResolution: 'Kuitansi dilampirkan pada transaksinya.',
  );
  k.incidents.add(kejadian);
  jejak(
    dicatat,
    'meiske',
    'finance.incident.record',
    '${kejadian.code} · ${kejadian.explanation.title}',
    RecordRef('incident', kejadian.id),
  );

  // ---------- Report template (DP11): accepted on M−1 day 3 ----------
  final format = ReportTemplate(
    id: 'bawaan-v1',
    name: 'Bawaan Palakat v1',
    acceptedBy: 'meiske',
    acceptedAt: a.jam(a.bln(-1, 3), 10, 15),
  );
  k.templates.add(format);
  jejak(
    format.acceptedAt!,
    'meiske',
    'finance.template.accept',
    'Persetujuan format laporan dicatat: ${format.name}',
    RecordRef('template', format.id),
  );
}
