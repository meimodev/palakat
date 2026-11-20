import '../../core/tanggal.dart';
import 'actor.dart';
import 'modules.dart';
import 'org.dart';
import 'people.dart';
import 'result.dart';
import 'roles.dart';

/// The capability catalog (PMP 11, README 3.5): `<module>.<action>`.
/// [module] null means core or Reports and search, which are always on.
/// [read] capabilities stay allowed while their module is READ_ONLY (PMP 8).
/// [decision] marks the approvals and verifications for which a person with
/// two posts that both hold it is asked "Sebagai …" (Q31, BerandaJabatan).
enum Capability {
  // Core
  assignPost('core.assign_post', null, 'Catat penugasan'),
  coverVacancy('core.cover_vacancy', null, 'Jalankan jabatan kosong'),
  delegate('core.delegate', null, 'Buat pelimpahan'),
  switchModule('core.switch_module', null, 'Ubah modul'),
  verifyAuthority('core.verify_authority', null, 'Verifikasi wewenang'),
  viewPeople('core.view_people', null, 'Cari orang', read: true),
  recoverAccount('core.recover_account', null, 'Pulihkan akun'),
  confirmRecovery('core.confirm_recovery', null, 'Pastikan identitas'),
  export('core.export', null, 'Ekspor data'),
  reportsCross('reports.cross', null, 'Buka laporan', read: true),
  // Finance
  financeView('finance.view', Module.finance, 'Buka keuangan', read: true),
  financeRecord('finance.record', Module.finance, 'Catat transaksi'),
  financeReview('finance.review', Module.finance, 'Tandai sudah diperiksa'),
  financeFinalize('finance.finalize', Module.finance, 'Bukukan'),
  financeClose('finance.close', Module.finance, 'Tutup buku'),
  financeReconcile('finance.reconcile', Module.finance, 'Rekonsiliasi'),
  financeViewFund(
    'finance.view_fund',
    Module.finance,
    'Lihat peruntukan',
    read: true,
  ),
  financeSettings('finance.settings', Module.finance, 'Ubah pengaturan'),
  financeClearUnitBlocker(
    'finance.clear_unit_blocker',
    Module.finance,
    'Selesaikan hambatan unit',
  ),
  financeAcceptException(
    'finance.accept_exception',
    Module.finance,
    'Terima pengecualian',
  ),
  financeAcceptTemplate(
    'finance.accept_template',
    Module.finance,
    'Setujui format laporan',
  ),
  financeHandover('finance.handover', Module.finance, 'Serah terima'),
  // Unit finance
  unitFinanceRecord(
    'unit_finance.record',
    Module.unitFinance,
    'Catat transaksi unit',
  ),
  unitFinanceFinalize('unit_finance.finalize', Module.unitFinance, 'Bukukan'),
  unitFinanceAttest('unit_finance.attest', Module.unitFinance, 'Nyatakan siap'),
  // Church documents and letters
  documentsView(
    'documents.view',
    Module.churchDocuments,
    'Buka dokumen',
    read: true,
  ),
  documentsPublish('documents.publish', Module.churchDocuments, 'Terbitkan'),
  documentsIssueLetter(
    'documents.issue_letter',
    Module.churchDocuments,
    'Terbitkan surat',
  ),
  documentsRequestLetter(
    'documents.request_letter',
    Module.churchDocuments,
    'Ajukan permohonan surat',
  ),
  documentsRecordRequest(
    'documents.record_request',
    Module.churchDocuments,
    'Catat permohonan di kantor',
  ),
  // Announcements and Warta
  announcementsView(
    'announcements.view',
    Module.announcements,
    'Buka pengumuman',
    read: true,
  ),
  announcementsDraft(
    'announcements.draft',
    Module.announcements,
    'Simpan draf',
  ),
  announcementsPublish(
    'announcements.publish',
    Module.announcements,
    'Terbitkan',
  ),
  wartaView('warta.view', Module.warta, 'Buka warta', read: true),
  wartaEdit('warta.edit', Module.warta, 'Ubah warta'),
  wartaPublish('warta.publish', Module.warta, 'Terbitkan'),
  wartaRevealIdentity('warta.reveal_identity', Module.warta, 'Buka nama'),
  // Membership
  membershipView(
    'membership.view',
    Module.membership,
    'Buka data jemaat',
    read: true,
  ),
  membershipVerify(
    'membership.verify',
    Module.membership,
    'Verifikasi data',
    decision: true,
  ),
  membershipImport(
    'membership.import',
    Module.membership,
    'Impor buku anggota',
  ),
  membershipApply('membership.apply', Module.membership, 'Ajukan permohonan'),
  membershipSubmit('membership.submit', Module.membership, 'Ajukan'),
  membershipRecordPaper(
    'membership.record_paper',
    Module.membership,
    'Masukkan formulir kertas',
  ),
  membershipConfirmHousehold(
    'membership.confirm_household',
    Module.membership,
    'Konfirmasi keluarga',
  ),
  membershipDelete('membership.delete', Module.membership, 'Hapus data'),
  membershipOverrideBipra(
    'membership.override_bipra',
    Module.membership,
    'Ubah BIPRA',
  ),
  // Services and attendance
  servicesView('services.view', Module.services, 'Buka ibadah', read: true),
  servicesDraft('services.draft', Module.services, 'Simpan draf ibadah'),
  servicesApprove(
    'services.approve',
    Module.services,
    'Setujui jadwal',
    decision: true,
  ),
  attendanceCount('attendance.count', Module.attendance, 'Hitung'),
  attendanceAssignCounter(
    'attendance.assign_counter',
    Module.attendance,
    'Tugaskan penghitung',
  ),
  attendanceFinalize(
    'attendance.finalize',
    Module.attendance,
    'Tetapkan',
    decision: true,
  ),
  attendanceCorrect('attendance.correct', Module.attendance, 'Koreksi'),
  // In-app approvals
  requestsSubmit(
    'requests.submit',
    Module.inAppApprovals,
    'Ajukan permintaan dana',
  ),
  requestsApprove(
    'requests.approve',
    Module.inAppApprovals,
    'Setujui',
    decision: true,
  ),
  requestsSetTable(
    'requests.set_table',
    Module.inAppApprovals,
    'Atur pemberi persetujuan',
  ),
  // Panitia
  panitiaCreate('panitia.create', Module.panitia, 'Buat panitia'),
  panitiaStage('panitia.stage', Module.panitia, 'Ubah tahap'),
  panitiaApproveLeftover(
    'panitia.approve_leftover',
    Module.panitia,
    'Setujui sisa uang',
  );

