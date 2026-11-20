import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import 'jangkar.dart';
import 'seed_store.dart';

/// README 5.7, M3: cases, approvals, evidence and the staged import batch
/// (seed.md 4, mock-data 2.10, 2.14, 2.15). The case ids are already on the
/// parts of `seed_keuangan.dart`; this file adds the case records, the two
/// rows that complete drawn cases (DP9 Selvie's spending, tt2), and the
/// decision lines of approvals and documents.
void seedKeuanganKasus(SeedStore store, Jangkar a) {
  final k = store.keuangan;
  Tanggal h(int d) => a.hariCerita(d);
  String tgl(Tanggal d) =>
      '${d.hari.toString().padLeft(2, '0')}/'
      '${d.bulan.toString().padLeft(2, '0')}/${d.tahun}';
  String namaBulan(int m) =>
      bulanTahun(a.bulan(m).$1, a.bulan(m).$2).split(' ').first;
  final bku = k.bySeedKey;

  // ---------- Two posted rows the drawn cases need ----------
  Transaction buku(
    String kunci,
    TransactionType jenis,
    Tanggal d,
    String uraian,
    Allocation bagian, {
    String? akun,
  }) {
    final booked = a.jam(d, 10, 0);
    final t = Transaction(
      id: 'bku-$kunci',
      seedKey: kunci,
      type: jenis,
      status: TransactionStatus.finalized,
      effectiveDate: d,
      description: uraian,
      allocations: [bagian],
      accountId: akun,
      createdBy: 'meiske',
      createdAt: booked.subtract(const Duration(minutes: 30)),
      reviewedBy: 'jefry',
      reviewedAt: booked.subtract(const Duration(minutes: 10)),
      finalizedBy: 'meiske',
      finalizedAt: booked,
    );
    // After the walk of seed_keuangan: the next free number of its year.
    t
      ..voucherYear = d.tahun
      ..voucherNumber = store.nextVoucher(t.series.code, d.tahun);
    k.transactions.add(t);
    for (final (saat, orang, jabatan, aksi, ringkas) in [
      (
        t.createdAt,
        'meiske',
        'bendahara-jemaat',
        'finance.txn.draft',
        'Draf dicatat: $uraian',
      ),
      (
        t.reviewedAt!,
        'jefry',
        'pemeriksa-kedua',
        'finance.txn.review',
        'Ditandai sudah diperiksa: $uraian',
      ),
      (
        booked,
        'meiske',
        'bendahara-jemaat',
        'finance.txn.finalize',
        'Dibukukan ${t.voucher} · $uraian',
      ),
    ]) {
      final post = store.inti.post(jabatan)!;
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
          ref: RecordRef('transaction', t.id),
        ),
      );
    }
    return t;
  }

  // DP9: Selvie's advance spent in full; the Rp75.000 above it is a claim.
  buku(
    '0119a',
    TransactionType.advanceSpending,
    h(4),
    'Pertanggungjawaban uang muka · Konsumsi syukur HUT',
    const Allocation(
      amount: 300000,
      fundId: 'umum',
      scopeId: 'jemaat',
      partyId: 'party-selvie',
      masterCode: '5.04.01.00',
      caseId: 'um4',
    ),
  );
  // tt2: "Dari persembahan khusus {d} {bulan} · disimpan di Kas".
  final khusus = a.mingguLalu(2);
  buku(
    '0132c',
    TransactionType.transitCollection,
    khusus,
    'Titipan untuk: Wilayah · Persembahan khusus',
    const Allocation(
      amount: 450000,
      fundId: 'umum',
      scopeId: 'jemaat',
      partyId: 'party-wilayah',
      masterCode: '2.1.01.02.00',
      caseId: 'tt2',
    ),
    akun: 'kas',
  );

  // ---------- Cases (mock-data 2.10; DP9, DP27) ----------
  FinanceCase kasus(
    String id,
    CaseKind jenis,
    String judul,
    Tanggal dibuka, {
    String? pihak,
    String? lingkup,
    String? akun,
    Tanggal? tempo,
    int? klaim,
    String? catatan,
    bool dicek = false,
  }) => FinanceCase(
    id: id,
    seedKey: id,
    kind: jenis,
    title: judul,
    fundId: 'umum',
    openedOn: dibuka,
    createdBy: 'meiske',
    createdAt: a.jam(dibuka, 9, 0),
    partyId: pihak,
    scopeId: lingkup ?? 'jemaat',
    accountId: akun,
    dueDate: tempo,
    claimAmount: klaim,
    note: catatan,
    checkedBy: dicek ? 'meiske' : null,
    checkedAt: dicek ? a.jam(dibuka, 9, 30) : null,
  );

  final issue2 = a.bln(-1, 20);
  k.cases.addAll([
    kasus('um-hut', CaseKind.advance, 'Panitia HUT Jemaat', a.bln(-2, 17)),
    kasus(
      'um1',
      CaseKind.advance,
      'Panitia Natal',
      h(1),
      pihak: 'party-rivo',
      lingkup: 'panitia-natal',
      akun: 'kas',
      tempo: a.akhirBln(0),
    ),
    // README 5.4: due T − 6 days, never before its issue date.
    kasus(
      'um2',
      CaseKind.advance,
      'Retret Pemuda',
      issue2,
      pihak: 'party-natalia',
      lingkup: 'bipra-pemuda',
      akun: 'kas',
      tempo: a.tidakSebelum(a.hariIni.tambahHari(-6), issue2),
    ),
    kasus(
      'um3',
      CaseKind.advance,
      'Perjalanan dinas Wilayah',
      a.bln(-1, 7),
      pihak: 'party-jefry',
      akun: 'kas',
    ),
    kasus(
      'um4',
      CaseKind.advance,
      'Konsumsi syukur HUT',
      a.bln(-1, 25),
      pihak: 'party-selvie',
      akun: 'kas',
    ),
    kasus(
      'tt-okt',
      CaseKind.transit,
      'Sentralisasi ${namaBulan(-1)}',
      a.minggu(-1, 1),
      pihak: 'party-sinode',
      akun: 'kas',
    ),
    kasus(
      'tt1',
      CaseKind.transit,
      'Sentralisasi ${namaBulan(0)}',
      a.bln(0, 1),
      pihak: 'party-sinode',
      akun: 'bni',
    ),
    kasus(
      'tt2',
      CaseKind.transit,
      'Persembahan khusus',
      khusus,
      pihak: 'party-wilayah',
      akun: 'kas',
      catatan:
          'Dari persembahan khusus ${khusus.hari} ${namaBulan(0)} · '
          'disimpan di Kas',
    ),
    kasus(
      'pb1',
      CaseKind.claim,
      'Alat kebersihan gereja',
      h(12),
      pihak: 'party-selvie',
      klaim: 185000,
      catatan: 'Nota ${tgl(h(12))} terlampir',
    ),
    kasus(
      'pb2',
      CaseKind.claim,
      'Bensin antar jemput',
      h(2),
      pihak: 'party-rivo',
      klaim: 120000,
      catatan: 'Nota ${tgl(h(2))} terlampir',
      dicek: true,
    ),
    kasus(
      'pb-hut',
      CaseKind.claim,
      'Kelebihan konsumsi syukur HUT',
      h(4),
      pihak: 'party-selvie',
      klaim: 75000,
      catatan: 'Dari uang muka ${bku('0119')?.voucher}',
      dicek: true,
    ),
  ]);

  // ---------- External approvals (DM 5.2; mock-data 2.7, 2.9) ----------
  for (final kunci in const ['0116', '0137']) {
    final t = bku(kunci)!;
    k.approvals.add(
      ApprovalRecord(
        id: 'setuju-$kunci',
        transactionId: t.id,
        declaration: ApprovalDeclaration(
          approverName: 'Pdt. Lidya Rondonuwu',
          approverRole: 'Ketua BPMJ',
          date: t.effectiveDate,
          method: 'notulen rapat',
        ),
        recordedBy: 'meiske',
        recordedAt: t.createdAt.add(const Duration(minutes: 5)),
        transactionRevision: t.revision,
      ),
    );
  }

  // ---------- Supporting documents (DM 5.3; mock-data 2.14) ----------
  // Receipts are scanned at the office (Yanti) and verified by the
  // Bendahara: no self-verification (README 3.5). 0143 stays missing (F12);
  // 0140 and 0145 wait for verification; 0116 and 0137 are excepted.
  String nota(Tanggal d) =>
      'nota-${d.hari.toString().padLeft(2, '0')}-'
      '${d.bulan.toString().padLeft(2, '0')}.jpg';
  const menunggu = {'0140', '0145'};
  const dikecualikan = {'0116', '0137'};
  for (final t in k.transactions) {
    if (!t.isPosted || !t.evidenceRequired || t.seedKey == '0143') continue;
    final unggah = t.createdAt.add(const Duration(minutes: 5));
    if (dikecualikan.contains(t.seedKey)) {
      k.evidence.add(
        EvidenceItem(
          id: 'bukti-${t.id}',
          transactionId: t.id,
          state: EvidenceItemState.exception,
          by: 'meiske',
          at: unggah,
          reason: 'kuitansi menyusul',
        ),
      );
      continue;
    }
    final tunggu = menunggu.contains(t.seedKey);
    k.evidence.add(
      EvidenceItem(
        id: 'bukti-${t.id}',
        transactionId: t.id,
        state: tunggu ? EvidenceItemState.uploaded : EvidenceItemState.verified,
        by: 'yanti',
        at: unggah,
        file: SampleFile(nota(t.effectiveDate)),
        decidedBy: tunggu ? null : 'meiske',
        decidedAt: tunggu ? null : t.finalizedAt,
      ),
    );
  }

  // ---------- Staged import (seed.md 4; the Impor board) ----------
  final (thn, bln) = a.bulan(0);
  String yy(Tanggal d) => tgl(d).replaceRange(6, 8, '');
  const singkat = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', //
    'Jul', 'Agu', 'Sep', 'Okt', 'Nop', 'Des',
  ];
  final hariTerakhir = a.akhirBln(0).hari;
  final batch = ImportBatch(
    id: 'impor-kas-bulan-ini',
    fileName: 'kas-${namaBulan(0).toLowerCase()}.xlsx',
    createdBy: 'meiske',
    createdAt: a.jam(h(15), 16, 40),
  );
  k.importBatches.add(batch);
  final pln = h(4);
  for (final (i, (raw, d, akun, jenis, jumlah, ma)) in [
    (
      '${yy(h(2))} · Persembahan Mgg · 3.100.000',
      h(2),
      'kas',
      TransactionType.income,
      3100000,
      '1.3.53.07.00',
    ),
    (
      '${yy(pln)} · Bayar PLN · -1250000',
      pln,
      'bni',
      TransactionType.expense,
      1250000,
      '5.01.02.00',
    ),
    (
      '${pln.hari} ${singkat[bln - 1]} · PLN ${singkat[bln - 1].toLowerCase()} '
          '· 1.250.000,-',
      pln,
      'bni',
      TransactionType.expense,
      1250000,
      '5.01.02.00',
    ),
    (
      '${yy(h(8))} · Honor pemusik · 650rb',
      h(8),
      'kas',
      TransactionType.expense,
      650000,
      null,
    ),
    // A day the month does not have: "tanggal tidak terbaca".
    (
      '${hariTerakhir + 1}/${bln.toString().padLeft(2, '0')}/'
          '${(thn % 100).toString().padLeft(2, '0')} · ATK · 85.000',
      null,
      'kas',
      TransactionType.expense,
      85000,
      '5.02.01.00',
    ),
  ].indexed) {
    k.stagedRows.add(
      StagedRow(
        id: 'baris-${i + 1}',
        batchId: batch.id,
        ordinal: i + 1,
        raw: raw,
        date: d,
        accountId: akun,
        amount: jumlah,
        type: jenis,
        masterCode: ma,
      ),
    );
  }
}
