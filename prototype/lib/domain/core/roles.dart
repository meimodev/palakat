import '../../core/tanggal.dart';
import 'capabilities.dart';

/// The role catalog (PMP 10). What each role may do is the table in
/// `capabilities.dart`.
enum Role {
  pengelolaTeknis('Pengelola teknis'),
  petugasVerifikasi('Petugas verifikasi'),
  pimpinanJemaat('Pimpinan Jemaat yang berwenang'),
  ketuaJemaat('Ketua Jemaat'),
  wakilKetuaBpmj('Wakil Ketua BPMJ'),
  operator('Operator'),
  bendaharaJemaat('Bendahara Jemaat', needsAuthority: true),
  pemeriksaKedua('Pemeriksa kedua'),
  aksesTerbatas('Akses terbatas'),
  bendaharaUnit('Bendahara unit'),
  sekretarisJemaat('Sekretaris Jemaat', needsAuthority: true),
  penatuaKolom('Penatua Kolom'),
  syamasKolom('Syamas Kolom'),
  ketuaUnit('Ketua unit'),
  ketuaPanitia('Ketua Panitia'),
  sekretarisPanitia('Sekretaris Panitia');

  const Role(this.label, {this.needsAuthority = false});

  final String label;

  /// The Bendahara and Sekretaris act only with an active AuthorityGrant,
  /// verified by the Petugas verifikasi (RD07, DL10).
  final bool needsAuthority;
}

/// A dated term: in force at a date from [start] to [end] (inclusive), unless
/// it was ended live at [endedAt], from whose date on it is not in force.
mixin Term {
  Tanggal get start;
  Tanggal? get end;
  DateTime? get endedAt;

  bool inForce(Tanggal at) =>
      start <= at &&
      (end == null || at <= end!) &&
      (endedAt == null || at < Tanggal.dari(endedAt!));

  /// Not in force at [at] because it ended before it.
  bool endedBy(Tanggal at) => start <= at && !inForce(at);
}

/// A post in a scope (PMP 5): 'Penatua Kolom 7'. Vacant while no
/// assignment to it is in force.
class Post {
  Post({
    required this.id,
    required this.role,
    required this.scopeId,
    required this.title,
    this.revision = 1,
  });

  final String id;
  final Role role;
  final String scopeId;

  /// As drawn: 'Bendahara Jemaat', 'Penatua Kolom 2', 'Ketua Pemuda'.
  final String title;
  int revision;
}

enum AssignmentStatus {
  /// Recorded; waiting for the authority grant (Bendahara, Sekretaris).
  pending,
  active,
  ended,
}

/// A person in a post for a term (PMP 5 Role assignment).
class Assignment with Term {
  Assignment({
    required this.id,
    required this.postId,
    required this.personId,
    required this.start,
    this.end,
    this.endedAt,
    this.status = AssignmentStatus.active,
    this.documentRef,
    this.recordedBy,
    this.recordedAt,
    this.endReason,
    this.revision = 1,
  });

  final String id;
  final String postId;
  final String personId;
  @override
  Tanggal start;
  @override
  Tanggal? end;
  @override
  DateTime? endedAt;
  AssignmentStatus status;

  /// The church document: 'SK BPMJ No. 12/…'.
  String? documentRef;
  String? recordedBy;
  DateTime? recordedAt;
  String? endReason;
  int revision;

  @override
  bool inForce(Tanggal at) =>
      status != AssignmentStatus.pending && super.inForce(at);
}

/// A task delegated for a dated period (PMP 5; it expires by itself).
class DelegatedTask {
  const DelegatedTask({
    required this.capability,
    required this.scopeId,
    required this.label,
  });

  final Capability capability;
  final String scopeId;

  /// As drawn: 'Verifikasi data Kolom 7'.
  final String label;
}

class Delegation with Term {
  Delegation({
    required this.id,
    required this.fromPersonId,
    this.fromAssignmentId,
    required this.toPersonId,
    required this.task,
    required this.start,
    required this.end,
    this.endedAt,
    this.createdAt,
    this.revision = 1,
  });

  final String id;
  final String fromPersonId;
  final String? fromAssignmentId;
  final String toPersonId;
  final DelegatedTask task;
  @override
  final Tanggal start;
  @override
  Tanggal? end;
  @override
  DateTime? endedAt;
  DateTime? createdAt;
  int revision;
}

/// An Operator acting in a vacant post (DL12). It ends when a holder is
/// assigned.
class VacancyCover with Term {
  VacancyCover({
    required this.id,
    required this.postId,
    required this.personId,
    this.operatorAssignmentId,
    required this.start,
    required this.startedAt,
    this.end,
    this.endedAt,
    this.reason,
    this.revision = 1,
  });

  final String id;
  final String postId;
  final String personId;
  final String? operatorAssignmentId;
  @override
  final Tanggal start;
  final DateTime startedAt;
  @override
  Tanggal? end;
  @override
  DateTime? endedAt;
  final String? reason;
  int revision;
}

enum GrantStatus { pending, active, revoked }

/// The church authorization of a Bendahara or Sekretaris (DM 3
/// AuthorityGrant, RD07, DL10): pending → active → revoked.
class AuthorityGrant {
  AuthorityGrant({
    required this.id,
    required this.personId,
    required this.assignmentId,
    required this.role,
    this.status = GrantStatus.pending,
    this.documentRef,
    this.recordedBy,
    this.recordedAt,
    this.verifiedBy,
    this.verifiedAt,
    this.revokedBy,
    this.revokedAt,
    this.reason,
    this.revision = 1,
  });

  final String id;
  final String personId;
  final String assignmentId;
  final Role role;
  GrantStatus status;
  String? documentRef;
  String? recordedBy;
  DateTime? recordedAt;
  String? verifiedBy;
  DateTime? verifiedAt;
  String? revokedBy;
  DateTime? revokedAt;
  String? reason;
  int revision;
}

enum HandoverStatus { proposed, recorded }

/// The outgoing holder's handover (SerahTerima, DP39): recorded later by the
/// authorized church officer through RoleRepository.assign.
class HandoverProposal {
  HandoverProposal({
    required this.id,
    required this.postId,
    required this.fromPersonId,
    required this.toPersonId,
    required this.documentRef,
    required this.createdAt,
    this.status = HandoverStatus.proposed,
    this.assignmentId,
    this.revision = 1,
  });

  final String id;
  final String postId;
  final String fromPersonId;
  final String toPersonId;
  final String documentRef;
  final DateTime createdAt;
  HandoverStatus status;
  String? assignmentId;
  int revision;
}

/// A post as RoleRepository.posts shows it: holder, vacancy, cover, a pending
/// assignment waiting for authority, and a proposed handover.
class PostView {
  const PostView({
    required this.post,
    this.holder,
    this.pending,
    this.pendingGrant,
    this.cover,
    this.handover,
    this.lastHolder,
  });

  final Post post;

  /// The assignment in force today.
  final Assignment? holder;

  /// "Menunggu verifikasi wewenang".
  final Assignment? pending;
  final AuthorityGrant? pendingGrant;

  /// The Operator's cover in force today.
  final VacancyCover? cover;
  final HandoverProposal? handover;

  /// The most recent ended assignment ('Pnt. Altje Rompas, … – …').
  final Assignment? lastHolder;

  bool get vacant => holder == null;
}
