import '../../core/tanggal.dart';

/// The transaction types of DM 4.2 (the boards' `JenisTransaksi`). The sign
/// of each is in `posting.dart`.
enum TransactionType {
  /// Offering, donation, other owned receipt ('Pendapatan').
  income,

  /// Direct expense, own-church centralization ('Belanja').
  expense,

  /// Reimbursement paid ('Penggantian biaya dibayar'), on a claim case.
  claimPayment,

  /// 'Uang Muka diberikan', on an advance case.
  advanceIssue,

  /// Accepted advance spending ('Pertanggungjawaban uang muka').
  advanceSpending,

  /// 'Pengembalian sisa uang muka'.
  advanceReturn,

  /// 'Pindah antar Kas/Bank' and 'Setoran ke bank': same Fund.
  accountTransfer,

  /// 'Alih peruntukan': same Account, Fund ownership changes.
  fundTransfer,

  /// 'Titipan untuk: …' (held/transit collection), on a transit case.
  transitCollection,

  /// 'Penyaluran' (held/transit remittance), on a transit case.
  transitRemittance,

  /// 'Saldo awal pencatatan' (controlled opening, series OPN).
  opening,

  /// A supplier refund lowering Belanja (RD04, pending; F9).
  supplierRefund,

  /// A return to a donor lowering Pendapatan (RD04, pending; F9).
  donorReturn,

  /// 'Pembalikan': the exact opposite of [Transaction.reversalOf].
  reversal,
}

/// DM 5.1. REVERSED is derived: a finalized original whose
/// [Transaction.reversedBy] is set.
enum TransactionStatus { draft, reviewed, finalized, cancelled }

/// Voucher series (DM 3 PostedBatch, RD13): one counter per series per year.
enum VoucherSeries {
  bku('BKU'),
  opn('OPN'),
  adj('ADJ');

  const VoucherSeries(this.code);
  final String code;
}

/// 'BKU-{year}-{NNNN}'.
String voucherCode(VoucherSeries s, int year, int number) =>
    '${s.code}-$year-${number.toString().padLeft(4, '0')}';

/// DM 5.2: MVP approval modes. IN_APP is used by fund requests only.
enum ApprovalMode { notRequired, external, inApp }

/// One part of a transaction (DM 3 TransactionAllocation): its amount,
/// Fund, activity scope (Lingkup), party, Mata Anggaran row and case. A
/// split payment or a multi-part offering has several.
class Allocation {
  const Allocation({
    required this.amount,
    this.type,
    this.accountId,
    this.fundId,
    this.toFundId,
    this.scopeId,
    this.partyId,
    this.masterCode,
    this.masterVersionId,
    this.caseId,
    this.label,
  });

  /// Positive rupiah.
  final int amount;

  /// This part's posting type when it differs from the transaction's (the
  /// Titipan part of a Sunday offering is a transit collection).
  final TransactionType? type;

  /// This part's Kas/Bank when it differs from the transaction's (an
  /// offering's Tunai to Kas, Transfer to BNI).
  final String? accountId;
  final String? fundId;

  /// Fund transfer only: the target Fund.
  final String? toFundId;

  /// The Lingkup scope id.
  final String? scopeId;

  /// A core Party id ('party-sinode').
  final String? partyId;

  /// Mata Anggaran code and the version it resolves in.
  final String? masterCode;
  final String? masterVersionId;

  /// The advance, transit or claim case it moves.
  final String? caseId;

  /// The part's name on the board: 'Tunai', 'QRIS', 'Transfer bank'.
  final String? label;

  Allocation copyWith({
    int? amount,
    String? accountId,
    String? fundId,
    String? scopeId,
    String? masterCode,
    String? masterVersionId,
  }) => Allocation(
    amount: amount ?? this.amount,
    type: type,
    accountId: accountId ?? this.accountId,
    fundId: fundId ?? this.fundId,
    toFundId: toFundId,
    scopeId: scopeId ?? this.scopeId,
    partyId: partyId,
    masterCode: masterCode ?? this.masterCode,
    masterVersionId: masterVersionId ?? this.masterVersionId,
    caseId: caseId,
    label: label,
  );
}

