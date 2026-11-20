import '../../core/tanggal.dart';

/// Organizational unit types (PMP 5, DL17).
enum ScopeType { jemaat, kolom, bipra, komisi, panitia, custom }

/// An organizational unit (DM 3 Scope): the hierarchy has no cycles.
class Scope {
  Scope({
    required this.id,
    required this.type,
    required this.name,
    this.parentId,
    this.start,
    this.end,
    this.active = true,
    this.revision = 1,
  });

  final String id;
  final ScopeType type;

  /// 'Kolom 7', 'Komisi Diakonia', 'Panitia Natal …'.
  String name;
  final String? parentId;
  Tanggal? start;
  Tanggal? end;
  bool active;
  int revision;
}

/// What a new Panitia or unit needs (OrgRepository.createScope, M9).
class ScopeDraft {
  const ScopeDraft({
    required this.type,
    required this.name,
    this.parentId = ScopeRef.jemaatId,
    this.start,
  });

  final ScopeType type;
  final String name;
  final String parentId;
  final Tanggal? start;
}

/// The scope a capability is asked for (README 3.5). [anywhere] asks whether
/// the person holds the capability in any scope (route guards).
class ScopeRef {
  const ScopeRef(this.scopeId);

  static const jemaatId = 'jemaat';
  static const jemaat = ScopeRef(jemaatId);
  static const anywhere = ScopeRef('*');

  final String scopeId;

  bool get isAnywhere => scopeId == '*';

  @override
  bool operator ==(Object other) =>
      other is ScopeRef && other.scopeId == scopeId;

  @override
  int get hashCode => scopeId.hashCode;
}