  const Capability(
    this.code,
    this.module,
    this.label, {
    this.read = false,
    this.decision = false,
  });

  final String code;
  final Module? module;

  /// The refusal's action word: "Tidak dapat dilakukan: {label}.".
  final String label;
  final bool read;
  final bool decision;
}

/// What every ACTIVE person may do as "Anggota jemaat" (PMP 10, Member).
/// `membership.apply` is not here: every persona is already a member (DP36).
const memberCapabilities = {
  Capability.documentsView,
  Capability.documentsRequestLetter,
  Capability.announcementsView,
  Capability.wartaView,
  Capability.membershipSubmit,
  Capability.servicesView,
};

/// The role → capability table (PMP 10, "Can" column). Workflow rules that
/// depend on a record (maker ≠ checker, no self-approval, Fund limits) live
/// in the commands, not here (README 3.5).
const roleCapabilities = <Role, Set<Capability>>{
  Role.pengelolaTeknis: {},
  Role.petugasVerifikasi: {Capability.verifyAuthority},
  Role.pimpinanJemaat: {
    Capability.assignPost,
    Capability.switchModule,
    Capability.delegate,
    Capability.viewPeople,
    Capability.export,
    Capability.reportsCross,
    Capability.financeView,
    Capability.financeAcceptTemplate,
    Capability.requestsSetTable,
    Capability.panitiaCreate,
    Capability.panitiaStage,
  },
  Role.ketuaJemaat: {
    Capability.delegate,
    Capability.reportsCross,
    Capability.financeAcceptException,
    Capability.servicesDraft,
    Capability.servicesApprove,
    Capability.attendanceAssignCounter,
    Capability.attendanceFinalize,
    Capability.attendanceCorrect,
    Capability.requestsApprove,
  },
  Role.wakilKetuaBpmj: {},
  Role.operator: {
    Capability.coverVacancy,
    Capability.viewPeople,
    Capability.recoverAccount,
    Capability.export,
    Capability.reportsCross,
    Capability.financeView,
    Capability.financeViewFund,
    Capability.financeRecord,
    Capability.documentsRecordRequest,
    Capability.announcementsDraft,
    Capability.membershipView,
    Capability.membershipImport,
    Capability.membershipRecordPaper,
    Capability.membershipConfirmHousehold,
    Capability.servicesDraft,
  },
  Role.bendaharaJemaat: {
    Capability.export,
    Capability.reportsCross,
    Capability.financeView,
    Capability.financeRecord,
    Capability.financeReview,
    Capability.financeFinalize,
    Capability.financeClose,
    Capability.financeReconcile,
    Capability.financeViewFund,
    Capability.financeSettings,
    Capability.financeClearUnitBlocker,
    Capability.financeHandover,
    Capability.unitFinanceRecord,
    Capability.unitFinanceAttest,
    Capability.panitiaApproveLeftover,
  },
  Role.pemeriksaKedua: {
    Capability.financeView,
    Capability.financeViewFund,
    Capability.financeReview,
  },
  Role.aksesTerbatas: {Capability.financeViewFund},
  Role.bendaharaUnit: {
    Capability.financeViewFund,
    Capability.unitFinanceRecord,
    Capability.unitFinanceFinalize,
    Capability.unitFinanceAttest,
  },
  Role.sekretarisJemaat: {
    Capability.delegate,
    Capability.viewPeople,
    Capability.documentsPublish,
    Capability.documentsIssueLetter,
    Capability.documentsRecordRequest,
    Capability.announcementsDraft,
    Capability.announcementsPublish,
    Capability.wartaEdit,
    Capability.wartaPublish,
    Capability.wartaRevealIdentity,
    Capability.membershipView,
  },
  Role.penatuaKolom: {
    Capability.delegate,
    Capability.viewPeople,
    Capability.confirmRecovery,
    Capability.reportsCross,
    Capability.membershipView,
    Capability.membershipVerify,
    Capability.membershipConfirmHousehold,
    Capability.membershipDelete,
    Capability.membershipOverrideBipra,
    Capability.servicesDraft,
    Capability.servicesApprove,
    Capability.attendanceAssignCounter,
    Capability.attendanceFinalize,
    Capability.attendanceCorrect,
    Capability.requestsApprove,
  },
  Role.syamasKolom: {
    Capability.servicesDraft,
    Capability.servicesApprove,
    Capability.attendanceAssignCounter,
    Capability.attendanceFinalize,
    Capability.attendanceCorrect,
  },
  Role.ketuaUnit: {
    Capability.reportsCross,
    Capability.servicesApprove,
    Capability.requestsSubmit,
    Capability.requestsApprove,
  },
  Role.ketuaPanitia: {Capability.requestsSubmit, Capability.requestsApprove},
  Role.sekretarisPanitia: {},
};