/// A ledger transaction (DM 3 Transaction) through its lifecycle (DM 5.1).
/// Seed files build it directly; the app changes it only through
/// `TransactionRepository`.
class Transaction {
  Transaction({
    required this.id,
    required this.type,
    required this.status,
    required this.effectiveDate,
    required this.description,
    required this.allocations,
    required this.createdBy,
    required this.createdAt,
    this.accountId,
    this.toAccountId,
    this.payee,
    this.sourceRef,
    this.approvalMode = ApprovalMode.notRequired,
    this.approvalRule,
    bool? evidenceRequired,
    this.unitScopeId,
    this.reviewedBy,
    this.reviewedAt,
    this.reviewedRevision,
    this.finalizedBy,
    this.finalizedAt,
    this.cancelledBy,
    this.cancelledAt,
    this.cancelReason,
    this.series = VoucherSeries.bku,
    this.voucherYear,
    this.voucherNumber,
    this.reversalOf,
    this.reversedBy,
    this.correctionOf,
    this.correctedBy,
    this.refundOf,
    this.countedBy = const [],
    this.serviceId,
    this.importRowId,
    this.aiProposalId,
    this.seedKey,
    this.revision = 1,
  }) : evidenceRequired = evidenceRequired ?? evidenceByDefault(type);

  final String id;
  TransactionType type;
  TransactionStatus status;
  Tanggal effectiveDate;

  /// 'Uraian': 'Persembahan Ibadah Minggu'.
  String description;
  List<Allocation> allocations;

  /// The Kas/Bank; the source of a transfer.
  String? accountId;

  /// The destination Kas/Bank of an account transfer.
  String? toAccountId;

  /// 'Dibayar kepada' as typed when it is no Party: 'PLN', 'Toko Sinar'.
  String? payee;

  /// 'No. bukti asal': 'KW-0412'.
  String? sourceRef;

  /// The approval policy captured for it (DM 5.2) and its rule text
  /// ('transaksi rutin').
  ApprovalMode approvalMode;
  String? approvalRule;

  /// Whether a supporting document is required (DM 5.3).
  bool evidenceRequired;

  /// The unit scope whose treasurer recorded it ('kolom-7'): the church
  /// Bendahara clearing it notifies the unit (DL33).
  String? unitScopeId;

  final String createdBy;
  final DateTime createdAt;
  String? reviewedBy;
  DateTime? reviewedAt;

  /// The [revision] the review was given on.
  int? reviewedRevision;
  String? finalizedBy;
  DateTime? finalizedAt;
  String? cancelledBy;
  DateTime? cancelledAt;
  String? cancelReason;

  VoucherSeries series;
  int? voucherYear;
  int? voucherNumber;

  /// The original this reverses; the reversal that reversed this.
  String? reversalOf;
  String? reversedBy;

  /// The original this replaces; the replacement of this.
  String? correctionOf;
  String? correctedBy;

  /// The posted transaction this refunds or returns (D25, RD04).
  final String? refundOf;

  /// 'Petugas penghitung' of a counted offering (person ids).
  final List<String> countedBy;

  /// The service an offering was collected at (J3; PMP 6.1).
  final String? serviceId;
  String? importRowId;
  String? aiProposalId;

  /// The drawn voucher number ('0143'), a lookup key only (README 5.5).
  final String? seedKey;
  int revision;

  /// 'BKU-{year}-{NNNN}'; null before finalize ('Belum ada No. Bukti').
  String? get voucher => voucherNumber == null
      ? null
      : voucherCode(series, voucherYear!, voucherNumber!);

  bool get isDraft =>
      status == TransactionStatus.draft || status == TransactionStatus.reviewed;
  bool get isPosted => status == TransactionStatus.finalized;

  /// 'Dibalik': posted, and its reversal is posted.
  bool get isReversed => isPosted && reversedBy != null;

  /// The sum of the parts (positive).
  int get total => allocations.fold(0, (s, a) => s + a.amount);

  /// The part's posting type.
  TransactionType typeOf(Allocation a) => a.type ?? type;

  /// The part's Kas/Bank.
  String? accountOf(Allocation a) => a.accountId ?? accountId;

  /// A copy holding only the parts [keep] accepts, for a Fund-only viewer
  /// or a giver (README 3.5, J1): the voucher stays, the other parts are gone.
  Transaction slice(bool Function(Allocation a) keep) => Transaction(
    id: id,
    type: type,
    status: status,
    effectiveDate: effectiveDate,
    description: description,
    allocations: [
      for (final a in allocations)
        if (keep(a)) a,
    ],
    createdBy: createdBy,
    createdAt: createdAt,
    accountId: accountId,
    toAccountId: toAccountId,
    sourceRef: sourceRef,
    approvalMode: approvalMode,
    evidenceRequired: evidenceRequired,
    unitScopeId: unitScopeId,
    reviewedBy: reviewedBy,
    reviewedAt: reviewedAt,
    finalizedBy: finalizedBy,
    finalizedAt: finalizedAt,
    cancelledBy: cancelledBy,
    cancelledAt: cancelledAt,
    series: series,
    voucherYear: voucherYear,
    voucherNumber: voucherNumber,
    reversalOf: reversalOf,
    reversedBy: reversedBy,
    correctionOf: correctionOf,
    correctedBy: correctedBy,
    refundOf: refundOf,
    countedBy: countedBy,
    serviceId: serviceId,
    seedKey: seedKey,
    revision: revision,
  );
}

