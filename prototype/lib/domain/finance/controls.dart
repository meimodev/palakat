import '../../core/tanggal.dart';
import '../core/files.dart';
import 'transaction.dart';

// ---------- Approval (DM 5.2) ----------

/// EXTERNAL: MISSING (no record in force) → RECORDED; a newer declaration
/// supersedes; a material change of the transaction voids it.
enum ApprovalStatus { recorded, superseded, voided }

/// What the Bendahara records about an approval given outside the app.
class ApprovalDeclaration {
  const ApprovalDeclaration({
    required this.approverName,
    required this.approverRole,
    required this.date,
    required this.method,
    this.notes,
  });

  /// 'Pdt. Lidya Rondonuwu'; 'Ketua BPMJ'.
  final String approverName;
  final String approverRole;
  final Tanggal date;

  /// 'notulen rapat'.
  final String method;
  final String? notes;
}

/// DM 3 ApprovalRecord: the declared approver, distinct from who recorded it.
class ApprovalRecord {
  ApprovalRecord({
    required this.id,
    required this.transactionId,
    required this.declaration,
    required this.recordedBy,
    required this.recordedAt,
    required this.transactionRevision,
    this.status = ApprovalStatus.recorded,
    this.supersededBy,
    this.endedAt,
    this.reason,
    this.revision = 1,
  });

  final String id;
  final String transactionId;
  final ApprovalDeclaration declaration;
  final String recordedBy;
  final DateTime recordedAt;

  /// The transaction revision it binds (DM 5.2).
  int transactionRevision;
  ApprovalStatus status;
  String? supersededBy;

  /// When it was superseded or voided.
  DateTime? endedAt;
  String? reason;
  int revision;
}

// ---------- Evidence (DM 5.3) ----------

/// The projection per transaction. Failed and quarantined are not reachable
/// (D9).
enum EvidenceStatus {
  notRequired,
  requiredMissing,
  uploaded,
  verified,
  exceptionAccepted,
}

/// One append-only decision line: an uploaded file and what became of it,
/// or an accepted exception ([file] null).
enum EvidenceItemState { uploaded, verified, rejected, released, exception }

class EvidenceItem {
  EvidenceItem({
    required this.id,
    required this.transactionId,
    required this.state,
    required this.by,
    required this.at,
    this.file,
    this.decidedBy,
    this.decidedAt,
    this.reason,
    this.revision = 1,
  });

  final String id;
  final String transactionId;
  EvidenceItemState state;

  /// Uploader (or who accepted the exception) and when.
  final String by;
  final DateTime at;
  final SampleFile? file;

  /// Who verified, rejected or released it, and when.
  String? decidedBy;
  DateTime? decidedAt;

  /// The exception's or rejection's reason ('kuitansi menyusul').
  String? reason;
  int revision;
}

// ---------- Cases (DM 5.4) ----------

/// Uang Muka, Titipan, Penggantian biaya. A claim is not a DM entity: it is
/// modelled here (domain.md 1, gap).
enum CaseKind { advance, transit, claim }

/// Derived from posted linked transactions: OPEN, PARTIALLY_SETTLED or
/// PARTIALLY_REMITTED, SETTLED.
enum CaseState { open, partial, settled }

/// One case; one Fund (EC06). Its amounts are derived ([CaseView]).
class FinanceCase {
  FinanceCase({
    required this.id,
    required this.kind,
    required this.title,
    required this.fundId,
    required this.openedOn,
    required this.createdBy,
    required this.createdAt,
    this.partyId,
    this.scopeId,
    this.accountId,
    this.dueDate,
    this.claimAmount,
    this.note,
    this.checkedBy,
    this.checkedAt,
    this.seedKey,
    this.revision = 1,
  });

  final String id;
  final CaseKind kind;

  /// 'Panitia Natal', 'Sentralisasi November'.
  String title;
  final String fundId;
  final Tanggal openedOn;
  final String createdBy;
  final DateTime createdAt;

  /// Recipient, beneficiary or claimant.
  String? partyId;
  String? scopeId;

  /// Where a Titipan is kept ('Disimpan di Bank BNI ··4821').
  String? accountId;
  Tanggal? dueDate;

  /// A claim's amount (claims only: there is no posted claim, DM 4.2).
  int? claimAmount;

  /// 'Nota … terlampir'.
  String? note;

