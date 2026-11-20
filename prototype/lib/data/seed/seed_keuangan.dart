import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import 'jangkar.dart';
import 'seed_store.dart';

/// The finance seed (README 5.1, 5.5, 5.6, 5.7; mock-data 2.4–2.9): Kas/Bank,
/// peruntukan, Lingkup, Mata Anggaran versions, the opening batch, the
/// invented M−2 rows, every M−1 and M0 row and draft M2 owns, the DP7
/// numbers, the voucher walk, the periods, the second-checker rule and the
/// AI spend. Rows carry their drawn number as `seedKey` ('0143'); cases,
/// evidence, approvals and month-end records are added by the M3/M4 seed
/// files, which find rows with `TabelKeuangan.bySeedKey` and the case ids
/// already on the parts (um1–um4, um-hut, tt-okt, tt1, pb2).
void seedKeuangan(SeedStore store, Jangkar a) {
  final k = store.keuangan;
  final cut = a.bln(-2, 15);

  // ---------- Kas/Bank (mock-data 2.4; DP16) ----------
  k.accounts.addAll([
    Account(
      id: 'kas',
      name: 'Kas',
      shortName: 'Kas',
      type: AccountType.cash,
      activeFrom: cut,
    ),
    Account(
      id: 'bni',
      name: 'Bank BNI ··4821',
      shortName: 'Bank BNI',
      type: AccountType.bank,
      institution: 'BNI',
      activeFrom: cut,
    ),
    Account(
      id: 'bsg',
      name: 'Bank SulutGo ··1107',
      shortName: 'Bank SulutGo',
      type: AccountType.bank,
      institution: 'Bank SulutGo',
      activeFrom: cut,
    ),
    // Never used: deactivated at the end of M−1 ("Nonaktif sejak {M0}").
    Account(
      id: 'hut',
      name: 'Kas Panitia HUT',
      shortName: 'Kas Panitia HUT',
      type: AccountType.cash,
      activeFrom: cut,
      activeTo: a.akhirBln(-1),
      deactivationReason: 'Panitia HUT Jemaat selesai',
      operatedByScopeId: 'panitia-hut',
    ),
    Account(
      id: 'kol7',
      name: 'Kas Kolom 7',
      shortName: 'Kas Kolom 7',
      type: AccountType.cash,
      activeFrom: cut,
      operatedByScopeId: 'kolom-7',
    ),
  ]);

  // ---------- Peruntukan (DP37 preparers) ----------
  k.funds.addAll([
    Fund(
      id: 'umum',
      name: 'Umum Jemaat',
      ownerScopeId: 'jemaat',
      activeFrom: cut,
    ),
    Fund(
      id: 'diak',
      name: 'Diakonia',
      ownerScopeId: 'komisi-diakonia',
      activeFrom: cut,
      preparerPersonId: 'olga',
    ),
    Fund(
      id: 'bang',
      name: 'Pembangunan',
      ownerScopeId: 'jemaat',
      activeFrom: cut,
      preparerPersonId: 'rivo',
    ),
    Fund(
      id: 'kol7',
      name: 'Kolom 7',
      ownerScopeId: 'kolom-7',
      activeFrom: cut,
      preparerPersonId: 'deasy',
    ),
    // DP27: no rows, a computed balance of Rp0.
    Fund(
      id: 'natal',
      name: 'Panitia Natal',
      ownerScopeId: 'panitia-natal',
      activeFrom: cut,
    ),
  ]);

  // ---------- Lingkup (DP12: five) ----------
  for (final s in const [
    'jemaat',
    'kolom-3',
    'bipra-pemuda',
    'komisi-diakonia',
    'panitia-natal',
  ]) {
    k.lingkup.add(LingkupLink(id: 'lingkup-$s', scopeId: s, activeFrom: cut));
  }

  // ---------- Mata Anggaran (mock-data 2.5, DP13) ----------
  final kode = '${cut.tahun}.1';
  final (tahunDepan, _) = a.bulan(1);
  final kodeDraf = tahunDepan == cut.tahun ? '${cut.tahun}.2' : '$tahunDepan.1';
  const o = AllowedEffect.owned;
  // (code, name, heading?, allowed effect)
  const pendapatan = [
    ('1.3.53.00.00', 'PERSEMBAHAN', true, o),
    ('1.3.53.07.00', 'Persembahan Ibadah Minggu', false, o),
    ('1.3.53.09.00', 'Persembahan syukur', false, o),
    ('1.3.55.01.00', 'Persembahan Diakonia', false, o),
    ('1.4.10.00.00', 'SUMBANGAN', true, o),
    ('1.4.10.02.00', 'Sumbangan donatur', false, AllowedEffect.both),
    ('1.4.10.03.00', 'Sumbangan natura', false, o),
    (
      '2.1.01.02.00',
      'DANA TRANSIT Sentralisasi Sinode',
      false,
      AllowedEffect.custody,
    ),
  ];
  const belanja = [
    ('5.00.00.00', 'BELANJA OPERASIONAL', true, o),
    ('5.01.02.00', 'Listrik, air dan telepon', false, o),
    ('5.02.01.00', 'Alat tulis dan fotokopi', false, o),
    ('5.03.03.00', 'Biaya administrasi bank', false, o),
    ('5.04.01.00', 'Konsumsi rapat', false, o),
    ('5.05.02.00', 'Sewa peralatan', false, o),
    ('5.07.01.00', 'Honorarium pelayan', false, o),
    ('5.08.02.00', 'Pemeliharaan gedung', false, o),
    // Invented (no board draws a transport row): advances and claims for
    // travel and fuel need one.
    ('5.09.01.00', 'Transportasi dan perjalanan dinas', false, o),
    ('4.00.00.00', 'BELANJA PELAYANAN', true, o),
    ('4.03.03.00', 'Diakonia duka', false, o),
    ('4.03.04.00', 'Diakonia sakit', false, o),
  ];
  void versi(
    MasterKind jenis,
    String kodeVersi,
    MasterVersionStatus st,
    Tanggal berlaku,
    List<(String, String, bool, AllowedEffect)> baris,
    DateTime dibuat,
  ) {
    final id = '${jenis.name}-$kodeVersi';
    final terbit = st == MasterVersionStatus.published;
    k.masterVersions.add(
      MasterVersion(
        id: id,
        kind: jenis,
        code: kodeVersi,
        status: st,
        effectiveFrom: berlaku,
        createdBy: 'meiske',
        createdAt: dibuat,
        reviewedBy: terbit ? 'jefry' : null,
        reviewedAt: terbit ? dibuat : null,
        publishedBy: terbit ? 'meiske' : null,
        publishedAt: terbit ? dibuat : null,
      ),
    );
    String? judul;
    for (final (i, (c, nama, kepala, boleh)) in baris.indexed) {
      if (kepala) judul = c;
      // A row sits under the last heading of its own first digit.
      final induk = !kepala && judul != null && c[0] == judul[0] ? judul : null;
      k.masterRows.add(
        MasterRow(
          versionId: id,
          code: c,
          name: nama,
          order: i + 1,
          parentCode: induk,
          level: induk == null ? 1 : 2,
          postable: !kepala,
          allowedEffect: boleh,
        ),
      );
    }
  }

  final dibuatVersi = a.jam(a.bln(-2, 14), 9, 0);
  versi(
    MasterKind.pendapatan,
    kode,
    MasterVersionStatus.published,
    a.bln(-2, 1),
    pendapatan,
    dibuatVersi,
  );
  versi(
    MasterKind.belanja,
    kode,
    MasterVersionStatus.published,
    a.bln(-2, 1),
    belanja,
    dibuatVersi,
  );
  // The draft from M+1: 2 new rows, 1 renamed (computed on the boards).
  final dibuatDraf = a.jam(a.hariCerita(12), 10, 0);
  versi(
    MasterKind.pendapatan,
    kodeDraf,
    MasterVersionStatus.draft,
    a.bln(1, 1),
    pendapatan,
    dibuatDraf,
  );
  versi(MasterKind.belanja, kodeDraf, MasterVersionStatus.draft, a.bln(1, 1), [
    for (final r in belanja)
      if (r.$1 == '4.03.03.00')
        (r.$1, 'Diakonia duka dan sakit', r.$3, r.$4)
      else
        r,
    (
      '5.06.01.00',
      'Internet dan langganan aplikasi',
      false,
      AllowedEffect.unset,
    ),
    // mock-data 2.5 (WebMataAnggaran): on the Belanja tab, the remittance
    // row DM 4.2 asks for.
    (
      '2.2.01.02.00',
      'DANA TRANSIT Penyaluran Sentralisasi Sinode',
      false,
      AllowedEffect.custody,
    ),
  ], dibuatDraf);

  // ---------- Rule (D24) ----------
  k.ruleValues.add(
    RuleValue(
      id: 'aturan-pemeriksa-kedua',
      rule: FinanceRule.secondChecker,
      on: true,
      effectiveFrom: cut,
      setBy: 'meiske',
      setAt: a.jam(cut, 9, 30),
    ),
  );

  // ---------- Rows ----------
  /// A story date of M0 drawn on a Sunday, remembering its story day so
  /// `jam` keeps story order when it lands on today.
  Tanggal minggu(int kLalu, int cerita) =>
      TanggalCerita.dari(a.mingguLalu(kLalu), cerita);

  DateTime pukul(Tanggal d, int menit) =>
      a.jam(d, (menit.clamp(0, 1439)) ~/ 60, menit.clamp(0, 1439) % 60);

  const um = TransactionType.advanceIssue;
  const plg = TransactionType.advanceReturn;
  const pj = TransactionType.advanceSpending;
  const pdp = TransactionType.income;
  const blj = TransactionType.expense;
  const pindah = TransactionType.accountTransfer;
  const titip = TransactionType.transitCollection;
  const salur = TransactionType.transitRemittance;

  /// A posted row: recorded by [oleh], checked by Jefry, booked at [jam]
  /// (created 30 and checked 10 minutes before), number given by the walk.
  Transaction buku(
    String kunci,
    TransactionType jenis,
    Tanggal d,
    String uraian,
    List<Allocation> bagian, {
    String? akun,
    String? keAkun,
    (int, int) jam = (10, 0),
    String? pihak,
    String? asal,
    String oleh = 'meiske',
    String? unit,
    bool setuju = false,
  }) {
    final m = jam.$1 * 60 + jam.$2;
    final t = Transaction(
      id: kunci == 'opn' ? 'opn' : 'bku-$kunci',
      seedKey: kunci,
      type: jenis,
      status: TransactionStatus.finalized,
      effectiveDate: d,
      description: uraian,
      allocations: bagian,
      accountId: akun,
      toAccountId: keAkun,
      payee: pihak,
      sourceRef: asal,
      approvalMode: setuju ? ApprovalMode.external : ApprovalMode.notRequired,
      approvalRule: setuju ? 'Belanja Rp2.000.000 ke atas' : null,
      unitScopeId: unit,
      createdBy: oleh,
      createdAt: pukul(d, m - 30),
      reviewedBy: 'jefry',
      reviewedAt: pukul(d, m - 10),
      finalizedBy: oleh,
      finalizedAt: pukul(d, m),
      series: jenis == TransactionType.opening
          ? VoucherSeries.opn
          : VoucherSeries.bku,
    );
    k.transactions.add(t);
    return t;
  }

  Allocation p(
    int jumlah,
    String? ma, {
    String dana = 'umum',
    String lingkup = 'jemaat',
    String? akun,
    TransactionType? jenis,
    String? kasus,
    String? pihak,
    String? label,
  }) => Allocation(
    amount: jumlah,
    type: jenis,
    accountId: akun,
    fundId: dana,
    scopeId: lingkup,
    partyId: pihak,
    masterCode: ma,
    caseId: kasus,
    label: label,
  );

  // ---------- Opening OPN-{cutover year}-0001 (mock-data 2.4, DP16) ----------
  final opn = buku(
    'opn',
    TransactionType.opening,
    cut,
    'Saldo awal pencatatan',
    [
      p(2000000, null, akun: 'kas'),
      p(700000, null, akun: 'kas', dana: 'diak'),
      p(500000, null, akun: 'kas', dana: 'bang'),
      p(19350000, null, akun: 'bni'),
      p(2350000, null, akun: 'bni', dana: 'diak'),
      p(2300000, null, akun: 'bni', dana: 'bang'),
      p(5100000, null, akun: 'bsg'),
      p(920000, null, akun: 'kol7', dana: 'kol7', lingkup: 'kolom-7'),
    ],
    jam: (10, 15),
  );
  final sebelum = a.bln(-2, 14).toString();
  k.opening = OpeningBatch(
    cutoverDate: cut,
    transactionId: opn.id,
    recordedBy: 'meiske',
    recordedAt: opn.finalizedAt!,
    sources: {
      'kas': 'Sumber: berita acara hitung kas $sebelum',
      'bni': 'Sumber: rekening koran $sebelum',
      'bsg': 'Sumber: rekening koran $sebelum',
      'kol7': 'Sumber: berita acara hitung kas Kolom 7 $sebelum',
    },
  );

  // ---------- M−2: invented rows (D10) around the drawn 0019 and 0031 ----------
  // Kas +870.000, BNI +4.565.000, SulutGo −1.485.000: Rp32.300.000 at the
  // cutover to Rp36.250.000 on day 1 of M−1 (README 5.1). Keys only order
  // the walk.
  Tanggal s(int d) => a.bln(-2, d);
  buku('0004', pdp, s(16), 'Persembahan syukur', [
    p(800000, '1.3.53.09.00'),
  ], akun: 'kas');
  buku('0007', pdp, s(16), 'Sumbangan donatur', [
    p(1500000, '1.4.10.02.00'),
  ], akun: 'bni');
  buku('0010', um, s(17), 'Uang Muka diberikan · Panitia HUT Jemaat', [
    p(1000000, null, kasus: 'um-hut'),
  ], akun: 'kas');
  buku(
    '0014',
    blj,
    s(18),
    'Listrik PLN',
    [p(985000, '5.01.02.00')],
    akun: 'bsg',
    pihak: 'PLN',
  );
  buku('0019', pdp, a.minggu(-2, 3), 'Persembahan Ibadah Minggu', [
    p(2900000, '1.3.53.07.00'),
  ], akun: 'kas');
  buku('0021', blj, s(19), 'Konsumsi rapat majelis', [
    p(450000, '5.04.01.00'),
  ], akun: 'kas');
  buku(
    '0024',
    blj,
    s(20),
    'Fotokopi warta jemaat',
    [p(125000, '5.02.01.00')],
    akun: 'kas',
    pihak: 'Toko Sinar',
  );
  buku('0026', blj, s(20), 'Telepon dan internet kantor', [
    p(520000, '5.01.02.00'),
  ], akun: 'bsg');
  buku(
    '0029',
    pindah,
    s(21),
    'Setoran ke bank: ke Bank BNI ··4821',
    [p(4000000, null)],
    akun: 'kas',
    keAkun: 'bni',
  );
  buku(
    '0031',
    blj,
    s(22),
    'Alat tulis Toko Sinar',
    [p(85000, '5.02.01.00')],
    akun: 'kas',
    pihak: 'Toko Sinar',
  );
  buku('0034', pdp, s(23), 'Persembahan syukur', [
    p(1200000, '1.3.53.09.00'),
  ], akun: 'bni');
  buku('0040', blj, s(24), 'Perbaikan pintu samping', [
    p(300000, '5.08.02.00'),
  ], akun: 'kas');
  buku('0047', blj, s(25), 'Honorarium pelayan', [
    p(1820000, '5.07.01.00'),
  ], akun: 'bni');
  buku('0055', pdp, s(26), 'Persembahan syukur', [
    p(480000, '1.3.53.09.00'),
  ], akun: 'kas');
  buku('0062', pdp, a.minggu(-2, 4), 'Persembahan Ibadah Minggu', [
    p(2650000, '1.3.53.07.00'),
  ], akun: 'kas');
  buku('0068', blj, s(27), 'Sewa tenda ibadah syukur', [
    p(300000, '5.05.02.00'),
  ], akun: 'bni');
  buku('0075', pj, s(28), 'Pertanggungjawaban uang muka · Panitia HUT Jemaat', [
    p(650000, '5.04.01.00', kasus: 'um-hut'),
  ]);
  buku('0088', blj, a.akhirBln(-2), 'Biaya administrasi bank', [
    p(15000, '5.03.03.00'),
  ], akun: 'bni');
  buku('0094', pdp, a.akhirBln(-2), 'Sumbangan donatur', [
    p(20000, '1.4.10.02.00'),
  ], akun: 'bsg');

  // ---------- M−1: the F02 rows (mock-data 2.7) but 0133 (DP8) ----------
  Tanggal o1(int d) => a.bln(-1, d);
  buku('0098', pdp, a.minggu(-1, 1), 'Persembahan Ibadah Minggu dan Diakonia', [
    p(3200000, '1.3.53.07.00', akun: 'kas'),
    p(
      950000,
      '1.3.55.01.00',
      akun: 'bni',
      dana: 'diak',
      lingkup: 'komisi-diakonia',
    ),
  ]);
  Allocation titipan(int n) =>
      p(n, '2.1.01.02.00', kasus: 'tt-okt', pihak: 'party-sinode');
  buku('0099', titip, a.minggu(-1, 1), 'Titipan untuk: Sinode · Sentralisasi', [
    titipan(600000),
  ], akun: 'kas');
  buku('0100', blj, o1(5), 'Honorarium pelayan', [
    p(1820000, '5.07.01.00'),
  ], akun: 'bni');
  buku(
    '0101',
    blj,
    o1(6),
    'Toko Sinar: listrik dan alat tulis, satu pembayaran',
    [p(1000000, '5.01.02.00'), p(250000, '5.02.01.00')],
    akun: 'bni',
    pihak: 'Toko Sinar',
  );
  buku(
    '0102',
    pindah,
    o1(6),
    'Setoran ke bank: ke Bank BNI ··4821',
    [p(5000000, null)],
    akun: 'kas',
    keAkun: 'bni',
  );
  buku('0103', um, o1(7), 'Uang Muka diberikan · Pnt. Jefry Wowor', [
    p(400000, null, kasus: 'um3', pihak: 'party-jefry'),
  ], akun: 'kas');
  buku(
    '0104',
    pindah,
    o1(8),
    'Setoran ke bank: ke Bank SulutGo ··1107',
    [p(1500000, null)],
    akun: 'kas',
    keAkun: 'bsg',
  );
  final b105 = buku('0105', blj, o1(9), 'Konsumsi rapat majelis', [
    p(750000, '5.02.01.00'),
  ], akun: 'kas');
  buku(
    '0106',
    plg,
    o1(10),
    'Pengembalian sisa uang muka · Panitia HUT Jemaat',
    [p(350000, null, kasus: 'um-hut')],
    akun: 'kas',
  );
  buku('0107', pdp, a.minggu(-1, 2), 'Persembahan Ibadah Minggu', [
    p(2650000, '1.3.53.07.00'),
  ], akun: 'kas');
  buku('0108', titip, a.minggu(-1, 2), 'Titipan untuk: Sinode · Sentralisasi', [
    titipan(600000),
  ], akun: 'kas');
  final b109 = buku('0109', TransactionType.reversal, o1(12), 'Pembalikan', [
    p(750000, '5.02.01.00', jenis: blj, akun: 'kas'),
  ], akun: 'kas');
  final b110 = buku('0110', blj, o1(12), 'Konsumsi rapat majelis', [
    p(750000, '5.04.01.00'),
  ], akun: 'kas');
  b109.reversalOf = b105.id;
  b105.reversedBy = b109.id;
  b110.correctionOf = b105.id;
  b105.correctedBy = b110.id;
  buku('0114', pdp, a.minggu(-1, 3), 'Persembahan Ibadah Minggu', [
    p(2400000, '1.3.53.07.00'),
  ], akun: 'kas');
  buku('0115', pdp, o1(18), 'Sumbangan donatur', [
    p(700000, '1.4.10.02.00'),
  ], akun: 'bni');
  buku('0117', titip, a.minggu(-1, 3), 'Titipan untuk: Sinode · Sentralisasi', [
    titipan(600000),
  ], akun: 'kas');
  buku('0112', um, o1(20), 'Uang Muka diberikan · Sdri. Natalia Rumengan', [
    p(
      800000,
      null,
      kasus: 'um2',
      pihak: 'party-natalia',
      lingkup: 'bipra-pemuda',
    ),
  ], akun: 'kas');
  buku('0113', pdp, o1(20), 'Persembahan syukur', [
    p(1220000, '1.3.53.09.00'),
  ], akun: 'kas');
  buku(
    '0116',
    blj,
    o1(22),
    'Pemeliharaan atap gedung',
    [p(5500000, '5.08.02.00')],
    akun: 'bni',
    setuju: true,
  );
  buku('0119', um, o1(25), 'Uang Muka diberikan · Ibu Selvie Kalalo', [
    p(300000, null, kasus: 'um4', pihak: 'party-selvie'),
  ], akun: 'kas');
  buku('0123', pdp, a.minggu(-1, 4), 'Persembahan Ibadah Minggu', [
    p(2700000, '1.3.53.07.00'),
  ], akun: 'kas');
  buku('0125', titip, a.minggu(-1, 4), 'Titipan untuk: Sinode · Sentralisasi', [
    titipan(600000),
  ], akun: 'kas');
  buku('0120', blj, o1(26), 'Honorarium pelayan', [
    p(1820000, '5.07.01.00'),
  ], akun: 'bni');
  buku(
    '0130',
    pindah,
    o1(26),
    'Setoran ke bank: ke Bank BNI ··4821',
    [p(2690000, null)],
    akun: 'kas',
    keAkun: 'bni',
  );
  buku('0118', pdp, o1(27), 'Persembahan syukur', [
    p(500000, '1.3.53.09.00'),
  ], akun: 'bni');
  // Its posting time matters to M4: it invalidates a Diakonia readiness
  // attested before it (README 5.6).
  buku(
    '0122',
    blj,
    o1(27),
    'Diakonia sakit',
    [p(300000, '4.03.04.00', dana: 'diak', lingkup: 'komisi-diakonia')],
    akun: 'kas',
    jam: (15, 30),
  );
  buku('0121', pdp, o1(28), 'Sumbangan donatur', [
    p(500000, '1.4.10.02.00', pihak: 'party-ibu-runtu'),
  ], akun: 'bni');
  buku(
    '0127',
    pindah,
    o1(30),
    'Pindah antar Kas/Bank: Bank BNI ke Kas',
    [p(2000000, null)],
    akun: 'bni',
    keAkun: 'kas',
  );
  buku('0128', salur, o1(30), 'Penyaluran · Titipan untuk: Sinode', [
    titipan(2400000),
  ], akun: 'bni');
  // In transit at the month end (mock-data 2.11).
  buku(
    '0131',
    pindah,
    a.akhirBln(-1),
    'Setoran ke bank: ke Bank BNI ··4821',
    [p(500000, null)],
    akun: 'kas',
    keAkun: 'bni',
  );

  // ---------- M0 (mock-data 2.9; DP3, DP5, DP15, DP22, DP32) ----------
  Tanggal h(int d) => a.hariCerita(d);
  final bulanIni = bulanTahun(a.bulan(0).$1, a.bulan(0).$2).split(' ').first;
  buku('0129', um, h(1), 'Uang Muka diberikan · Panitia Natal', [
    p(
      1500000,
      null,
      kasus: 'um1',
      pihak: 'party-rivo',
      lingkup: 'panitia-natal',
    ),
  ], akun: 'kas');
  buku(
    '0132',
    pdp,
    minggu(3, 1),
    'Sampul syukur, Ibadah Minggu Pagi',
    [p(100000, '1.3.53.09.00', pihak: 'party-novita')],
    akun: 'kas',
    jam: (12, 0),
  );
  // tt1 (mock-data 2.10): Rp2.400.000 "dari 4 persembahan · disimpan di Bank
  // BNI", so 0136's Rp1.000.000 leaves Rp1.400.000. No board draws these
  // rows; keys between the drawn numbers keep the walk in posting order.
  void titipanSinode(String kunci, Tanggal d, String ibadah, int menit) => buku(
    kunci,
    titip,
    d,
    'Titipan untuk: Sinode · Sentralisasi $bulanIni',
    [
      p(
        600000,
        '2.1.01.02.00',
        kasus: 'tt1',
        pihak: 'party-sinode',
        label: ibadah,
      ),
    ],
    akun: 'bni',
    jam: (12, menit),
  );
  titipanSinode('0132a', minggu(3, 1), 'Ibadah Minggu Pagi', 10);
  titipanSinode('0132b', minggu(3, 1), 'Ibadah Minggu Sore', 15);
  buku(
    '0149',
    pj,
    h(3),
    'Pertanggungjawaban uang muka · Perjalanan dinas Wilayah',
    [p(400000, '5.09.01.00', kasus: 'um3', pihak: 'party-jefry')],
  );
  buku(
    '0134',
    TransactionType.claimPayment,
    h(5),
    'Penggantian biaya dibayar · Bensin antar jemput',
    [p(120000, '5.09.01.00', kasus: 'pb2', pihak: 'party-rivo')],
    akun: 'kas',
  );
  buku('0150', pj, h(5), 'Pertanggungjawaban uang muka · Retret Pemuda', [
    p(
      300000,
      '5.04.01.00',
      kasus: 'um2',
      pihak: 'party-natalia',
      lingkup: 'bipra-pemuda',
    ),
  ]);
  buku('0135', pdp, h(6), 'Persembahan Diakonia', [
    p(1200000, '1.3.55.01.00', dana: 'diak', lingkup: 'komisi-diakonia'),
  ], akun: 'bni');
  buku('0136', salur, h(7), 'Penyaluran · Sentralisasi $bulanIni (Sinode)', [
    p(1000000, '2.1.01.02.00', kasus: 'tt1', pihak: 'party-sinode'),
  ], akun: 'bni');
  buku(
    '0137',
    blj,
    h(8),
    'Renovasi pastori, termin 1',
    [p(4500000, '5.08.02.00')],
    akun: 'bni',
    asal: 'KW-0412',
    setuju: true,
  );
  buku('0138', pj, h(8), 'Pertanggungjawaban uang muka · Panitia Natal', [
    p(
      850000,
      '5.05.02.00',
      kasus: 'um1',
      pihak: 'party-rivo',
      lingkup: 'panitia-natal',
    ),
  ]);
  titipanSinode('0138a', minggu(2, 8), 'Ibadah Minggu Pagi', 10);
  final b139 = buku(
    '0139',
    blj,
    h(9),
    'Konsumsi rapat majelis',
    [p(750000, '5.02.01.00')],
    akun: 'kas',
    jam: (14, 12),
  );
  buku('0140', blj, h(10), 'Bensin operasional', [
    p(200000, '5.09.01.00'),
  ], akun: 'kas');
  buku('0141', blj, h(10), 'Diakonia duka', [
    p(500000, '4.03.03.00', dana: 'diak', lingkup: 'komisi-diakonia'),
  ], akun: 'bni');
  buku(
    '0142',
    pindah,
    h(11),
    'Pindah antar Kas/Bank: Kas ke Bank BNI',
    [p(1000000, null)],
    akun: 'kas',
    keAkun: 'bni',
  );
  // The missing supporting document (F12): no evidence is ever seeded for it.
  buku(
    '0143',
    blj,
    h(11),
    'Sewa sound system',
    [p(600000, '5.05.02.00', lingkup: 'panitia-natal')],
    akun: 'kas',
    pihak: 'CV NADA PRIMA',
    jam: (16, 5),
  );
  final b144 = buku(
    '0144',
    TransactionType.reversal,
    h(12),
    'Pembalikan',
    [p(750000, '5.02.01.00', jenis: blj, akun: 'kas')],
    akun: 'kas',
    jam: (9, 31),
  );
  final b145 = buku(
    '0145',
    blj,
    h(12),
    'Konsumsi rapat majelis',
    [p(750000, '5.04.01.00')],
    akun: 'kas',
    jam: (9, 40),
  );
  b144.reversalOf = b139.id;
  b139.reversedBy = b144.id;
  b145.correctionOf = b139.id;
  b139.correctedBy = b145.id;
  buku(
    '0151',
    pdp,
    h(12),
    'Persembahan Ibadah Kolom',
    [p(320000, '1.3.53.07.00', dana: 'kol7', lingkup: 'kolom-7')],
    akun: 'kol7',
    oleh: 'deasy',
    unit: 'kolom-7',
    jam: (20, 10),
  );
  buku(
    '0146',
    pdp,
    minggu(1, 15),
    'Persembahan Ibadah Minggu',
    [p(3450000, '1.3.53.07.00')],
    akun: 'kas',
    jam: (12, 20),
  );
  titipanSinode('0146a', minggu(1, 15), 'Ibadah Minggu Pagi', 25);

  // ---------- DP7: numbers given, bookings never finished ----------
  for (final (kunci, saat) in [
    ('0111', a.jam(a.bln(-1, 14), 10, 20)),
    ('0124', a.jam(a.bln(-1, 29), 16, 5)),
    ('0126', a.jam(a.bln(-1, 30), 9, 12)),
    ('0133', a.jam(a.akhirBln(-1), 15, 40)),
    ('0147', a.jam(h(14), 10, 42)),
    ('0148', a.jam(minggu(1, 15), 12, 30)),
  ]) {
    k.unfinishedVouchers.add(
      UnfinishedVoucher(
        id: 'nomor-$kunci',
        allocatedAt: saat,
        seedKey: kunci,
        note:
            'Nomor diberikan, pembukuannya tidak selesai. '
            'Nomor ini tidak dipakai ulang.',
      ),
    );
  }

  // ---------- The voucher walk (README 5.5, DP38) ----------
  k.numberSeedVouchers(store.nextVoucher);
  b109.description = 'Pembalikan ${b105.voucher}';
  b144.description = 'Pembalikan ${b139.voucher}';

  // ---------- Drafts (DP3, DP14, DP17) ----------
  Transaction draf(
    String id,
    Tanggal d,
    String uraian,
    Allocation bagian,
    String akun,
    DateTime dibuat, {
    String oleh = 'meiske',
    String? unit,
  }) {
    final t = Transaction(
      id: id,
      type: blj,
      status: TransactionStatus.draft,
      effectiveDate: d,
      description: uraian,
      allocations: [bagian],
      accountId: akun,
      unitScopeId: unit,
      createdBy: oleh,
      createdAt: dibuat,
    );
    k.transactions.add(t);
    return t;
  }

  // DP17 a: no Mata Anggaran; with DP3 the "2 draf · Rp800.000".
  draf(
    'draf-honor-pemusik',
    h(8),
    'Honor pemusik',
    p(650000, null),
    'bni',
    a.jam(h(8), 15, 30),
  );
  // DP3.
  draf(
    'draf-fotokopi-warta',
    h(14),
    'Fotokopi warta jemaat',
    p(150000, '5.02.01.00'),
    'kas',
    a.jam(h(14), 9, 15),
  );
  // DP17 b: dated in the closed M−2, made in M0 after the close (RD09).
  draf(
    'draf-honor-pemusik-tutup',
    a.bln(-2, 28),
    'Honor pemusik',
    p(650000, '5.07.01.00'),
    'bni',
    a.jam(h(15), 16, 10),
  );
  // DP14: the Kolom 7 drafts. On a church account: blocks M−1 until cleared.
  draf(
    'draf-kolom7-konsumsi',
    a.bln(-1, 28),
    'Konsumsi ibadah Kolom',
    p(150000, '5.04.01.00', dana: 'kol7', lingkup: 'kolom-7'),
    'bni',
    a.jam(a.bln(-1, 28), 19, 40),
    oleh: 'deasy',
    unit: 'kolom-7',
  );
  // From the Diakonia fund: refused for the unit.
  draf(
    'draf-kolom7-duka',
    h(13),
    'Bantuan duka',
    p(200000, '4.03.03.00', dana: 'diak', lingkup: 'kolom-7'),
    'kol7',
    a.jam(h(13), 18, 20),
    oleh: 'deasy',
    unit: 'kolom-7',
  );

  // Recorded twice, cancelled by the Bendahara (WebTransaksi): no number.
  draf(
      'batal-bunga-altar',
      h(5),
      'Pembelian bunga altar',
      p(200000, '5.02.01.00'),
      'kas',
      a.jam(h(5), 17, 0),
    )
    ..status = TransactionStatus.cancelled
    ..cancelledBy = 'meiske'
    ..cancelledAt = a.jam(h(6), 8, 2)
    ..cancelReason = 'Tercatat dua kali';

  // ---------- Periods (README 5.6) ----------
  Period bulan(int m, {Tanggal? mulai}) {
    final (y, b) = a.bulan(m);
    return Period(
      year: y,
      month: b,
      start: mulai ?? a.bln(m, 1),
      end: a.akhirBln(m),
    );
  }

  final tutup = bulan(-2, mulai: cut)
    ..status = PeriodStatus.closed
    ..closedBy = 'meiske'
    ..closedAt = a.jam(a.bln(-1, 5), 19, 2);
  tutup.snapshotId =
      'SNP-${tutup.year}-${tutup.month.toString().padLeft(2, '0')}-01';
  k.periods.addAll([tutup, bulan(-1), bulan(0), bulan(1)]);

  // ---------- Audit (DP6): who recorded, checked, booked, cancelled, closed ----------
  // The lines the repositories would have written (the action keys of
  // MemoryTransactionRepository); Riwayat and "oleh" read them.
  const jabatanDari = {
    'meiske': 'bendahara-jemaat',
    'jefry': 'pemeriksa-kedua',
    'deasy': 'bendahara-kolom-7',
  };
  void jejak(
    DateTime saat,
    String orang,
    String aksi,
    String ringkas,
    RecordRef ref, {
    String? alasan,
  }) {
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
        reason: alasan,
        ref: ref,
      ),
    );
  }

  for (final t in k.transactions) {
    final ref = RecordRef('transaction', t.id);
    jejak(
      t.createdAt,
      t.createdBy,
      'finance.txn.draft',
      'Draf dicatat: ${t.description}',
      ref,
    );
    if (t.reviewedAt != null && t.reviewedBy != t.finalizedBy) {
      jejak(
        t.reviewedAt!,
        t.reviewedBy!,
        'finance.txn.review',
        'Ditandai sudah diperiksa: ${t.description}',
        ref,
      );
    }
    if (t.finalizedAt != null) {
      jejak(
        t.finalizedAt!,
        t.finalizedBy!,
        'finance.txn.finalize',
        'Dibukukan ${t.voucher} · ${t.description}',
        ref,
      );
    }
    if (t.cancelledAt != null) {
      jejak(
        t.cancelledAt!,
        t.cancelledBy!,
        'finance.txn.cancel',
        'Dibatalkan: ${t.description}',
        ref,
        alasan: t.cancelReason,
      );
    }
  }
  jejak(
    tutup.closedAt!,
    tutup.closedBy!,
    'finance.period.close',
    'Tutup buku ${bulanTahun(tutup.year, tutup.month)}',
    RecordRef('period', tutup.id),
  );

  // ---------- AI spend: 75 % of the cap this month (F3) ----------
  k.aiSpend[periodIdOf(a.bulan(0).$1, a.bulan(0).$2)] = k.aiCap * 3 ~/ 4;
}
