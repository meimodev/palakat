import '../../domain/core/core.dart';

/// Organizational units (README 4.1).
abstract interface class OrgRepository {
  List<Scope> scopes({ScopeType? type});
  Scope? scope(String id);

  /// Parent first, up to the Jemaat; [id] itself excluded.
  List<Scope> ancestors(String id);

  /// A Panitia or other unit (M9).
  Future<Result<Scope>> createScope(
    Actor actor,
    ScopeDraft draft, {
    required String idempotencyKey,
  });
}