  /// A claim checked ('klaim sudah dicek'); checking changes no balance.
  String? checkedBy;
  DateTime? checkedAt;

  /// The drawn id ('um1', 'tt2', 'pb1'), a lookup key only.
  final String? seedKey;
  int revision;
}

/// A case with its derived figures at today.
class CaseView {
  const CaseView({
    required this.kase,
    required this.amount,
    required this.reduced,
    required this.outstanding,
    required this.state,
    required this.overdue,
    required this.entries,
  });

  final FinanceCase kase;

  /// Issued (advance), collected (transit) or claimed (claim).
  final int amount;

  /// Settled, returned, remitted or paid.
  final int reduced;
  final int outstanding;
  final CaseState state;

  /// Past its due date with something outstanding.
  final bool overdue;

  /// Its posted linked transactions, oldest first.
  final List<Transaction> entries;
}

/// `CaseRepository.issueAdvance`.
class CaseDraft {
  const CaseDraft({
    required this.kind,
    required this.title,
    required this.fundId,
    required this.amount,
    this.partyId,
    this.scopeId,
    this.accountId,
    this.dueDate,
    this.effectiveDate,
    this.masterCode,
    this.note,
  });

  final CaseKind kind;
  final String title;
  final String fundId;
  final int amount;
  final String? partyId;
  final String? scopeId;
  final String? accountId;
  final Tanggal? dueDate;

  /// Null: today.
  final Tanggal? effectiveDate;
  final String? masterCode;
  final String? note;
}

/// A settlement, return, collection, remittance or payment on a case.
class CaseEntryDraft {
  const CaseEntryDraft({
    required this.amount,
    this.accountId,
    this.masterCode,
    this.effectiveDate,
    this.description,
    this.scopeId,
  });

  final int amount;
  final String? accountId;
  final String? masterCode;
  final Tanggal? effectiveDate;
  final String? description;
  final String? scopeId;
}

/// `CaseRepository.recordClaim`.
class ClaimDraft {
  const ClaimDraft({
    required this.title,
    required this.partyId,
    required this.fundId,
    required this.amount,
    this.note,
  });

  final String title;
  final String partyId;
  final String fundId;
  final int amount;
  final String? note;
}

// ---------- Import (DM 5.5, 6.2) ----------

enum ImportBatchStatus { staged, validated, reviewed, committed }

/// A staged row's disposition; refused and deselected rows are kept.
enum RowDisposition { pending, ok, possibleDuplicate, refused, deselected }

class ImportBatch {
  ImportBatch({
    required this.id,
    required this.fileName,
    required this.createdBy,
    required this.createdAt,
    this.status = ImportBatchStatus.staged,
    this.revision = 1,
  });

  final String id;
  final String fileName;
  final String createdBy;
  final DateTime createdAt;
  ImportBatchStatus status;
  int revision;
}

/// A staged row: the raw source text and what it was read as.
class StagedRow {
  StagedRow({
    required this.id,
    required this.batchId,
    required this.ordinal,
    required this.raw,
    this.date,
    this.accountId,
    this.amount,
    this.type,
    this.masterCode,
    this.disposition = RowDisposition.pending,
    this.reason,
    this.duplicateOf,
    this.selected = true,
    this.committedTransactionId,
    this.revision = 1,
  });

  final String id;
  final String batchId;
  final int ordinal;

  /// Exactly as in the file: '02/11/26 · Persembahan Mgg · 3.100.000'.
  final String raw;

  /// Null when unreadable ('tanggal tidak terbaca').
  Tanggal? date;
  String? accountId;
  int? amount;
  TransactionType? type;
  String? masterCode;
  RowDisposition disposition;
  String? reason;
  String? duplicateOf;
  bool selected;

  /// The DRAFT made by commit.
  String? committedTransactionId;
  int revision;
}

/// A bundled sample file to stage.
class SampleImport {
  const SampleImport(this.fileName, this.lines);

  final String fileName;
  final List<String> lines;
}

// ---------- Reconciliation (DM 5.5, 6.3) ----------

enum ReconStatus { open, reviewed, confirmed }

/// Derived from the confirmed matches of a statement line.
enum MatchState { unmatched, partial, matched }