enum GrantKind { assignment, cover, delegation, member }

/// One way a person may act at a date: an assignment, a vacancy cover, a
/// delegation, or plain membership. [toActor] is the actor of a command
/// done through it.
class Grant {
  const Grant({
    required this.kind,
    required this.personId,
    required this.scopeId,
    required this.title,
    required this.capabilities,
    this.assignmentId,
    this.postId,
    this.delegationId,
    this.viaLabel,
  });

  final GrantKind kind;
  final String personId;
  final String scopeId;

  /// The post title ('Penatua Kolom 7'), the delegated task, or 'Anggota
  /// jemaat'.
  final String title;
  final Set<Capability> capabilities;

  /// The assignment acted in: the post's own, or the Operator's for a cover.
  final String? assignmentId;
  final String? postId;
  final String? delegationId;

  /// 'menjalankan jabatan kosong Bendahara Jemaat', 'pelimpahan dari …'.
  final String? viaLabel;

  String get id => switch (kind) {
    GrantKind.assignment => 'assignment:$assignmentId',
    GrantKind.cover => 'cover:$postId',
    GrantKind.delegation => 'delegation:$delegationId',
    GrantKind.member => 'member:$personId',
  };

  Via get via => switch (kind) {
    GrantKind.cover => ViaVacancyCover(postId!),
    GrantKind.delegation => ViaDelegation(delegationId!),
    _ => Via.direct,
  };

