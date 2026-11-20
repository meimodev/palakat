import 'actor.dart';
import 'files.dart';
import 'modules.dart';

/// One append-only audit line (DM 3 AuditRecord): who acted, in which post,
/// scope and way, what changed, why and when. Written by the repositories
/// inside each command, never by the UI.
class AuditRecord {
  const AuditRecord({
    required this.id,
    required this.at,
    required this.personId,
    required this.personName,
    required this.actingRole,
    this.assignmentId,
    required this.scopeId,
    this.via = Via.direct,
    this.viaLabel,
    this.module,
    required this.action,
    required this.summary,
    this.before,
    this.after,
    this.reason,
    this.ref,
  });

  final String id;
  final DateTime at;
  final String personId;

  /// The actor's name as recorded: 'Yanti Sumual'.
  final String personName;

  /// The post title acted in: 'Operator', 'Bendahara Jemaat'.
  final String actingRole;
  final String? assignmentId;
  final String scopeId;
  final Via via;

  /// 'menjalankan jabatan kosong Bendahara Jemaat' or 'atas pelimpahan …'.
  final String? viaLabel;

  /// Null for core actions.
  final Module? module;

  /// A stable key: 'role.assign', 'module.switch', 'session.end_device'.
  final String action;

  /// The Riwayat line: 'Menugaskan Yohanis Tumbelaka sebagai Bendahara Jemaat'.
  final String summary;
  final String? before;
  final String? after;
  final String? reason;
  final RecordRef? ref;

  /// 'Yanti Sumual, Operator · menjalankan jabatan kosong Bendahara Jemaat'.
  String get actorLine => ['$personName, $actingRole', ?viaLabel].join(' · ');
}

/// AuditRepository.list filter; every field narrows.
class AuditFilter {
  const AuditFilter({
    this.personId,
    this.module,
    this.coreOnly = false,
    this.ref,
    this.actionPrefix,
    this.from,
    this.to,
  });

  final String? personId;
  final Module? module;

  /// Only records with no module (core actions).
  final bool coreOnly;
  final RecordRef? ref;

  /// 'role.' matches every role action.
  final String? actionPrefix;
  final DateTime? from;
  final DateTime? to;
}