/// One Account in one period.
class ReconSession {
  ReconSession({
    required this.id,
    required this.accountId,
    required this.periodId,
    this.statementClosing,
    this.statementFile,
    this.status = ReconStatus.open,
    this.timingItems = const {},
    this.reviewedBy,
    this.reviewedAt,
    this.confirmedBy,
    this.confirmedAt,
    this.confirmReason,
    this.revision = 1,
  });

  final String id;
  final String accountId;
  final String periodId;

  /// The observed statement closing; null until a statement is in.
  int? statementClosing;
  String? statementFile;
  ReconStatus status;

  /// Timing items: transaction id → reason ('dibawa ke {bulan}').
  Map<String, String> timingItems;
  String? reviewedBy;
  DateTime? reviewedAt;
  String? confirmedBy;
  DateTime? confirmedAt;

  /// The church Bendahara confirming a unit's account says why (DL33).
  String? confirmReason;
  int revision;
}

/// An observed bank line (DM 3 StatementLine); never income by itself.
class StatementLine {
  StatementLine({
    required this.id,
    required this.sessionId,
    required this.date,
    required this.amount,
    required this.description,
    this.matchedTransactionIds = const [],
    this.revision = 1,
  });

  final String id;
  final String sessionId;
  final Tanggal date;

  /// Signed: in positive, out negative.
  final int amount;

  /// 'TRF MASUK IBU RUNTU', 'BIAYA ADM'.
  final String description;
  List<String> matchedTransactionIds;
  int revision;
}

/// A cash count (DM 3 CashCount). An observed zero is explicit; no count is
/// not zero.
class CashCount {
  CashCount({
    required this.id,
    required this.accountId,
    required this.periodId,
    required this.countedAt,
    required this.denominations,
    required this.counters,
    required this.recordedBy,
    this.file,
  });

  final String id;
  final String accountId;

  /// The period it observes the closing of.
  final String periodId;
  final DateTime countedAt;

  /// Denomination → sheets: {100000: 80, 50000: 5, …}.
  final Map<int, int> denominations;

  /// Names of the counters.
  final List<String> counters;
  final String recordedBy;
  final SampleFile? file;

  int get total => denominations.entries.fold(0, (s, e) => s + e.key * e.value);
}

/// A bundled sample statement to import.
class SampleStatement {
  const SampleStatement({
    required this.fileName,
    required this.closing,
    required this.lines,
  });

  final String fileName;
  final int closing;
  final List<({Tanggal date, String description, int amount})> lines;
}

// ---------- Period and close (DM 5.5, 6.4) ----------

/// OPEN → CLOSED, irreversible, in calendar order (RD01).
enum PeriodStatus { open, closed }

/// A church-wide calendar month. The first starts at the cutover (RD05).
class Period {
  Period({
    required this.year,
    required this.month,
    required this.start,
    required this.end,
    this.status = PeriodStatus.open,
    this.closedBy,
    this.closedAt,
    this.confirmation,
    this.snapshotId,
    this.revision = 1,
  });

  final int year, month;
  final Tanggal start, end;
  PeriodStatus status;
  String? closedBy;
  DateTime? closedAt;

  /// The closer's explicit confirmation text (RD08).
  String? confirmation;
  String? snapshotId;
  int revision;

  /// 'yyyy-mm'.
  String get id => periodIdOf(year, month);
  bool get isClosed => status == PeriodStatus.closed;
  bool contains(Tanggal d) => start <= d && d <= end;
}

/// 'yyyy-mm': the period id of a month.
String periodIdOf(int year, int month) =>
    '$year-${month.toString().padLeft(2, '0')}';

/// DM 6.4 blocker classes, as the boards check them.
enum BlockerKind {
  /// An earlier period is still OPEN.
  earlierPeriodOpen,

  /// A bank Account has no statement for the period.
  statementMissing,

  /// A cash Account has no count for the period.
  cashCountMissing,

  /// An Account's reconciliation is not confirmed, or a book change after
  /// its confirmation made it stale.
  notReconciled,

  /// A posted part lacks its Mata Anggaran.
  missingClassification,
  approvalMissing,
  evidenceMissing,

  /// A DRAFT or REVIEWED transaction dated in the period (RD09).
  openDraft,

  /// A staged import row dated in the period, not yet committed (RD09).
  stagedImportRow,
  negativeCase,

  /// A Fund's readiness attestation is missing or invalidated (RD12).
  readinessMissing,
  readinessInvalidated,