  Actor toActor() => Actor(
    personId: personId,
    assignmentId: assignmentId,
    scopeId: scopeId,
    via: via,
  );

  @override
  bool operator ==(Object other) => other is Grant && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// What the gate reads. `TabelInti` implements it.
abstract interface class AuthorityFacts {
  Person? person(String id);
  Iterable<Person> get people;
  Post? post(String id);
  Iterable<Post> get posts;
  Iterable<Assignment> get assignments;
  Iterable<AuthorityGrant> get authorityGrants;
  Iterable<Delegation> get delegations;
  Iterable<VacancyCover> get covers;
  Scope? scope(String id);
  ModuleStatus moduleStatus(Module module);
}

/// The capability gate (README 3.5, PMP 5): "may this person do this, in this
/// scope, at this time". One place, a static table plus these checks, so it
/// maps onto row-level security later. It takes no record.
class Can {
  const Can(this.facts);

  final AuthorityFacts facts;

  /// A module is active when it and the module it needs are ACTIVE.
  bool moduleActive(Module? m) =>
      m == null ||
      (facts.moduleStatus(m) == ModuleStatus.active && moduleActive(m.needs));

  /// READ_ONLY still allows reads (PMP 8).
  bool moduleReadable(Module? m) =>
      m == null ||
      (facts.moduleStatus(m) != ModuleStatus.off && moduleReadable(m.needs));

  bool _moduleAllows(Capability c) =>
      c.read ? moduleReadable(c.module) : moduleActive(c.module);

  /// Every way [personId] may act at [at], in this order: assignments (post
  /// order), vacancy covers, delegations, membership.
  List<Grant> grantsOf(String personId, {required Tanggal at}) {
    final p = facts.person(personId);
    if (p == null) return const [];
    final hasil = <Grant>[];
    final posts = facts.posts.toList();
    final mine =
        facts.assignments
            .where((a) => a.personId == personId && a.inForce(at))
            .toList()
          ..sort(
            (a, b) => posts
                .indexWhere((x) => x.id == a.postId)
                .compareTo(posts.indexWhere((x) => x.id == b.postId)),
          );
    for (final a in mine) {
      final post = facts.post(a.postId);
      if (post == null) continue;
      if (post.role.needsAuthority && !_authorized(a.id, at)) continue;
      hasil.add(
        Grant(
          kind: GrantKind.assignment,
          personId: personId,
          scopeId: post.scopeId,
          title: post.title,
          capabilities: roleCapabilities[post.role]!,
          assignmentId: a.id,
          postId: post.id,
        ),
      );
    }
    final operatorAssignment = mine
        .where((a) => facts.post(a.postId)?.role == Role.operator)
        .firstOrNull;
    if (operatorAssignment != null) {
      for (final c in facts.covers) {
        if (c.personId != personId || !c.inForce(at)) continue;
        final post = facts.post(c.postId);
        if (post == null) continue;
        hasil.add(
          Grant(
            kind: GrantKind.cover,
            personId: personId,
            scopeId: post.scopeId,
            title: post.title,
            capabilities: roleCapabilities[post.role]!,
            assignmentId: operatorAssignment.id,
            postId: post.id,
            viaLabel: 'menjalankan jabatan kosong ${post.title}',
          ),
        );
      }
    }
    for (final d in facts.delegations) {
      if (d.toPersonId != personId || !d.inForce(at)) continue;
      final dari = facts.person(d.fromPersonId);
      hasil.add(
        Grant(
          kind: GrantKind.delegation,
          personId: personId,
          scopeId: d.task.scopeId,
          title: d.task.label,
          capabilities: {d.task.capability},
          delegationId: d.id,
          viaLabel: 'pelimpahan dari ${dari?.name ?? d.fromPersonId}',
        ),
      );
    }
    if (p.status == PersonStatus.active && !p.isSystem) {
      hasil.add(
        Grant(
          kind: GrantKind.member,
          personId: personId,
          scopeId: ScopeRef.jemaatId,
          title: 'Anggota jemaat',
          capabilities: memberCapabilities,
        ),
      );
    }
    return hasil;
  }

