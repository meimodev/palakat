/// The Collaboration domain (README 4.5; PMP 6.1, DL11, DL16, DL26–DL30):
/// Panitia, services, attendance counts, fund requests and the approver
/// table. Pure Dart. States carry the board labels (O10: Service and
/// FundRequest have no written state machine).
library;

import '../../core/tanggal.dart';
import '../core/org.dart';

// ---------- Panitia (rulebook 14.4, DL27) ----------

enum PanitiaStage {
  planning('Perencanaan'),
  active('Aktif'),
  eventCompleted('Acara selesai'),
  financialClosing('Penutupan keuangan'),
  closed('Ditutup'),
  retired('Diarsipkan');

  const PanitiaStage(this.label);
  final String label;

  /// The stage `advanceStage` moves to; null after ARCHIVED.
  PanitiaStage? get next =>
      index + 1 < values.length ? values[index + 1] : null;
}

/// Ketua, Sekretaris and Bendahara: three distinct people (P15).
class PanitiaOfficers {
  const PanitiaOfficers({
    required this.ketuaId,
    required this.sekretarisId,
    required this.bendaharaId,
  });

  final String ketuaId, sekretarisId, bendaharaId;

  bool get distinct =>
      ketuaId != sekretarisId &&
      ketuaId != bendaharaId &&
      sekretarisId != bendaharaId;
}

/// One stage change, for Riwayat.
class PanitiaStageChange {
  const PanitiaStageChange({
    required this.stage,
    required this.by,
    required this.at,
    this.reason,
  });

  final PanitiaStage stage;
  final String by;
  final DateTime at;
  final String? reason;
}

class Panitia {
  Panitia({
    required this.id,
    required this.scopeId,
    required this.name,
    required this.stage,
    required this.createdBy,
    required this.createdAt,
    this.skDocumentId,
    this.officers,
    this.fundId,
    List<PanitiaStageChange>? history,
    this.revision = 1,
  }) : history = history ?? [];

  final String id;

  /// Its Scope (type panitia): Funds, posts and cases point at it.
  final String scopeId;
  final String name;
  PanitiaStage stage;

  /// The written church decision in Dokumen gereja; null only for Panitia
  /// recorded before the app (Paskah, HUT).
  final String? skDocumentId;
  final PanitiaOfficers? officers;

  /// The peruntukan, created on activation (AlurPanitiaBaru).
  String? fundId;
  final String createdBy;
  final DateTime createdAt;

  /// Oldest first.
  final List<PanitiaStageChange> history;

  /// Where the leftover money goes, approved by the church Bendahara (DL27).
  String? leftoverFundId;
  int? leftoverAmount;
  String? leftoverApprovedBy;
  DateTime? leftoverApprovedAt;
  int revision;

  bool get leftoverApproved => leftoverApprovedBy != null;

  /// When it entered [s]; null when it has not.
  DateTime? reachedAt(PanitiaStage s) =>
      history.where((h) => h.stage == s).lastOrNull?.at;
}

/// A Panitia's money, computed from the ledger (DP27): its own Fund and the
/// advances issued to its scope.
class PanitiaMoney {
  const PanitiaMoney({
    required this.fundBalance,
    required this.advanceIds,
    required this.advanced,
    required this.settled,
    required this.returned,
    required this.outstanding,
  });

  /// The Panitia's own peruntukan (Rp0 for Panitia Natal, DP27).
  final int fundBalance;

  /// Advance cases issued to its scope (um1).
  final List<String> advanceIds;
  final int advanced, settled, returned;

  /// "Uang Muka belum dipertanggungjawabkan".
  final int outstanding;

  /// "Sisa uang": what is still to be accounted for or returned.
  int get leftover => fundBalance + outstanding;
}

// ---------- Services (DL11) ----------

enum ServiceKind {
  minggu('Ibadah Minggu'),
  kolom('Ibadah Kolom'),
  bipra('Ibadah BIPRA'),
  panitia('Kegiatan Panitia');

  const ServiceKind(this.label);
  final String label;
}

/// Board labels (README 4.5).
enum ServiceStatus {
  draft('Draf'),
  scheduled('Dijadwalkan'),
  done('Selesai'),
  closed('Ditutup');

  const ServiceStatus(this.label);
  final String label;
}