  /// No report template accepted (RD03).
  templateNotAccepted,
}

/// One computed close blocker (DM 6.4); never stored.
class Blocker {
  const Blocker({
    required this.kind,
    this.transactionId,
    this.accountId,
    this.fundId,
    this.caseId,
    this.importRowId,
    this.periodId,
    this.unitScopeId,
    this.amount,
  });

  final BlockerKind kind;
  final String? transactionId;
  final String? accountId;
  final String? fundId;
  final String? caseId;
  final String? importRowId;

  /// The earlier open period.
  final String? periodId;

  /// The unit whose item it is ('hambatan dari unit'; DL33).
  final String? unitScopeId;
  final int? amount;
}

/// RD12: CURRENT → INVALIDATED by a later posting in the Fund; a missing one
/// may be waived by the workspace Treasurer with a reason.
class ReadinessAttestation {
  ReadinessAttestation({
    required this.id,
    required this.fundId,
    required this.periodId,
    this.preparerId,
    this.attestedAt,
    this.waivedBy,
    this.waivedAt,
    this.waiverReason,
    this.revision = 1,
  });

  final String id;
  final String fundId;
  final String periodId;
  String? preparerId;
  DateTime? attestedAt;
  String? waivedBy;
  DateTime? waivedAt;
  String? waiverReason;
  int revision;
}

enum ReadinessState { missing, current, invalidated, waived }

/// A Fund that needs an attestation for a period, with its state.
class ReadinessView {
  const ReadinessView({
    required this.fundId,
    required this.state,
    this.attestation,
  });

  final String fundId;
  final ReadinessState state;
  final ReadinessAttestation? attestation;
}

/// What `PeriodRepository.recordIncident` takes.
class IncidentExplanation {
  const IncidentExplanation({
    required this.title,
    required this.facts,
    required this.impact,
    required this.responsible,
    this.escalation,
    this.transactionIds = const [],
  });

  final String title;
  final String facts;
  final String impact;
  final String responsible;
  final String? escalation;
  final List<String> transactionIds;
}

/// DM 3 CloseIncident: never mutates a CLOSED period or clears a blocker.
class CloseIncident {
  CloseIncident({
    required this.id,
    required this.year,
    required this.number,
    required this.periodId,
    required this.explanation,
    required this.recordedBy,
    required this.recordedAt,
    this.narrativeResolution,
    this.settlementTransactionId,
    this.revision = 1,
  });

  final String id;

  /// 'K-{year}-{NN}', numbered in recording order.
  final int year, number;
  final String periodId;
  final IncidentExplanation explanation;
  final String recordedBy;
  final DateTime recordedAt;
  String? narrativeResolution;

  /// The DRAFT in the open month, when one was made.
  String? settlementTransactionId;
  int revision;

  String get code => 'K-$year-${number.toString().padLeft(2, '0')}';
}

// ---------- Reports (DM 7, 8) ----------

/// The GMIM report pack forms.
enum ReportForm {
  f01,
  f02,
  f03,
  f04,
  f05,
  f06,
  f07,
  f08,
  f09,
  f10,
  f11,
  f12,
  f13,
  f14,
}

/// DM 3: the set of Funds and Accounts a report covers; null = all.
class Perimeter {
  const Perimeter({this.fundIds, this.accountIds});

  static const whole = Perimeter();

  final Set<String>? fundIds;
  final Set<String>? accountIds;

  bool get isWhole => fundIds == null && accountIds == null;
}

/// Where a dataset comes from: the period's snapshot when it is closed and
/// the perimeter is whole, else a preview computed from state.
class ReportSource {
  const ReportSource(this.periodId, {this.perimeter = Perimeter.whole});

  final String periodId;
  final Perimeter perimeter;
}

/// One computed dataset: rows of named values (keys per form in
/// `ReportRepository`) and named totals.
class ReportDataset {
  const ReportDataset({
    required this.form,
    required this.rows,
    this.totals = const {},
  });

  final ReportForm form;
  final List<Map<String, Object?>> rows;
  final Map<String, Object?> totals;
}

/// A set of datasets for one period and perimeter (PREVIEW or SNAPSHOT).
class ReportPack {
  const ReportPack({
    required this.periodId,
    required this.perimeter,
    required this.coverageStart,
    required this.coverageEnd,
    required this.official,
    required this.datasets,
  });