  bool _authorized(String assignmentId, Tanggal at) =>
      facts.authorityGrants.any(
        (g) =>
            g.assignmentId == assignmentId &&
            g.status == GrantStatus.active &&
            (g.verifiedAt == null || !(at < Tanggal.dari(g.verifiedAt!))),
      );

  /// Whether [grantScope] is [asked] or one of its ancestors.
  bool covers(String grantScope, ScopeRef asked) {
    if (asked.isAnywhere || grantScope == asked.scopeId) return true;
    var s = facts.scope(asked.scopeId);
    final seen = <String>{};
    while (s?.parentId != null && seen.add(s!.id)) {
      if (s.parentId == grantScope) return true;
      s = facts.scope(s.parentId!);
    }
    return false;
  }

  /// The grants of [personId] that give [c] in [scope] at [at] (the module
  /// aside). Two or more for a [Capability.decision] means "Sebagai …".
  List<Grant> grantsFor(
    String personId,
    Capability c,
    ScopeRef scope, {
    required Tanggal at,
  }) => [
    for (final g in grantsOf(personId, at: at))
      if (g.capabilities.contains(c) && covers(g.scopeId, scope)) g,
  ];

  /// The grant a command by [actor] uses: the actor's own acting grant when
  /// it gives [c], else the person's first that does; null when none does or
  /// the module does not allow it. Repositories record it in the audit line.
  Grant? grantFor(
    Actor actor,
    Capability c,
    ScopeRef scope, {
    required Tanggal at,
  }) {
    if (!_moduleAllows(c)) return null;
    final g = grantsFor(actor.personId, c, scope, at: at);
    if (g.isEmpty) return null;
    return g.firstWhere(
      (x) => x.assignmentId == actor.assignmentId && x.via == actor.via,
      orElse: () => g.first,
    );
  }

  /// README 3.5: the module is active (READ_ONLY: reads only), and an
  /// assignment, delegation or vacancy cover in force at [at] gives [c] in a
  /// scope that is [scope] or an ancestor of it.
  bool can(Actor actor, Capability c, ScopeRef scope, {required Tanggal at}) =>
      grantFor(actor, c, scope, at: at) != null;

  /// The refusal for the UI when [can] is false; null when it is true.
  Refusal? whyNot(
    Actor actor,
    Capability c,
    ScopeRef scope, {
    required Tanggal at,
  }) {
    if (can(actor, c, scope, at: at)) return null;
    if (!_moduleAllows(c)) {
      return Refusal(
        action: c.label,
        because: 'Modul ${c.module!.label} tidak aktif.',
      );
    }
    final siapa = whoCan(c, scope, at: at).map((p) => p.name).join(', ');
    return Refusal(
      action: c.label,
      because: 'Jabatan Anda tidak berwenang untuk ini.',
      whoCanAct: siapa.isEmpty ? null : siapa,
    );
  }

  /// The people (not system actors, not by membership alone) who may do [c]
  /// in [scope] at [at].
  List<Person> whoCan(Capability c, ScopeRef scope, {required Tanggal at}) => [
    for (final p in facts.people)
      if (!p.isSystem &&
          grantsFor(
            p.id,
            c,
            scope,
            at: at,
          ).any((g) => g.kind != GrantKind.member))
        p,
  ];

  /// The posts a person with two posts must choose between (Q31): their
  /// assignments that share a [Capability.decision]. Empty when the app can
  /// pick the post itself.
  List<Grant> choicesOf(String personId, {required Tanggal at}) {
    final langsung = grantsOf(
      personId,
      at: at,
    ).where((g) => g.kind == GrantKind.assignment).toList();
    final pilih = <Grant>{};
    for (var i = 0; i < langsung.length; i++) {
      for (var j = i + 1; j < langsung.length; j++) {
        final sama = langsung[i].capabilities
            .intersection(langsung[j].capabilities)
            .where((c) => c.decision);
        if (sama.isNotEmpty) pilih.addAll([langsung[i], langsung[j]]);
      }
    }
    return [
      for (final g in langsung)
        if (pilih.contains(g)) g,
    ];
  }
}