class ServiceDraft {
  const ServiceDraft({
    required this.title,
    required this.kind,
    required this.scopeId,
    required this.date,
    this.time,
    this.sessions,
    this.place,
  });

  final String title;
  final ServiceKind kind;

  /// The audience: 'jemaat' (Semua anggota) or a Kolom, BIPRA, Panitia.
  final String scopeId;
  final Tanggal date;

  /// '19.00'.
  final String? time;

  /// 'Subuh, Pagi, Malam'.
  final String? sessions;
  final String? place;
}

class Service {
  Service({
    required this.id,
    required this.title,
    required this.kind,
    required this.scopeId,
    required this.date,
    required this.draftedBy,
    required this.createdAt,
    this.time,
    this.sessions,
    this.place,
    this.status = ServiceStatus.draft,
    this.approvedBy,
    this.approverTitle,
    this.approvedAt,
    this.revision = 1,
  });

  final String id;
  final String title;
  final ServiceKind kind;
  final String scopeId;
  final Tanggal date;
  final String? time, sessions, place;
  final String draftedBy;
  final DateTime createdAt;
  ServiceStatus status;

  /// Who approved, as which post ('Penatua Kolom 7'), when (DL11). The
  /// approver also assigns counters and finalizes the count (DL30).
  String? approvedBy;
  String? approverTitle;
  DateTime? approvedAt;
  DateTime? closedAt;
  int revision;

  bool get forEveryone => scopeId == ScopeRef.jemaatId;
}

// ---------- Attendance (rulebook 14.9, DL30) ----------

enum AttendanceStatus {
  live('Sedang dihitung'),
  review('Sudah diperiksa'),
  finalized('Ditetapkan');

  const AttendanceStatus(this.label);
  final String label;
}

/// One counting post ('Pintu depan') and its counter.
class CounterPost {
  CounterPost({required this.post, required this.personId, this.count = 0});

  final String post;
  String personId;
  int count;
}

/// A correction keeps both values (DP35).
class AttendanceCorrection {
  const AttendanceCorrection({
    required this.from,
    required this.to,
    required this.reason,
    required this.by,
    required this.at,
  });

  final int from, to;
  final String reason, by;
  final DateTime at;
}

/// Counts only: no names, no absent list (Kehadiran).
class AttendanceCount {
  AttendanceCount({
    required this.serviceId,
    List<CounterPost>? posts,
    this.status = AttendanceStatus.live,
    this.revision = 1,
  }) : posts = posts ?? [];

  final String serviceId;

  /// In assignment order.
  final List<CounterPost> posts;
  AttendanceStatus status;
  String? reviewedBy;
  DateTime? reviewedAt;
  String? finalizedBy;
  DateTime? finalizedAt;

  /// Oldest first.
  final List<AttendanceCorrection> corrections = [];
  int revision;

  /// The sum of the posts: what was counted.
  int get counted => posts.fold(0, (n, p) => n + p.count);

  /// The figure reports use: the last correction, else the count.
  int get total => corrections.isEmpty ? counted : corrections.last.to;

  CounterPost? postOf(String post) =>
      posts.where((p) => p.post == post).firstOrNull;

  bool isCounter(String personId) => posts.any((p) => p.personId == personId);
}

// ---------- In-app approvals (DL29, DM 5.2) ----------

/// Who approves a unit type's requests: its own head, or the Ketua Jemaat.
enum ApproverChoice {
  unitHead,
  ketuaJemaat;

  /// 'Penatua Kolom', 'Ketua BIPRA', 'Ketua Komisi', 'Ketua Panitia', or
  /// 'Ketua Jemaat' (PemberiPersetujuan pills).
  String labelFor(ScopeType unitType) => switch (this) {
    ketuaJemaat => 'Ketua Jemaat',
    unitHead => switch (unitType) {
      ScopeType.kolom => 'Penatua Kolom',
      ScopeType.bipra => 'Ketua BIPRA',
      ScopeType.komisi => 'Ketua Komisi',
      ScopeType.panitia => 'Ketua Panitia',
      _ => 'Ketua Jemaat',
    },
  };
}

/// The church's approver table (DL29). Until a row is filled, the default
/// applies: the unit's own head; Church Fund requests go to the Ketua
/// Jemaat. Below [threshold] no approval is needed.
class ApproverTable {
  ApproverTable({this.threshold = 250000, this.revision = 1});