/// DM 5.3: required-by-default evidence for direct spending, paid
/// reimbursements, accepted advance spending and transit remittances.
bool evidenceByDefault(TransactionType t) => switch (t) {
  TransactionType.expense ||
  TransactionType.claimPayment ||
  TransactionType.advanceSpending ||
  TransactionType.transitRemittance => true,
  _ => false,
};

/// What `TransactionRepository.createDraft` takes. Several [allocations]
/// make a split.
class TransactionDraft {
  const TransactionDraft({
    required this.type,
    required this.effectiveDate,
    required this.description,
    required this.allocations,
    this.accountId,
    this.toAccountId,
    this.payee,
    this.sourceRef,
    this.approvalMode = ApprovalMode.notRequired,
    this.approvalRule,
    this.evidenceRequired,
    this.importRowId,
    this.aiProposalId,
    this.reversalOf,
    this.correctionOf,
    this.refundOf,
    this.countedBy = const [],
    this.serviceId,
  });

  final TransactionType type;
  final Tanggal effectiveDate;
  final String description;
  final List<Allocation> allocations;
  final String? accountId;
  final String? toAccountId;
  final String? payee;
  final String? sourceRef;
  final ApprovalMode approvalMode;
  final String? approvalRule;

  /// Null: the default of [type] (DM 5.3).
  final bool? evidenceRequired;
  final String? importRowId;
  final String? aiProposalId;

  /// Set by the repository's own reverse and correct.
  final String? reversalOf;
  final String? correctionOf;

  /// See [Transaction.refundOf], [Transaction.countedBy] and
  /// [Transaction.serviceId].
  final String? refundOf;
  final List<String> countedBy;
  final String? serviceId;
}

/// `TransactionRepository.editDraft`: only the fields given change. A
/// change to anything but [description], [payee] or [sourceRef] is material
/// and returns a reviewed draft to DRAFT (DM 5.1).
class TransactionPatch {
  const TransactionPatch({
    this.type,
    this.effectiveDate,
    this.description,
    this.allocations,
    this.accountId,
    this.toAccountId,
    this.payee,
    this.sourceRef,
  });

  final TransactionType? type;
  final Tanggal? effectiveDate;
  final String? description;
  final List<Allocation>? allocations;
  final String? accountId;
  final String? toAccountId;
  final String? payee;
  final String? sourceRef;

  bool get isMaterial =>
      type != null ||
      effectiveDate != null ||
      allocations != null ||
      accountId != null ||
      toAccountId != null;
}

/// `TransactionRepository.list` filter; every field narrows.
class TransactionFilter {
  const TransactionFilter({
    this.types,
    this.statuses,
    this.accountId,
    this.fundId,
    this.masterCode,
    this.text,
    this.from,
    this.to,
  });

  final Set<TransactionType>? types;
  final Set<TransactionStatus>? statuses;

  /// Any part on this Kas/Bank (either side of a transfer).
  final String? accountId;
  final String? fundId;
  final String? masterCode;

  /// Case-insensitive, in the description, payee, voucher or a code.
  final String? text;
  final Tanggal? from;
  final Tanggal? to;
}

/// One number of a voucher series (`voucherSeries`, `gaps`).
class VoucherEntry {
  const VoucherEntry({
    required this.series,
    required this.year,
    required this.number,
    this.transactionId,
    this.unfinished,
  });

  final VoucherSeries series;
  final int year;
  final int number;

  /// The posted transaction; null for a number allocated without one.
  final String? transactionId;
  final UnfinishedVoucher? unfinished;

  String get code => voucherCode(series, year, number);
  bool get isGap => transactionId == null;
}

/// A number given but never posted ("nomor diberikan, pembukuannya tidak
/// selesai", DP7). Numbers are never reused (DM F12).
class UnfinishedVoucher {
  UnfinishedVoucher({
    required this.id,
    required this.allocatedAt,
    this.series = VoucherSeries.bku,
    this.year,
    this.number,
    this.note,
    this.seedKey,
  });

  final String id;
  final DateTime allocatedAt;
  final VoucherSeries series;
  int? year;
  int? number;
  final String? note;

  /// The drawn number ('0111'), a lookup key only.
  final String? seedKey;
}

/// What `TransactionRepository.correct` makes: a reversal draft and its
/// replacement draft, both to be reviewed and finalized.
class Correction {
  const Correction({required this.reversal, required this.replacement});

  final Transaction reversal;
  final Transaction replacement;
}