  final String periodId;
  final Perimeter perimeter;

  /// The interval it covers: from the cutover in the first period (RD05).
  final Tanggal coverageStart, coverageEnd;

  /// True for a snapshot.
  final bool official;
  final Map<ReportForm, ReportDataset> datasets;
}

/// The close snapshot: a deep copy of the datasets (README 4.6 point 3).
class ReportSnapshot {
  const ReportSnapshot({
    required this.year,
    required this.month,
    required this.frozenAt,
    required this.closedBy,
    required this.masterVersionIds,
    required this.pack,
  });

  final int year, month;
  final DateTime frozenAt;
  final String closedBy;
  final List<String> masterVersionIds;
  final ReportPack pack;

  /// 'SNP-{year}-{mm}-01'.
  String get id => 'SNP-$year-${month.toString().padLeft(2, '0')}-01';
}

/// The report template (DM 11); 'Bawaan Palakat v1' once accepted (RD03).
class ReportTemplate {
  ReportTemplate({
    required this.id,
    required this.name,
    this.acceptedBy,
    this.acceptedAt,
    this.revision = 1,
  });

  final String id;
  final String name;
  String? acceptedBy;
  DateTime? acceptedAt;
  int revision;

  bool get accepted => acceptedBy != null;
}

/// TERBATAS: one Fund's slice (F02, F03, F05, F07, F12) for a Fund-only
/// viewer (D27).
class RestrictedReport {
  const RestrictedReport({required this.fundId, required this.datasets});

  final String fundId;
  final Map<ReportForm, ReportDataset> datasets;
}

// ---------- AI (README 4.6 point 6) ----------

/// The boards that ask: AIFoto (a receipt photo), BantuanAI (a sentence),
/// AIMataAnggaran (a Mata Anggaran suggestion), AIBulan/WebAI (month end).
enum AiKind { receiptPhoto, sentence, masterRow, monthEnd }

enum AiProposalStatus { pending, ready, disposed }

/// 'Pakai', 'Ubah', 'Abaikan'. None needs a reason.
enum AiDisposition { accepted, edited, rejected }

/// What a board sends.
class AiInput {
  const AiInput({this.text = '', this.amount, this.fileName});

  /// The sentence or the description.
  final String text;
  final int? amount;

  /// The photo's file name.
  final String? fileName;
}

/// One suggested line: a Mata Anggaran row and its part (null amount when
/// the AI is unsure).
class AiLine {
  const AiLine(this.masterCode, this.amount);

  final String masterCode;
  final int? amount;
}

/// The board's fixed proposal. Kas/Bank, peruntukan and Lingkup are never
/// suggested (D01).
class AiResult {
  const AiResult({
    this.amount,
    this.payee,
    this.date,
    this.lines = const [],
    this.unsure = false,
  });

  final int? amount;
  final String? payee;
  final Tanggal? date;
  final List<AiLine> lines;

  /// 'AI kurang yakin': candidates without amounts.
  final bool unsure;
}

/// DM 3 AIProposal: no posting or approval authority.
class AiProposal {
  AiProposal({
    required this.id,
    required this.kind,
    required this.input,
    required this.cost,
    required this.requestedBy,
    required this.requestedAt,
    this.status = AiProposalStatus.pending,
    this.result,
    this.readyAt,
    this.disposition,
    this.disposedBy,
    this.disposedAt,
    this.revision = 1,
  });

  final String id;
  final AiKind kind;
  final AiInput input;

  /// Rupiah added to the month's spend.
  final int cost;
  final String requestedBy;
  final DateTime requestedAt;
  AiProposalStatus status;
  AiResult? result;
  DateTime? readyAt;
  AiDisposition? disposition;
  String? disposedBy;
  DateTime? disposedAt;
  int revision;
}

/// The month's AI spend against the cap ("Batas biaya AI per bulan").
class AiBudget {
  const AiBudget({
    required this.periodId,
    required this.cap,
    required this.spent,
    required this.cost,
  });

  final String periodId;
  final int cap;
  final int spent;

  /// The cost of one proposal.
  final int cost;

  /// README 4.2: used up when spend + cost > cap.
  bool get usedUp => spent + cost > cap;

  /// 0–100, for the bar and the 70 % note.
  int get percent => cap == 0 ? 100 : (spent * 100 ~/ cap).clamp(0, 100);
}