  /// The unit types the table has rows for, in board order.
  static const unitTypes = [
    ScopeType.kolom,
    ScopeType.bipra,
    ScopeType.komisi,
    ScopeType.panitia,
  ];

  final Map<ScopeType, ApproverChoice> rows = {};
  int threshold;
  String? savedBy;
  DateTime? savedAt;
  int revision;

  /// Every row filled ("Simpan tabel").
  bool get filled => unitTypes.every(rows.containsKey);

  ApproverChoice choiceFor(ScopeType unitType) => unitType == ScopeType.jemaat
      ? ApproverChoice.ketuaJemaat
      : rows[unitType] ?? ApproverChoice.unitHead;
}

/// IN_APP approval (DM 5.2): PENDING → APPROVED / REJECTED, back to PENDING
/// on a material change; NOT_REQUIRED below the threshold.
enum RequestApproval {
  notRequired('Tidak diperlukan'),
  pending('Menunggu persetujuan'),
  approved('Disetujui'),
  rejected('Tidak disetujui');

  const RequestApproval(this.label);
  final String label;
}

/// The request's board label (README 4.5).
enum FundRequestState {
  waiting('Menunggu persetujuan'),
  approved('Disetujui'),
  refused('Tidak disetujui'),
  noApprovalNeeded('Tidak diperlukan'),

  /// "Catat pembayaran" done; the Uang Muka diberikan draft is not booked
  /// yet (second-checker rule, D24).
  paymentRecorded('Pembayaran dicatat'),
  paid('Dibayar');

  const FundRequestState(this.label);
  final String label;
}

class FundRequestDraft {
  const FundRequestDraft({
    required this.purpose,
    required this.amount,
    required this.fundId,
    this.scopeId,
  });

  /// "Keperluan".
  final String purpose;
  final int amount;

  /// "Diambil dari peruntukan": its owner's unit type decides the approver.
  final String fundId;

  /// The requesting unit; null: the unit of the post the requester acts in.
  final String? scopeId;
}

/// One approval decision, kept when it stops counting (Riwayat).
class RequestDecision {
  const RequestDecision({
    required this.approval,
    required this.by,
    required this.byTitle,
    required this.at,
    required this.amount,
    this.reason,
    this.superseded = false,
  });

  final RequestApproval approval;
  final String by, byTitle;
  final DateTime at;
  final int amount;
  final String? reason;

  /// Voided by a material change ("Persetujuan lama tidak berlaku lagi").
  final bool superseded;

  RequestDecision supersede() => RequestDecision(
    approval: approval,
    by: by,
    byTitle: byTitle,
    at: at,
    amount: amount,
    reason: reason,
    superseded: true,
  );
}

class FundRequest {
  FundRequest({
    required this.id,
    required this.purpose,
    required this.amount,
    required this.fundId,
    required this.scopeId,
    required this.requestedBy,
    required this.requesterTitle,
    required this.requestedAt,
    required this.approval,
    required this.approverScopeId,
    required this.approverTitle,
    this.revision = 1,
  });

  final String id;
  final String purpose;
  int amount;
  final String fundId;

  /// The requesting unit ('komisi-diakonia', 'bipra-pemuda').
  final String scopeId;
  final String requestedBy;

  /// 'Ketua Komisi Diakonia'.
  final String requesterTitle;
  final DateTime requestedAt;
  RequestApproval approval;

  /// The scope whose `requests.approve` holder decides: 'jemaat' for the
  /// Ketua Jemaat, else the unit's own; and that post's title.
  String approverScopeId;
  String approverTitle;

  /// Oldest first.
  final List<RequestDecision> decisions = [];

  /// The Uang Muka diberikan draft and its advance case (`recordPayment`).
  String? paymentTransactionId;
  String? caseId;
  int revision;

  RequestDecision? get decision =>
      decisions.where((d) => !d.superseded).lastOrNull;
}

/// A request with its state at read time ("Dibayar" once the payment draft
/// is booked).
class FundRequestView {
  const FundRequestView({required this.request, required this.state});

  final FundRequest request;
  final FundRequestState state;

  /// Money may be paid out: approved, or below the threshold, and not yet
  /// recorded.
  bool get payable =>
      state == FundRequestState.approved ||
      state == FundRequestState.noApprovalNeeded;
}
